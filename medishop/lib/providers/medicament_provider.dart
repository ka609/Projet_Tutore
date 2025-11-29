import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:medishop/models/medicament.dart';
import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';

class MedicamentProvider with ChangeNotifier {
  final ApiService _apiService;

  MedicamentProvider(this._apiService) {
    fetchAllMedicaments();
  }

  List<Medicament> _allMedicaments = [];
  List<Medicament> get allMedicaments => _allMedicaments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllMedicaments({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.authDio
          .get(ApiConstants.baseUrl + ApiConstants.medicamentsEndpoint);

      _allMedicaments = (response.data as List)
          .map((json) => Medicament.fromJson(json))
          .toList();
    } on DioException catch (e) {
      _errorMessage =
          'Erreur chargement médicaments: ${e.response?.statusCode}';
    } catch (e) {
      _errorMessage = 'Erreur inattendue: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Medicament> createMedicament({
    required String nomCommercial,
    String? nomScientifique,
    String? description,
    String? categorie,
    required bool necessitePrescription,
    required num price,
    File? photoFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nom_commercial': nomCommercial,
        'nom_scientifique': nomScientifique,
        'description': description,
        'categorie': categorie,
        'necessite_prescription': necessitePrescription,
        'price': price,
        if (photoFile != null)
          'photo': await MultipartFile.fromFile(
            photoFile.path,
            filename: photoFile.path.split('/').last,
          ),
      });

      final response = await _apiService.authDio.post(
        ApiConstants.baseUrl + ApiConstants.medicamentsEndpoint,
        data: formData,
      );

      final newMedicament = Medicament.fromJson(response.data);
      _allMedicaments.add(newMedicament);
      notifyListeners();
      return newMedicament;
    } on DioException catch (e) {
      final errorMsg = e.response?.data.toString() ?? 'Erreur API inconnue';
      throw Exception('Échec création médicament: $errorMsg');
    }
  }

  Future<void> updateMedicament(
    Medicament medicament, {
    required String nomCommercial,
    String? nomScientifique,
    String? description,
    String? categorie,
    required bool necessitePrescription,
    required num price,
    File? photoFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nom_commercial': nomCommercial,
        'nom_scientifique': nomScientifique,
        'description': description,
        'categorie': categorie,
        'necessite_prescription': necessitePrescription,
        if (photoFile != null)
          'photo': await MultipartFile.fromFile(
            photoFile.path,
            filename: photoFile.path.split('/').last,
          ),
      });

      final response = await _apiService.authDio.patch(
        '${ApiConstants.baseUrl}${ApiConstants.medicamentsEndpoint}${medicament.id}/',
        data: formData,
      );

      final updatedMedicament = Medicament.fromJson(response.data);
      final index = _allMedicaments.indexWhere((m) => m.id == medicament.id);
      if (index != -1) _allMedicaments[index] = updatedMedicament;
      notifyListeners();
    } on DioException catch (e) {
      final errorMsg = e.response?.data.toString() ?? 'Erreur API inconnue';
      throw Exception('Échec modification médicament: $errorMsg');
    }
  }
}
