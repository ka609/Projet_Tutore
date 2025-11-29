// lib/providers/delivery_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/models/commande.dart'; // Nous utiliserons le modèle Commande

class DeliveryProvider with ChangeNotifier {
  final ApiService _apiService;

  // --- VARIABLES D'ÉTAT ---
  List<Commande> _availableDeliveries = []; // Commandes prêtes à être prises
  List<Commande> _myDeliveries = []; // Commandes acceptées par ce livreur
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS PUBLICS ---
  List<Commande> get availableDeliveries => _availableDeliveries;
  List<Commande> get myDeliveries => _myDeliveries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DeliveryProvider(this._apiService);

  // --- 1. CHARGER LES COMMANDES DISPONIBLES (Status: PRET_LIVRAISON) ---
  Future<void> fetchAvailableDeliveries({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Endpoint pour récupérer les commandes marquées comme prêtes par les pharmacies
      final response = await _apiService.authDio.get(
        ApiConstants.baseUrl + '/api/livreur/deliveries/available/',
      );

      final List<dynamic> jsonList = response.data;
      _availableDeliveries =
          jsonList.map((json) => Commande.fromJson(json)).toList();
    } on DioException catch (_) {
      _errorMessage = 'Échec du chargement des commandes disponibles.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. CHARGER MES LIVRAISONS (Commandes déjà acceptées) ---
  Future<void> fetchMyDeliveries({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Endpoint pour récupérer les commandes assignées à ce livreur
      final response = await _apiService.authDio.get(
        ApiConstants.baseUrl + '/api/livreur/deliveries/me/',
      );

      final List<dynamic> jsonList = response.data;
      _myDeliveries = jsonList.map((json) => Commande.fromJson(json)).toList();
    } on DioException catch (_) {
      _errorMessage = 'Échec du chargement de vos livraisons.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 3. ACCEPTER UNE COMMANDE ---
  Future<void> acceptDelivery(int commandeId) async {
    try {
      // Appel API pour assigner la commande au livreur actuel et changer le statut à EN_LIVRAISON
      await _apiService.authDio.post(
        ApiConstants.baseUrl + '/api/livreur/deliveries/$commandeId/accept/',
      );

      // Mettre à jour les états locaux après succès
      final acceptedItemIndex =
          _availableDeliveries.indexWhere((c) => c.id == commandeId);
      if (acceptedItemIndex != -1) {
        final acceptedItem = _availableDeliveries.removeAt(acceptedItemIndex);

        // Mettre à jour le statut dans l'objet Commande (simulation de la réponse API)
        final updatedCommande = Commande(
          id: acceptedItem.id,
          client: acceptedItem.client,
          pharmacie: acceptedItem.pharmacie,
          totalMontant: acceptedItem.totalMontant,
          statutCommande: 'EN_LIVRAISON',
          adresseLivraison: acceptedItem.adresseLivraison,
          dateCommande: acceptedItem.dateCommande,
          lignes: acceptedItem.lignes,
          // ... autres champs
        );
        _myDeliveries.add(updatedCommande);
        notifyListeners();
      }
    } on DioException catch (e) {
      String msg =
          'Impossible d\'accepter la commande. Elle a peut-être déjà été prise.';
      throw Exception(msg);
    }
  }

  // --- 4. METTRE À JOUR LE STATUT DE LIVRAISON (LIVREE ou ÉCHEC) ---
  Future<void> updateDeliveryStatus(int commandeId, String newStatus) async {
    // newStatus doit être 'LIVREE' ou 'ECHEC_LIVRAISON'
    if (newStatus != 'LIVREE' && newStatus != 'ECHEC_LIVRAISON') {
      throw ArgumentError('Statut de livraison non valide.');
    }

    try {
      // Appel API pour changer le statut
      await _apiService.authDio.patch(
        ApiConstants.baseUrl + '/api/livreur/deliveries/$commandeId/status/',
        data: {'statut': newStatus},
      );

      // Mettre à jour l'état local
      final index = _myDeliveries.indexWhere((c) => c.id == commandeId);
      if (index != -1) {
        final oldCommande = _myDeliveries[index];
        _myDeliveries.removeAt(index); // Retirer ou marquer comme terminé

        // Optionnel: On peut ne pas retirer l'objet si l'on veut un historique dans la même liste
        // Si on garde l'historique dans cette liste:
        _myDeliveries.insert(
            index,
            Commande(
              id: oldCommande.id,
              client: oldCommande.client,
              pharmacie: oldCommande.pharmacie,
              totalMontant: oldCommande.totalMontant,
              statutCommande: newStatus,
              adresseLivraison: oldCommande.adresseLivraison,
              dateCommande: oldCommande.dateCommande,
              lignes: oldCommande.lignes,
              // ... autres champs
            ));

        notifyListeners();
      }
    } on DioException catch (e) {
      String msg = 'Échec de la mise à jour du statut.';
      throw Exception(msg);
    }
  }

  // --- 5. Vider l'état (lors de la déconnexion) ---
  void clearDeliveries() {
    _availableDeliveries.clear();
    _myDeliveries.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
