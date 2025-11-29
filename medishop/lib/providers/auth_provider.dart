// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/models/utilisateur.dart';
import 'package:medishop/models/user_type.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  Utilisateur? _currentUser;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Utilisateur? get currentUser => _currentUser;

  UserType get userType => _currentUser?.typeUtilisateur ?? UserType.UNKNOWN;

  AuthProvider(this._apiService) {
    _checkInitialAuth();
  }

  // Vérification initiale
  Future<bool> checkAuthenticationStatus() async {
    final accessToken = await _apiService.tokenManager.getAccessToken();
    if (accessToken != null && !_isAuthenticated) {
      await _loadUserProfile();
    }
    return _isAuthenticated;
  }

  Future<void> _checkInitialAuth() async {
    await checkAuthenticationStatus();
    _isLoading = false;
    notifyListeners();
  }

  // Route selon le type utilisateur
  String getHomeRoute() {
    if (_currentUser == null) return '/login';

    switch (userType) {
      case UserType.CLIENT:
        return '/client/home';
      case UserType.PHARMACIE:
        return '/pharmacie/dashboard';
      case UserType.LIVREUR:
        return '/livreur/home';
      default:
        return '/login';
    }
  }

  // -------------------------
  //          LOGIN
  // -------------------------
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.nonAuthDio.post(
        ApiConstants.tokenEndpoint,
        data: {"email": email, "password": password},
      );

      final accessToken = response.data['access'];
      final refreshToken = response.data['refresh'];

      await _apiService.tokenManager.setTokens(accessToken, refreshToken);

      await _loadUserProfile();
    } on DioException catch (e) {
      _isAuthenticated = false;

      final errorMessage =
          e.response?.data['detail'] ?? 'Identifiants invalides';

      throw Exception(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------
  //         REGISTER
  // -------------------------
  Future<void> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required UserType type,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.nonAuthDio.post(
        'utilisateurs/', // CORRECTION : endpoint DRF
        data: {
          "email": email,
          "password": password,
          "nom": nom,
          "prenom": prenom,
          "type_utilisateur": type.name,
        },
      );

      // Auto login
      await login(email, password);
    } on DioException catch (e) {
      String msg = "Échec de l'inscription.";

      if (e.response?.data is Map) {
        final errors = e.response!.data;
        if (errors.containsKey("email")) {
          msg = "Email: ${errors['email'][0]}";
        } else if (errors.containsKey("detail")) {
          msg = errors["detail"];
        }
      }

      throw Exception(msg);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------
  //  Récupération du profil
  // -------------------------
  Future<void> _loadUserProfile() async {
    try {
      final response =
          await _apiService.authDio.get(ApiConstants.userMeEndpoint);

      _currentUser = Utilisateur.fromJson(response.data);
      _isAuthenticated = true;
      notifyListeners();
    } catch (_) {
      await logout(isManual: false);
    }
  }

  // -------------------------
  //      UPDATE PROFILE
  // -------------------------
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.authDio.patch(
        'utilisateurs/me/',
        data: data,
      );

      _currentUser = Utilisateur.fromJson(response.data);
      notifyListeners();
    } on DioException {
      throw Exception("Erreur mise à jour du profil.");
    }
  }

  // -------------------------
  //          LOGOUT
  // -------------------------
  Future<void> logout({bool isManual = true}) async {
    await _apiService.tokenManager.clearTokens();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
