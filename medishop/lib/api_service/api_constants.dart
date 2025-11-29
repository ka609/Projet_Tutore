// lib/api_service/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // --- JWT ---
  static const String tokenEndpoint = '/token/';
  static const String tokenRefreshEndpoint = '/token/refresh/';

  // --- Stock ---
  static const String availableStockEndpoint = '/stocks/available/';

  // --- Profil utilisateur (via /utilisateurs/me/) ---
  static const String userMeEndpoint = '/utilisateurs/me/';

  static const String commandesEndpoint = '/commandes/';
  // --- Pharmacie ---
  static const String myPharmaciesEndpoint = '/pharmacies/my/';
  static const String createPharmacieEndpoint = '/pharmacies/create/';
  // --- Médicaments ---
  static const String medicamentsEndpoint = '/medicaments/';
}
