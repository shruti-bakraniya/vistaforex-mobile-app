import '../core/cache_service.dart';
import 'models.dart';

const _kLedgerKey = 'conversion_ledger';

class LedgerRepository {
  LedgerRepository._();
  static final instance = LedgerRepository._();

  final _cache = CacheService.instance;

  List<ConversionEntry> getAll() {
    final list = _cache.getList(_kLedgerKey);
    if (list == null) return [];
    try {
      return list
          .map((e) => ConversionEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      return [];
    }
  }

  Future<void> save(ConversionEntry entry) async {
    final all = getAll();
    all.insert(0, entry);
    await _cache.setList(_kLedgerKey, all.map((e) => e.toJson()).toList());
  }

  Future<ConversionEntry> record({
    required String from,
    required String to,
    required double amount,
    required double rate,
    required String sourceName,
  }) async {
    final entry = ConversionEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      from: from,
      to: to,
      amount: amount,
      rate: rate,
      timestamp: DateTime.now(),
      sourceName: sourceName,
    );
    await save(entry);
    return entry;
  }

  Future<void> clear() async {
    await _cache.remove(_kLedgerKey);
  }
}
