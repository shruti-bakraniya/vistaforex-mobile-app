import 'package:dio/dio.dart';
import '../core/dio_client.dart';
import 'models.dart';

/// Open Exchange Rates (open.er-api.com) — free tier, no API key required.
/// Docs: https://www.exchangerate-api.com/docs/free
class OpenErProvider {
  OpenErProvider._();
  static final instance = OpenErProvider._();

  static const _base = 'https://open.er-api.com/v6';
  Dio get _dio => DioClient.instance.dio;

  /// Fetch latest rates with [baseCurrency] as the base.
  Future<RatesResult> fetchLatest({String baseCurrency = 'USD'}) async {
    final response = await _dio.get('$_base/latest/$baseCurrency');
    final data = response.data as Map<String, dynamic>;

    if (data['result'] != 'success') {
      throw Exception('Open.er-api returned error: ${data['error-type']}');
    }

    final rates = <String, double>{};
    (data['rates'] as Map<String, dynamic>).forEach((k, v) {
      rates[k] = (v as num).toDouble();
    });

    final dateStr = data['time_last_update_utc'] as String? ?? '';
    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now();
    }

    return RatesResult(
      rates: rates,
      base: baseCurrency,
      date: date,
      fromCache: false,
    );
  }
}
