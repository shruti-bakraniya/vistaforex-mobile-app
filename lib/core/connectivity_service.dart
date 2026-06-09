import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    isOnline.value = _isConnected(result);
    _connectivity.onConnectivityChanged.listen((results) {
      isOnline.value = _isConnected(results);
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  static ConnectivityService get to => Get.find();
}
