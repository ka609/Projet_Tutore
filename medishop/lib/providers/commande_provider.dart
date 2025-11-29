// lib/providers/commande_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/providers/panier_provider.dart';
import 'package:medishop/models/commande.dart';

class CommandeProvider with ChangeNotifier {
  final ApiService _apiService;
  final PanierProvider _panierProvider;

  // --- VARIABLES CLIENT ---
  List<Commande> _commandes = [];

  // --- VARIABLES PHARMACIE ---
  List<Commande> _pharmacyOrders = [];

  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS ---
  List<Commande> get commandes => _commandes;
  List<Commande> get pharmacyOrders => _pharmacyOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CommandeProvider(this._apiService, this._panierProvider);

  // -----------------------------------------------------
  // 1. CRÉER UNE COMMANDE (CLIENT) + RETOURNER L'OBJET
  // -----------------------------------------------------
  Future<Commande> createCommande(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.authDio.post(
        '${ApiConstants.baseUrl}/commandes/',
        data: data,
      );

      final createdCommande = Commande.fromJson(response.data);

      // Ajouter à la liste locale
      _commandes.add(createdCommande);

      // Vider le panier
      _panierProvider.clearPanier();

      notifyListeners();

      return createdCommande;
    } on DioException catch (_) {
      _errorMessage = 'Impossible de créer la commande.';
      notifyListeners();
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------
  // 2. HISTORIQUE CLIENT AVEC forceRefresh
  // -----------------------------------------------------
  Future<void> fetchCommandesHistory({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.authDio.get(
        '${ApiConstants.baseUrl}/commandes/',
      );

      final List<dynamic> jsonList = response.data;
      _commandes = jsonList.map((e) => Commande.fromJson(e)).toList();
    } on DioException catch (_) {
      _errorMessage = "Erreur lors du chargement de l’historique.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------
  // 3. COMMANDES POUR LE PHARMACIEN AVEC forceRefresh
  // -----------------------------------------------------
  Future<void> fetchPharmacyOrders({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.authDio.get(
        '${ApiConstants.baseUrl}/pharmacie/commandes/',
      );

      final List<dynamic> commandesJson = response.data;

      _pharmacyOrders =
          commandesJson.map((json) => Commande.fromJson(json)).toList();
    } on DioException catch (_) {
      _errorMessage = 'Erreur lors du chargement des commandes.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Commande?> fetchCommandeById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.authDio.get(
        '${ApiConstants.baseUrl}/commandes/$id/',
      );

      return Commande.fromJson(response.data);
    } on DioException catch (_) {
      _errorMessage = "Erreur lors du chargement de la commande.";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. METTRE À JOUR LE STATUT D'UNE COMMANDE (PHARMACIE)
  Future<void> updateCommandeStatus(int commandeId, String newStatus) async {
    final index = _pharmacyOrders.indexWhere((c) => c.id == commandeId);
    if (index == -1) return;

    final oldCommande = _pharmacyOrders[index];

    // Création d'une copie modifiée
    final updatedCommande = Commande(
      id: oldCommande.id,
      client: oldCommande.client,
      pharmacie: oldCommande.pharmacie,
      totalMontant: oldCommande.totalMontant,
      statutCommande: newStatus,
      adresseLivraison: oldCommande.adresseLivraison,
      dateCommande: oldCommande.dateCommande,
      lignes: oldCommande.lignes,
    );

    // Mise à jour optimiste
    _pharmacyOrders[index] = updatedCommande;
    notifyListeners();

    try {
      await _apiService.authDio.patch(
        '${ApiConstants.baseUrl}/commandes/$commandeId/status/',
        data: {'statut': newStatus},
      );
    } on DioException catch (_) {
      // Annuler la modification locale
      _pharmacyOrders[index] = oldCommande;
      notifyListeners();
      throw Exception("Erreur mise à jour statut commande.");
    }
  }
}
