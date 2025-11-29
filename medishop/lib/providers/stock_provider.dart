// lib/providers/stock_provider.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/models/stock.dart';
import 'package:medishop/models/medicament.dart';

class StockProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Stock> _availableStock = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  StockProvider(this._apiService);

  // Getters pour accéder à l'état
  List<Stock> get availableStock => _availableStock;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // Propriété calculée : la liste de stocks filtrée par la requête de recherche
  List<Stock> get filteredStock {
    if (_searchQuery.isEmpty) {
      return _availableStock;
    }
    final query = _searchQuery.toLowerCase();

    return _availableStock.where((stock) {
      final medicament = stock.medicament;
      // Filtrer par nom commercial, nom scientifique, ou catégorie
      return medicament.nomCommercial.toLowerCase().contains(query) ||
          (medicament.nomScientifique?.toLowerCase().contains(query) ??
              false) ||
          (medicament.categorie?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Méthode pour mettre à jour la requête de recherche
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // --- Chargement des Stocks depuis l'API (Utilisé par le Client et le Pharmacien) ---
  Future<void> fetchAvailableStock({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Appel via l'instance sécurisée authDio
      final response = await _apiService.authDio.get(
        ApiConstants.availableStockEndpoint,
      );

      final List<dynamic> stockJson = response.data;

      // Mappage des données JSON vers la liste de modèles Stock
      _availableStock = stockJson.map((json) => Stock.fromJson(json)).toList();
    } on DioException catch (e) {
      _errorMessage =
          'Échec du chargement du catalogue. Code: ${e.response?.statusCode}';
    } catch (e) {
      _errorMessage = 'Une erreur inattendue est survenue.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Récupérer les Détails d'un Article de Stock (basé sur l'ID du Médicament) ---
  Future<Stock> fetchStockItemDetail(int medicamentId) async {
    // 1. Tenter de trouver l'article de stock localement
    try {
      return _availableStock
          .firstWhere((stock) => stock.medicament.id == medicamentId);
    } catch (_) {
      // 2. Si non trouvé localement, charger depuis l'API.
      try {
        final endpoint = '${ApiConstants.baseUrl}/stock/$medicamentId/';
        final response = await _apiService.authDio.get(endpoint);
        return Stock.fromJson(response.data);
      } on DioException catch (e) {
        _errorMessage =
            'Échec du chargement du détail du médicament. Code: ${e.response?.statusCode}';
        notifyListeners();
        throw Exception(_errorMessage);
      }
    }
  }

  // ------------------------------------------------------------------
  // --- MÉTHODES PHARMACIEN : AJOUT & MODIFICATION ---
  // ------------------------------------------------------------------

  Future<void> addOrUpdateStock({
    required int medicamentId,
    required int quantite,
    required double prixUnitaire,
    int? stockId, // Si présent, c'est une modification
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint = stockId == null
          ? '${ApiConstants.baseUrl}/pharmacie/stock/create/'
          : '${ApiConstants.baseUrl}/pharmacie/stock/$stockId/update/';

      final data = {
        'medicament_id': medicamentId,
        'quantite': quantite,
        'prix_unitaire': prixUnitaire,
      };

      final response = stockId == null
          ? await _apiService.authDio.post(endpoint, data: data)
          : await _apiService.authDio.patch(endpoint, data: data);

      final newStockItem = Stock.fromJson(response.data);

      // Mise à jour de la liste locale
      if (stockId == null) {
        _availableStock.add(newStockItem);
      } else {
        final index = _availableStock.indexWhere((s) => s.id == stockId);
        if (index != -1) {
          _availableStock[index] = newStockItem;
        }
      }

      await fetchAvailableStock(forceRefresh: true);
    } on DioException catch (e) {
      _errorMessage =
          'Échec de l\'opération de stock: ${e.response?.data.toString()}';
      notifyListeners();
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Recherche de Médicaments (pour le formulaire d'ajout) ---
  Future<List<Medicament>> searchMedicaments(String query) async {
    if (query.length < 3) return [];

    try {
      final response = await _apiService.authDio
          .get('${ApiConstants.baseUrl}/medicaments/search/?q=$query');
      return (response.data as List)
          .map((json) => Medicament.fromJson(json))
          .toList();
    } on DioException catch (e) {
      // Gérer les erreurs de recherche séparément
      print('Erreur de recherche de médicaments: $e');
      return [];
    }
  }
}
