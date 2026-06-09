import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'connectivity_service.dart';

class DioClient {
  DioClient._();
  static final instance = DioClient._();

  late final Dio _dio;

  void init() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _ConnectivityInterceptor(),
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        logPrint: (o) {
          // Suppress in production; print in debug
          assert(() {
            // ignore: avoid_print
            print('[DIO] $o');
            return true;
          }());
        },
      ),
      _ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}

class _ConnectivityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final svc = Get.isRegistered<ConnectivityService>()
        ? Get.find<ConnectivityService>()
        : null;
    if (svc != null && !svc.isOnline.value) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
        true,
      );
      return;
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final msg = switch (err.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out',
      DioExceptionType.receiveTimeout => 'Server took too long to respond',
      DioExceptionType.sendTimeout => 'Request timed out',
      DioExceptionType.connectionError => err.message ?? 'No internet connection',
      DioExceptionType.badResponse => 'Server error: ${err.response?.statusCode}',
      _ => err.message ?? 'An unexpected error occurred',
    };
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        message: msg,
      ),
    );
  }
}
