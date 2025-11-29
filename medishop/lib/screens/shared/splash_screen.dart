// lib/screens/shared/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:medishop/providers/auth_provider.dart';
import 'package:medishop/providers/delivery_provider.dart'; // Pour le Livreur
import 'package:medishop/providers/stock_provider.dart'; // Pour la Pharmacie
import 'package:medishop/providers/user_settings_provider.dart'; // Pour les Paramètres
import 'package:medishop/models/user_type.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Lance la vérification et le chargement des données après le rendu initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  // --- Logique d'initialisation et de navigation ---
  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 1. Vérifier si un token existe et si l'utilisateur est déjà connecté
    final bool isAuthenticated = await authProvider.checkAuthenticationStatus();

    if (isAuthenticated) {
      // 2. L'utilisateur est connecté, charger les données spécifiques à son rôle
      await _loadRoleSpecificData(authProvider.userType);

      // 3. Charger les paramètres utilisateur pour tous les rôles
      await Provider.of<UserSettingsProvider>(context, listen: false)
          .fetchSettings();

      // 4. Naviguer vers l'écran d'accueil approprié
      String homePath = authProvider
          .getHomeRoute(); // Utilisation de la méthode dans AuthProvider

      // Utilisation de replace pour éviter le retour au Splash Screen
      context.go(homePath);
    } else {
      // 5. L'utilisateur n'est pas connecté, naviguer vers la page de connexion
      context.go('/login');
    }
  }

  // Fonction pour charger les données essentielles au démarrage selon le rôle
  Future<void> _loadRoleSpecificData(UserType userType) async {
    // Les autres providers (Panier, Commande, Notification) seront chargés
    // ou initialisés lors de la première interaction ou sur leur écran dédié.

    try {
      if (userType == UserType.PHARMACIE) {
        // Charger le stock de la pharmacie
        await Provider.of<StockProvider>(context, listen: false)
            .fetchAvailableStock(forceRefresh: true);
        // On pourrait aussi charger les commandes en attente ici.
      } else if (userType == UserType.LIVREUR) {
        // Charger les livraisons disponibles et mes livraisons
        final deliveryProvider =
            Provider.of<DeliveryProvider>(context, listen: false);
        await deliveryProvider.fetchAvailableDeliveries(forceRefresh: true);
        await deliveryProvider.fetchMyDeliveries(forceRefresh: true);
      }
      // Pour le Client, le catalogue sera chargé sur CatalogueScreen
    } catch (e) {
      // Gérer l'échec de chargement des données initiales (peut être ignoré ou logué)
      print('Erreur lors du chargement des données initiales: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ajouter votre logo ici
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text(
              'MediShop',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
