// lib/providers/prescription_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/models/prescription.dart';

class PrescriptionProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Prescription> _userPrescriptions = [];
  bool _isLoading = false;
  String? _error;

  List<Prescription> get userPrescriptions => _userPrescriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PrescriptionProvider(this._apiService);

  // --- 1. SOUMISSION D'UNE NOUVELLE PRESCRIPTION (CLIENT) ---
  // Prend le chemin du fichier local à envoyer à l'API.
  Future<void> uploadPrescription({required String filePath}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String fileName = filePath.split('/').last;

      // Simule l'envoi d'un fichier multipart
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiService.authDio.post(
        ApiConstants.baseUrl + '/api/prescriptions/upload/',
        data: formData,
      );

      final newPrescription = Prescription.fromJson(response.data);
      _userPrescriptions.insert(0, newPrescription);

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = 'Échec de l\'envoi de l\'ordonnance: API ou fichier invalide.';
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    } catch (e) {
      _error = 'Erreur inattendue lors de l\'envoi.';
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  // --- 2. RÉCUPÉRATION DES PRESCRIPTIONS DE L'UTILISATEUR ---
  Future<void> fetchUserPrescriptions({bool forceRefresh = false}) async {
    if (_userPrescriptions.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.authDio.get(
        ApiConstants.baseUrl + '/api/prescriptions/me/',
      );

      _userPrescriptions = (response.data as List)
          .map((json) => Prescription.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = 'Impossible de récupérer l\'historique des ordonnances.';
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  // --- 3. TÉLÉCHARGEMENT/AFFICHAGE DU FICHIER DE PRESCRIPTION (Optionnel) ---
  // Cette fonction simule l'action d'ouvrir le fichier depuis l'URL.
  Future<void> downloadPrescriptionFile(String fileUrl) async {
    if (fileUrl.isEmpty) {
      throw Exception("URL du fichier de prescription invalide.");
    }

    // Dans une application réelle, vous utiliseriez 'url_launcher' ou 'path_provider'
    // pour télécharger le fichier ou l'ouvrir dans un navigateur/lecteur PDF.
    print(
        'Tentative de téléchargement/ouverture du fichier à l\'URL: $fileUrl');
    // Exemple simulé de lancement:
    // await launchUrl(Uri.parse(fileUrl));
  }

  // Vider l'état (lors de la déconnexion)
  void clearState() {
    _userPrescriptions = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
