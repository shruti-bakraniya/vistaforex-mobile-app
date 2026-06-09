import 'package:get/get.dart';
import '../convert/convert_controller.dart';
import '../history/history_controller.dart';
import '../ledger/ledger_controller.dart';
import '../settings/settings_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(HomeController.new, fenix: true);
    Get.lazyPut<ConvertController>(ConvertController.new, fenix: true);
    Get.lazyPut<HistoryController>(HistoryController.new, fenix: true);
    Get.lazyPut<LedgerController>(LedgerController.new, fenix: true);
    Get.lazyPut<SettingsController>(SettingsController.new, fenix: true);
  }
}
