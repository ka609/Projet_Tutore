import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/models/commande.dart';

// Énumération des méthodes de paiement supportées
enum PaymentMethod { carteBancaire, virement, paiementLivraison }

class PaymentProvider with ChangeNotifier {
  final ApiService _apiService;

  // État du paiement
  bool _isProcessingPayment = false;
  String? _paymentError;

  bool get isProcessingPayment => _isProcessingPayment;
  String? get paymentError => _paymentError;

  PaymentProvider(this._apiService);

  // --- 1. SOUMETTRE UN PAIEMENT ---
  Future<Commande> submitPayment({
    required int commandeId,
    required PaymentMethod method,
    String? cardToken, // Jeton sécurisé si carte bancaire
    double montant = 0.0, // Montant total
  }) async {
    _isProcessingPayment = true;
    _paymentError = null;
    notifyListeners();

    String paymentType = method.toString().split('.').last.toUpperCase();

    // Payload
    Map<String, dynamic> data = {
      'commande_id': commandeId,
      'montant': montant,
      'methode': paymentType,
    };

    if (method == PaymentMethod.carteBancaire && cardToken != null) {
      data['card_token'] = cardToken;
    }

    try {
      final response = await _apiService.authDio.post(
        '${ApiConstants.baseUrl}/paiements/submit/',
        data: data,
      );

      _isProcessingPayment = false;
      notifyListeners();

      // Retourner la commande mise à jour
      return Commande.fromJson(response.data);
    } on DioException catch (e) {
      _paymentError = 'Échec du paiement.';

      // Récupérer un message d'erreur plus précis si disponible
      if (e.response?.data is Map) {
        final data = e.response!.data;
        if (data.containsKey('detail')) _paymentError = data['detail'];
        if (data.containsKey('message')) _paymentError = data['message'];
        if (data.containsKey('error')) _paymentError = data['error'];
        if (data.containsKey('non_field_errors')) {
          _paymentError = (data['non_field_errors'] as List).join(', ');
        }
      }

      _isProcessingPayment = false;
      notifyListeners();
      throw Exception(_paymentError);
    } catch (e) {
      _paymentError = 'Erreur inattendue lors de la soumission du paiement.';
      _isProcessingPayment = false;
      notifyListeners();
      throw Exception(_paymentError);
    }
  }

  // --- 2. Vider l'état (lors de la déconnexion) ---
  void clearState() {
    _paymentError = null;
    _isProcessingPayment = false;
    notifyListeners();
  }
}
