import 'package:get/get.dart';
import '../../data/ledger_repository.dart';
import '../../data/models.dart';
import '../home/home_controller.dart';

class LedgerController extends GetxController {
  final entries = <ConversionEntry>[].obs;
  final searchQuery = ''.obs;

  HomeController get home => Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    loadEntries();
    // Reload when tab switches to ledger
    ever(home.currentTab, (tab) {
      if (tab == 2) loadEntries();
    });
  }

  void loadEntries() {
    entries.value = LedgerRepository.instance.getAll();
  }

  List<ConversionEntry> get filtered {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return entries;
    return entries.where((e) {
      return e.from.toLowerCase().contains(q) ||
          e.to.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, List<ConversionEntry>> get groupedByDate {
    final result = <String, List<ConversionEntry>>{};
    for (final e in filtered) {
      final key = _formatDate(e.timestamp);
      result.putIfAbsent(key, () => []).add(e);
    }
    return result;
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  void reuse(ConversionEntry entry) {
    home.reuseConversion(entry);
  }

  Future<void> clearAll() async {
    await LedgerRepository.instance.clear();
    entries.clear();
  }
}
