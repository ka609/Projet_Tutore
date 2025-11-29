import 'package:flutter/material.dart';
import 'package:medishop/models/pharmacie.dart';
import 'package:dio/dio.dart';
import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';

class PharmacieProvider with ChangeNotifier {
  final ApiService apiService;

  PharmacieProvider(this.apiService);

  List<Pharmacie> _myPharmacies = [];
  List<Pharmacie> get myPharmacies => _myPharmacies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get hasAnyPharmacy => _myPharmacies.isNotEmpty;

  Future<void> fetchMyPharmacies({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.authDio.get(
        ApiConstants.baseUrl + ApiConstants.myPharmaciesEndpoint,
      );

      if (response.statusCode == 200 && response.data is List) {
        _myPharmacies = (response.data as List)
            .map((json) => Pharmacie.fromJson(json))
            .toList();
      } else {
        _myPharmacies = [];
      }
    } on DioException catch (e) {
      print('Erreur Dio: ${e.response?.statusCode}');
      _myPharmacies = [];
    } catch (e) {
      print('Erreur inattendue: $e');
      _myPharmacies = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPharmacie({
    required String nom,
    required String licenceNumero,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = {
        'nom_pharmacie': nom,
        'licence_numero': licenceNumero,
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await apiService.authDio.post(
        ApiConstants.baseUrl + ApiConstants.createPharmacieEndpoint,
        data: data,
      );

      final newPharmacie = Pharmacie.fromJson(response.data);
      _myPharmacies.add(newPharmacie);
      notifyListeners();
    } on DioException catch (e) {
      final msg = e.response?.data.toString() ?? 'Erreur API';
      throw Exception("Échec création pharmacie: $msg");
    } catch (e) {
      throw Exception("Erreur interne: $e");
    }
  }
}
