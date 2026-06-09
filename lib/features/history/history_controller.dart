import 'package:get/get.dart';
import '../../data/exchange_rate_repository.dart';
import '../../data/models.dart';
import '../home/home_controller.dart';

class HistoryController extends GetxController {
  HomeController get home => Get.find<HomeController>();

  final selectedDays = 30.obs;
  final historyPoints = <RatePoint>[].obs;
  final isLoading = false.obs;
  final isFromCache = false.obs;

  static const rangeDays = [7, 30, 90, 365];

  @override
  void onInit() {
    super.onInit();
    ever(selectedDays, (_) => loadHistory());
    ever(home.fromCode, (_) => loadHistory());
    ever(home.toCode, (_) => loadHistory());
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final result = await ExchangeRateRepository.instance.getHistory(
        from: home.fromCode.value,
        to: home.toCode.value,
        days: selectedDays.value,
        currentRates: home.rates.value,
      );
      historyPoints.value = result.points;
      isFromCache.value = result.fromCache;
    } catch (e) {
      historyPoints.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  double get currentRate =>
      historyPoints.isEmpty ? 0 : historyPoints.last.value;

  double get firstRate =>
      historyPoints.isEmpty ? 0 : historyPoints.first.value;

  double get hi =>
      historyPoints.isEmpty ? 0 : historyPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b);

  double get lo =>
      historyPoints.isEmpty ? 0 : historyPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b);

  double get avg => historyPoints.isEmpty
      ? 0
      : historyPoints.map((p) => p.value).reduce((a, b) => a + b) /
          historyPoints.length;

  double get pctChange =>
      firstRate == 0 ? 0 : ((currentRate - firstRate) / firstRate) * 100;

  bool get isUp => pctChange >= 0;

  double get volatility => avg == 0 ? 0 : ((hi - lo) / avg) * 100;
}
