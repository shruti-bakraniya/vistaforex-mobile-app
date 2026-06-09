import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import 'models.dart';

/// Frankfurter API — free ECB-based exchange rates, no API key required.
/// Docs: https://www.frankfurter.app/docs
class FrankfurterProvider {
  FrankfurterProvider._();
  static final instance = FrankfurterProvider._();

  static const _base = 'https://api.frankfurter.app';
  Dio get _dio => DioClient.instance.dio;

  /// Fetch latest rates with [baseCurrency] as the base.
  Future<RatesResult> fetchLatest({String baseCurrency = 'USD'}) async {
    final response = await _dio.get(
      '$_base/latest',
      queryParameters: {'base': baseCurrency},
    );
    final data = response.data as Map<String, dynamic>;
    final rates = <String, double>{baseCurrency: 1.0};
    (data['rates'] as Map<String, dynamic>).forEach((k, v) {
      rates[k] = (v as num).toDouble();
    });
    return RatesResult(
      rates: rates,
      base: baseCurrency,
      date: DateTime.parse(data['date'] as String),
      fromCache: false,
    );
  }

  /// Fetch daily rate history for [fromCode]→[toCode] over the last [days].
  Future<HistoryResult> fetchHistory({
    required String fromCode,
    required String toCode,
    int days = 30,
  }) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    final fmt = (DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final response = await _dio.get(
      '$_base/${fmt(start)}..${fmt(end)}',
      queryParameters: {'base': fromCode, 'symbols': toCode},
    );
    final data = response.data as Map<String, dynamic>;
    final ratesMap = data['rates'] as Map<String, dynamic>;

    final points = ratesMap.entries
        .map((e) {
          final dateStr = e.key;
          final inner = e.value as Map<String, dynamic>;
          final val = (inner[toCode] as num?)?.toDouble();
          if (val == null) return null;
          return RatePoint(date: DateTime.parse(dateStr), value: val);
        })
        .whereType<RatePoint>()
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return HistoryResult(points: points, fromCache: false);
  }
}
