// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api_service/api_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/parametre_utilisateur_provider.dart';
import 'providers/stock_provider.dart';
import 'providers/panier_provider.dart';
import 'providers/commande_provider.dart';
import 'providers/delivery_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/prescription_provider.dart';
import 'providers/user_settings_provider.dart';
import 'providers/pharmacie_provider.dart';
import 'providers/medicament_provider.dart';

// Router
import 'router/app_router.dart';

void main() {
  final apiService = ApiService();

  final panierProvider = PanierProvider();
  final paymentProvider = PaymentProvider(apiService);
  final notificationProvider = NotificationProvider(apiService);
  final prescriptionProvider = PrescriptionProvider(apiService);
  final userSettingsProvider = UserSettingsProvider(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService),
        ),

        ChangeNotifierProvider(
          create: (_) => StockProvider(apiService)..fetchAvailableStock(),
        ),

        ChangeNotifierProvider.value(value: panierProvider),

        ChangeNotifierProvider(
          create: (_) => CommandeProvider(apiService, panierProvider),
        ),

        ChangeNotifierProvider(
          create: (_) => DeliveryProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => ParametreUtilisateurProvider(apiService),
        ),

        ChangeNotifierProvider.value(value: paymentProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: prescriptionProvider),
        ChangeNotifierProvider.value(value: userSettingsProvider),

        // 🔵 PharmacieProvider CORRIGÉ
        ChangeNotifierProvider(
          create: (_) => PharmacieProvider(apiService),
        ),

        ChangeNotifierProvider(
          create: (_) => MedicamentProvider(apiService),
        ),
      ],
      child: const MediShopApp(),
    ),
  );
}

class MediShopApp extends StatelessWidget {
  const MediShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final router = AppRouter.router(authProvider);

    return MaterialApp.router(
      title: 'MediShop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: router,
    );
  }
}
