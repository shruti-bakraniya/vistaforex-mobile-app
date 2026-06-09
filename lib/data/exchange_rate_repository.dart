import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../core/cache_service.dart';
import 'currencies.dart';
import 'frankfurter_provider.dart';
import 'models.dart';
import 'open_er_provider.dart';

const _kRatesKey = 'cached_rates';
const _kRatesTimestamp = 'cached_rates_ts';
const _kHistoryPrefix = 'cached_history_';

class ExchangeRateRepository {
  ExchangeRateRepository._();
  static final instance = ExchangeRateRepository._();

  final _frankfurter = FrankfurterProvider.instance;
  final _openEr = OpenErProvider.instance;
  final _cache = CacheService.instance;

  Future<RatesResult> getRates({
    String base = 'USD',
    required String sourceId,
  }) async {
    try {
      final result = await _fetchFromSource(sourceId: sourceId, base: base);
      await _cacheRates(result);
      return result;
    } on DioException catch (e) {
      final cached = _loadCachedRates(base);
      if (cached != null) return cached;
      throw Exception(e.message ?? 'Failed to fetch rates');
    } catch (e) {
      final cached = _loadCachedRates(base);
      if (cached != null) return cached;
      // Last resort: fallback rates
      return RatesResult(
        rates: kFallbackRates,
        base: 'USD',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        fromCache: true,
      );
    }
  }

  Future<RatesResult> _fetchFromSource({
    required String sourceId,
    required String base,
  }) {
    return switch (sourceId) {
      'frankfurter' || 'ecb' => _frankfurter.fetchLatest(baseCurrency: base),
      'open_er' || 'openex' => _openEr.fetchLatest(baseCurrency: base),
      _ => _frankfurter.fetchLatest(baseCurrency: base), // Default to Frankfurter
    };
  }

  Future<void> _cacheRates(RatesResult result) async {
    await _cache.setJson(_kRatesKey, {
      'base': result.base,
      'date': result.date.toIso8601String(),
      'rates': result.rates,
    });
    await _cache.setString(_kRatesTimestamp, DateTime.now().toIso8601String());
  }

  RatesResult? _loadCachedRates(String base) {
    final json = _cache.getJson(_kRatesKey);
    if (json == null) return null;
    try {
      final ratesRaw = json['rates'] as Map<String, dynamic>;
      final rates = ratesRaw.map((k, v) => MapEntry(k, (v as num).toDouble()));
      return RatesResult(
        rates: rates,
        base: json['base'] as String? ?? 'USD',
        date: DateTime.parse(json['date'] as String),
        fromCache: true,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns cached timestamp, or null if never synced.
  DateTime? get lastSyncTime {
    final ts = _cache.getString(_kRatesTimestamp);
    if (ts == null) return null;
    try {
      return DateTime.parse(ts);
    } catch (_) {
      return null;
    }
  }

  /// Get rate history; uses Frankfurter for real data or generates a
  /// seeded random walk if the API fails / pair not supported.
  Future<HistoryResult> getHistory({
    required String from,
    required String to,
    required int days,
    required Map<String, double> currentRates,
  }) async {
    final cacheKey = '$_kHistoryPrefix${from}_${to}_$days';

    // Try network first
    try {
      final result = await _frankfurter.fetchHistory(
        fromCode: from,
        toCode: to,
        days: days,
      );
      if (result.points.isNotEmpty) {
        await _cacheHistory(cacheKey, result.points);
        return result;
      }
    } catch (_) {}

    // Try disk cache
    final cached = _loadCachedHistory(cacheKey);
    if (cached != null) {
      return HistoryResult(points: cached, fromCache: true);
    }

    // Generate seeded fallback
    return HistoryResult(
      points: _generateFallbackHistory(
        from: from,
        to: to,
        days: days,
        currentRates: currentRates,
      ),
      fromCache: true,
    );
  }

  Future<void> _cacheHistory(String key, List<RatePoint> points) async {
    final list = points
        .map((p) => {
              'date': p.date.toIso8601String(),
              'value': p.value,
            })
        .toList();
    await _cache.setList(key, list);
  }

  List<RatePoint>? _loadCachedHistory(String key) {
    final list = _cache.getList(key);
    if (list == null) return null;
    try {
      return list
          .map((e) => RatePoint(
                date: DateTime.parse(e['date'] as String),
                value: (e['value'] as num).toDouble(),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }

  List<RatePoint> _generateFallbackHistory({
    required String from,
    required String to,
    required int days,
    required Map<String, double> currentRates,
  }) {
    final fromRate = currentRates[from] ?? kFallbackRates[from] ?? 1.0;
    final toRate = currentRates[to] ?? kFallbackRates[to] ?? 1.0;
    final baseRate = toRate / fromRate;

    final seed = (from.codeUnitAt(0) * 131 +
            to.codeUnitAt(math.min(2, to.length - 1)) * 17 +
            from.length * 7 +
            991) %
        2147483647;

    final walk = _seededWalk(seed, days);
    final amp = baseRate * 0.032;
    final today = DateTime.now();

    final points = List.generate(days, (i) {
      final d = today.subtract(Duration(days: days - 1 - i));
      final val = baseRate + (walk[i] - 0.5) * 2 * amp;
      return RatePoint(date: d, value: val);
    });

    // Pin last point to current rate
    if (points.isNotEmpty) {
      return [
        ...points.take(points.length - 1),
        RatePoint(date: points.last.date, value: baseRate),
      ];
    }
    return points;
  }

  List<double> _seededWalk(int seed, int n) {
    var s = seed % 2147483647;
    if (s <= 0) s += 2147483646;
    double next() {
      s = (s * 16807) % 2147483647;
      return s / 2147483647;
    }

    final out = <double>[];
    var v = 0.5;
    for (var i = 0; i < n; i++) {
      v += (next() - 0.48) * 0.12;
      v = v.clamp(0.06, 0.94);
      out.add(v);
    }
    final min = out.reduce(math.min);
    final max = out.reduce(math.max);
    final span = (max - min).abs().clamp(0.001, double.infinity);
    return out.map((x) => (x - min) / span).toList();
  }
}
