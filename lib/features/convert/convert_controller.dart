import 'package:get/get.dart';
import '../../data/exchange_rate_repository.dart';
import '../home/home_controller.dart';

class ConvertController extends GetxController {
  HomeController get home => Get.find<HomeController>();

  final swapAngle = 0.0.obs;
  final isSaved = false.obs;

  // 30-day history for the active pair (drives sparkline + mini stats).
  // Fetched once per pair change, NOT on every amount keystroke.
  final spark = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Refetch the sparkline only when the pair or the underlying rates change.
    ever(home.fromCode, (_) => _loadSpark());
    ever(home.toCode, (_) => _loadSpark());
    ever(home.rates, (_) => _loadSpark());
    _loadSpark();
  }

  Future<void> _loadSpark() async {
    if (home.rates.isEmpty) return;
    final result = await ExchangeRateRepository.instance.getHistory(
      from: home.fromCode.value,
      to: home.toCode.value,
      days: 30,
      currentRates: home.rates.value,
    );
    spark.value = result.points.map((p) => p.value).toList();
  }

  double get sparkPct {
    if (spark.length < 2) return 0;
    final first = spark.first;
    if (first == 0) return 0;
    return ((spark.last - first) / first) * 100;
  }

  bool get sparkUp => sparkPct >= 0;

  double get sparkLo =>
      spark.isEmpty ? 0 : spark.reduce((a, b) => a < b ? a : b);

  double get sparkHi =>
      spark.isEmpty ? 0 : spark.reduce((a, b) => a > b ? a : b);

  void swap() {
    swapAngle.value += 180;
    home.swap();
    isSaved.value = false;
  }

  void save() {
    home.saveConversion();
    isSaved.value = true;
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (isSaved.value) isSaved.value = false;
    });
  }
}
