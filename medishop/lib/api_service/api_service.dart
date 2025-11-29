// lib/api_service/api_service.dart

import 'package:dio/dio.dart';
import 'package:medishop/api_service/auth_interceptor.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/api_service/token_manager.dart';

class ApiService {
  late Dio authDio;
  late Dio _nonAuthDio;
  final TokenManager tokenManager = TokenManager();

  ApiService() {
    final BaseOptions baseOptions = BaseOptions(
      baseUrl: ApiConstants.baseUrl, // ex : http://127.0.0.1:8000/api/
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {"Content-Type": "application/json"},
    );

    _nonAuthDio = Dio(baseOptions);

    authDio = Dio(baseOptions);
    authDio.interceptors.add(
      AuthInterceptor(_nonAuthDio, tokenManager),
    );
  }

  Dio get nonAuthDio => _nonAuthDio;
}
