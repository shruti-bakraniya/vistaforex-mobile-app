import 'package:get/get.dart';
import '../../core/connectivity_service.dart';
import '../../core/dio_client.dart';
import '../../data/currencies.dart';
import '../../data/exchange_rate_repository.dart';
import '../../data/ledger_repository.dart';
import '../../data/models.dart';

enum ConnState { live, cached, offline }

class HomeController extends GetxController {
  // ── Tab navigation ──────────────────────────────────────────
  final currentTab = 0.obs;

  // ── Theme ───────────────────────────────────────────────────
  final isDark = false.obs;

  void toggleTheme() => isDark.value = !isDark.value;

  // ── Currency pair ────────────────────────────────────────────
  final fromCode = 'USD'.obs;
  final toCode = 'INR'.obs;
  final amount = 1000.0.obs;

  Currency get fromCurrency => getCurrency(fromCode.value);
  Currency get toCurrency => getCurrency(toCode.value);

  double get crossRate {
    final r = rates.value;
    if (r.isEmpty) return 0;
    final f = r[fromCode.value] ?? 1.0;
    final t = r[toCode.value] ?? 1.0;
    if (f == 0) return 0;
    return t / f;
  }

  double get result => amount.value * crossRate;

  void swap() {
    final tmp = fromCode.value;
    fromCode.value = toCode.value;
    toCode.value = tmp;
  }

  // ── Exchange rates ───────────────────────────────────────────
  final rates = <String, double>{}.obs;
  final ratesDate = Rxn<DateTime>();
  final isLoadingRates = false.obs;
  final ratesError = RxnString();

  // ── Connectivity ─────────────────────────────────────────────
  final connState = ConnState.live.obs;
  bool get isOnline => connState.value == ConnState.live;

  // ── Data sources ─────────────────────────────────────────────
  final activeSourceId = 'frankfurter'.obs;

  // ── Toast message ────────────────────────────────────────────
  final toastMessage = RxnString();

  void showToast(String msg) {
    toastMessage.value = msg;
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (toastMessage.value == msg) toastMessage.value = null;
    });
  }

  // ── Last sync ────────────────────────────────────────────────
  DateTime? get lastSyncTime => ExchangeRateRepository.instance.lastSyncTime;

  // ── Init ─────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    DioClient.instance.init();
    Get.put(ConnectivityService());

    // React to real connectivity changes
    ConnectivityService.to.isOnline.listen((online) {
      if (!online && connState.value == ConnState.live) {
        connState.value = ConnState.cached;
      } else if (online && connState.value == ConnState.cached) {
        fetchRates();
      }
    });

    fetchRates();
  }

  Future<void> fetchRates() async {
    isLoadingRates.value = true;
    ratesError.value = null;
    try {
      final result = await ExchangeRateRepository.instance.getRates(
        base: 'USD',
        sourceId: activeSourceId.value,
      );
      rates.value = result.rates;
      ratesDate.value = result.date;
      if (result.fromCache) {
        connState.value = ConnState.cached;
      } else {
        connState.value = ConnState.live;
      }
    } catch (e) {
      ratesError.value = e.toString();
      connState.value = ConnState.offline;
    } finally {
      isLoadingRates.value = false;
    }
  }

  void retryConnection() => fetchRates();

  void useCachedRates() {
    connState.value = ConnState.cached;
    showToast('Using cached rates');
  }

  // ── Ledger ───────────────────────────────────────────────────
  Future<void> saveConversion() async {
    await LedgerRepository.instance.record(
      from: fromCode.value,
      to: toCode.value,
      amount: amount.value,
      rate: crossRate,
      sourceName: _sourceDisplayName(),
    );
    showToast('Saved to your ledger');
  }

  String _sourceDisplayName() {
    return switch (activeSourceId.value) {
      'frankfurter' => 'Frankfurter (ECB)',
      'open_er' => 'Open Exchange Rates',
      _ => activeSourceId.value,
    };
  }

  void reuseConversion(ConversionEntry entry) {
    fromCode.value = entry.from;
    toCode.value = entry.to;
    amount.value = entry.amount;
    currentTab.value = 0;
    showToast('Loaded ${entry.from} → ${entry.to}');
  }
}
