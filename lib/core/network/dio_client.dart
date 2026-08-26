import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// ✅ IP الاستضافة العامة
const String _kServerIp = '169.58.124.216';

const String kApiBaseUrl = 'http://$_kServerIp/api';
const String kServerRootUrl = 'http://$_kServerIp';

class DioClient {
  DioClient._internal();
  static final DioClient instance = DioClient._internal();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('❌ API Error: ${error.message}');
          debugPrint('URL: ${error.requestOptions.uri}');
          handler.next(error);
        },
        onRequest: (options, handler) {
          debugPrint('➡️ Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ Response: ${response.statusCode}');
          handler.next(response);
        },
      ),
    );
}

String fullImageUrl(String path) {
  if (path.startsWith('http')) return path;
  if (path.isEmpty) return '';
  return '$kServerRootUrl/storage/$path';
}