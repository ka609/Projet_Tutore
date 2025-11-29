// lib/providers/user_settings_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/models/parametre_utilisateur.dart'; // Importez votre modèle

class UserSettingsProvider with ChangeNotifier {
  final ApiService _apiService;

  List<ParametreUtilisateur> _settings = [];
  bool _isLoading = false;
  String? _error;

  List<ParametreUtilisateur> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserSettingsProvider(this._apiService);

  // Helper: Récupère la valeur d'un paramètre par sa clé
  String? getSettingValue(String key) {
    return _settings
        .firstWhere(
          (p) => p.cleParametre == key,
          orElse: () => ParametreUtilisateur(
              id: 0, utilisateur: '', cleParametre: '', valeurParametre: ''),
        )
        .valeurParametre;
  }

  // --- 1. CHARGEMENT DES PARAMÈTRES ---
  Future<void> fetchSettings({bool forceRefresh = false}) async {
    if (_settings.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.authDio.get(
        ApiConstants.baseUrl + '/api/users/parametres/',
      );

      _settings = (response.data as List)
          .map((json) => ParametreUtilisateur.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = 'Impossible de charger les paramètres utilisateur.';
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  // --- 2. MISE À JOUR/CRÉATION D'UN PARAMÈTRE ---
  Future<void> updateSetting(
      {required String key, required String value}) async {
    final existingIndex = _settings.indexWhere((p) => p.cleParametre == key);

    try {
      // 1. Appel API (utilisation de PUT ou PATCH pour l'upsert)
      final response = await _apiService.authDio.patch(
        ApiConstants.baseUrl +
            '/api/users/parametres/', // Peut nécessiter un endpoint spécifique
        data: {
          'cle_parametre': key,
          'valeur_parametre': value,
        },
      );

      // 2. Mettre à jour l'état local avec la réponse du serveur
      final updatedParam = ParametreUtilisateur.fromJson(response.data);

      if (existingIndex != -1) {
        // Mise à jour de l'élément existant
        _settings[existingIndex] = updatedParam;
      } else {
        // Ajout d'un nouvel élément
        _settings.add(updatedParam);
      }

      notifyListeners();
    } on DioException catch (e) {
      _error = 'Échec de la mise à jour du paramètre $key.';
      notifyListeners();
      throw Exception(_error);
    }
  }

  // Vider l'état (lors de la déconnexion)
  void clearState() {
    _settings = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
