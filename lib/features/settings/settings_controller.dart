import 'package:get/get.dart';
import '../../core/cache_service.dart';
import '../../data/api_sources.dart';
import '../../data/models.dart';
import '../home/home_controller.dart';

const _kSourceKey = 'active_source';
const _kSyncKey = 'sync_interval';
const _kCacheKey = 'use_offline_cache';

class SettingsController extends GetxController {
  HomeController get home => Get.find<HomeController>();

  final activeSourceId = 'frankfurter'.obs;
  final syncInterval = '30s'.obs;
  final useOfflineCache = true.obs;

  List<ApiSource> get sources => kApiSources;

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  void _loadPrefs() {
    final cache = CacheService.instance;
    activeSourceId.value = cache.getString(_kSourceKey) ?? 'frankfurter';
    syncInterval.value = cache.getString(_kSyncKey) ?? '30s';
    useOfflineCache.value =
        (cache.getString(_kCacheKey) ?? 'true') == 'true';
    home.activeSourceId.value = activeSourceId.value;
  }

  Future<void> setSource(String id) async {
    if (id == activeSourceId.value) return;
    activeSourceId.value = id;
    home.activeSourceId.value = id;
    await CacheService.instance.setString(_kSourceKey, id);
    home.fetchRates();
    home.showToast('Switched to ${_sourceName(id)}');
  }

  Future<void> setSyncInterval(String interval) async {
    syncInterval.value = interval;
    await CacheService.instance.setString(_kSyncKey, interval);
  }

  Future<void> setUseOfflineCache(bool value) async {
    useOfflineCache.value = value;
    await CacheService.instance.setString(_kCacheKey, value.toString());
  }

  String _sourceName(String id) {
    return kApiSources.firstWhere(
      (s) => s.id == id,
      orElse: () => kApiSources.first,
    ).name;
  }

  ApiSource get activeSource =>
      kApiSources.firstWhere(
        (s) => s.id == activeSourceId.value,
        orElse: () => kApiSources.first,
      );
}
