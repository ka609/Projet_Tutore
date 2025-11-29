// lib/api_service/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:medishop/api_service/token_manager.dart';
import 'package:medishop/api_service/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final Dio nonAuthDio; // Instance Dio sans intercepteur
  final TokenManager tokenManager;

  AuthInterceptor(this.nonAuthDio, this.tokenManager);

  // 1. Avant l'envoi : Ajout de l'Access Token
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await tokenManager
        .getAccessToken(); // Utilisation de tokenManager.getAccessToken()
    if (accessToken != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    super.onRequest(options, handler);
  }

  // 2. Après réception : Gestion de l'erreur 401
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si l'erreur est 401 ET que ce n'est pas déjà la requête de refresh
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != ApiConstants.tokenRefreshEndpoint) {
      // Utilisation d'ApiConstants
      final isRefreshed = await _refreshTokenAndRetry(err);

      if (isRefreshed) {
        // Si le refresh a réussi, relancer la requête originale
        return handler.resolve(await nonAuthDio.fetch(err.requestOptions));
      }

      // Si le refresh a échoué (refresh token expiré ou invalide), passer à l'erreur
      return handler.next(err);
    }
    super.onError(err, handler);
  }

  // --- Logique de Refresh du Token ---
  Future<bool> _refreshTokenAndRetry(DioException err) async {
    final refreshToken = await tokenManager.getRefreshToken();

    if (refreshToken == null) {
      return false;
    }

    try {
      final response = await nonAuthDio.post(
        ApiConstants.baseUrl +
            ApiConstants.tokenRefreshEndpoint, // Utilisation d'ApiConstants
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'] as String;
        final newRefreshToken = response.data['refresh'] as String;

        await tokenManager.setTokens(newAccessToken,
            newRefreshToken); // Utilisation de tokenManager.setTokens()

        // Mettre à jour le header de la requête originale
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        return true;
      }
    } catch (e) {
      await tokenManager.clearTokens();
    }
    return false;
  }
}
