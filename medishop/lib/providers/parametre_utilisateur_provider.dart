import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/models/parametre_utilisateur.dart';

class ParametreUtilisateurProvider with ChangeNotifier {
  final ApiService _apiService;

  // Stocke les paramètres sous forme de Map pour un accès rapide par clé (ex: 'theme', 'notifications_email')
  Map<String, ParametreUtilisateur> _parametres = {};
  Map<String, ParametreUtilisateur> get parametres => _parametres;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  ParametreUtilisateurProvider(this._apiService);

  // --- 1. Charger tous les paramètres de l'utilisateur actuel ---
  Future<void> fetchParametres() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Endpoint supposé pour récupérer TOUS les paramètres de l'utilisateur connecté
      final response = await _apiService.authDio
          .get('${ApiConstants.baseUrl}/utilisateurs/me/parametres/');

      final List<dynamic> data = response.data;

      _parametres = {
        for (var json in data)
          ParametreUtilisateur.fromJson(json).cleParametre:
              ParametreUtilisateur.fromJson(json),
      };
    } on DioException catch (e) {
      _error =
          'Erreur lors du chargement des paramètres: ${e.response?.statusCode}';
    } catch (e) {
      _error = 'Une erreur inattendue est survenue: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. Récupérer la valeur d'un paramètre spécifique ---
  String? getParametreValue(String cleParametre) {
    return _parametres[cleParametre]?.valeurParametre;
  }

  // --- 3. Mettre à jour (ou créer) un paramètre ---
  Future<void> updateParametre(String cle, String nouvelleValeur) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final existingParam = _parametres[cle];

      final data = {
        'cle_parametre': cle,
        'valeur_parametre': nouvelleValeur,
      };

      Response response;

      if (existingParam != null) {
        // Mise à jour (PATCH ou PUT) si le paramètre existe
        // L'API est supposée gérer l'ID ou utiliser la clé/utilisateur pour identifier
        response = await _apiService.authDio.patch(
            '${ApiConstants.baseUrl}/utilisateurs/me/parametres/${existingParam.id}/',
            data: data);
      } else {
        // Création (POST) si le paramètre n'existe pas
        response = await _apiService.authDio.post(
            '${ApiConstants.baseUrl}/utilisateurs/me/parametres/create/',
            data: data);
      }

      final updatedParam = ParametreUtilisateur.fromJson(response.data);
      _parametres[cle] = updatedParam;
    } on DioException catch (e) {
      _error = 'Échec de la mise à jour du paramètre $cle: ${e.response?.data}';
      // Re-charger en cas d'échec pour récupérer l'état réel du backend
      fetchParametres();
    } catch (e) {
      _error = 'Erreur inattendue lors de la mise à jour: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // À appeler lors de la déconnexion
  void clearState() {
    _parametres = {};
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
