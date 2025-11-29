// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medishop/models/stock.dart';
import 'package:medishop/models/medicament.dart';
import 'package:medishop/providers/auth_provider.dart';

// Screens Auth
import 'package:medishop/screens/auth/login_screen.dart';
import 'package:medishop/screens/auth/register_screen.dart';
import 'package:medishop/screens/pharmacie/pharmacie_add_screen.dart';
import 'package:medishop/screens/shared/parametres_screen.dart';
import 'package:medishop/screens/shared/notification_screen.dart';
import 'package:medishop/screens/shared/order_detail_screen.dart';

// Client
import 'package:medishop/screens/client/client_home.dart';
import 'package:medishop/screens/client/panier_screen.dart';
import 'package:medishop/screens/client/checkout_screen.dart';
import 'package:medishop/screens/client/commands_history_screen.dart';

// Pharmacie
import 'package:medishop/screens/pharmacie/pharmacie_dashboard.dart';
import 'package:medishop/screens/pharmacie/pharmacie_screen.dart';
import 'package:medishop/screens/pharmacie/stock_management_screen.dart';
import 'package:medishop/screens/pharmacie/stock_add_edit_screen.dart';
import 'package:medishop/screens/pharmacie/medicament_list_screen.dart';
import 'package:medishop/screens/pharmacie/medicament_add_edit_screen.dart';
import 'package:medishop/screens/pharmacie/medicament_detail_screen.dart';

// Livreur
import 'package:medishop/screens/livreur/livreur_home.dart';
import 'package:medishop/screens/livreur/delivery_map_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoading = authProvider.isLoading;
        final isAuthenticated = authProvider.isAuthenticated;

        if (isLoading)
          return state.matchedLocation == '/splash' ? null : '/splash';
        if (!isAuthenticated) {
          final isAuthRoute =
              ['/login', '/register'].contains(state.matchedLocation);
          return isAuthRoute ? null : '/login';
        }

        final homeRoute = authProvider.getHomeRoute();
        if (state.matchedLocation == '/splash' ||
            state.matchedLocation == '/') {
          return homeRoute;
        }
        return null;
      },
      routes: [
        // Splash & Auth
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

        // Notifications et Paramètres (global)
        GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationScreen()),
        GoRoute(
            path: '/parametres', builder: (_, __) => const ParametresScreen()),

        // Commandes globales
        GoRoute(
          path: '/orders/:commandeId',
          builder: (context, state) {
            final id =
                int.tryParse(state.pathParameters['commandeId'] ?? '0') ?? 0;
            if (id == 0)
              return const Scaffold(
                  body: Center(child: Text("Commande ID non valide.")));
            return OrderDetailScreen(commandeId: id);
          },
        ),

        // Client
        GoRoute(
          path: '/client/home',
          builder: (_, __) => const ClientHome(),
          routes: [
            GoRoute(path: 'panier', builder: (_, __) => const PanierScreen()),
            GoRoute(
                path: 'checkout', builder: (_, __) => const CheckoutScreen()),
            GoRoute(
                path: 'history',
                builder: (_, __) => const CommandsHistoryScreen()),
          ],
        ),

        // Pharmacie Dashboard
        GoRoute(
          path: '/pharmacie/dashboard',
          builder: (_, __) => const PharmacieDashboard(),
          routes: [
            GoRoute(
                path: 'pharmacie', builder: (_, __) => const PharmacieScreen()),

            // Stock
            GoRoute(
              path: 'stock',
              builder: (_, __) => const StockManagementScreen(),
              routes: [
                GoRoute(
                    path: 'add',
                    builder: (_, __) => const StockAddEditScreen()),
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final stockToEdit = state.extra as Stock?;
                    return StockAddEditScreen(stockToEdit: stockToEdit);
                  },
                ),
              ],
            ),

            // Médicaments
            GoRoute(
              path: 'medicaments',
              builder: (_, __) => const MedicamentListScreen(),
              routes: [
                GoRoute(
                    path: 'add',
                    builder: (_, __) => const MedicamentAddEditScreen()),
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final med = state.extra as Medicament?;
                    if (med == null)
                      return const Scaffold(
                          body: Center(
                              child: Text("Erreur: Médicament non spécifié.")));
                    return MedicamentAddEditScreen(medicamentToEdit: med);
                  },
                ),
                GoRoute(
                  path: 'details/:id',
                  builder: (context, state) => MedicamentDetailScreen(
                    medicamentId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),

            // Commandes Pharmacie
            GoRoute(
              path: 'commandes',
              builder: (_, __) => const Scaffold(
                body: Center(child: Text("Gestion des Commandes Pharmacie")),
              ),
            ),

            // Paramètres et Notifications (depuis Dashboard)
            GoRoute(
                path: 'parametres',
                builder: (_, __) => const ParametresScreen()),
            GoRoute(
                path: 'notifications',
                builder: (_, __) => const NotificationScreen()),
          ],
        ),

        // Ajouter une pharmacie
        GoRoute(
            path: '/pharmacie/add',
            builder: (_, __) => const PharmacieAddScreen()),

        // Livreur
        GoRoute(
          path: '/livreur/home',
          builder: (_, __) => const LivreurHome(),
          routes: [
            GoRoute(
              path: 'map/:commandeId',
              builder: (context, state) {
                final id =
                    int.tryParse(state.pathParameters['commandeId'] ?? '0') ??
                        0;
                if (id == 0)
                  return const Scaffold(
                      body: Center(child: Text("Commande ID non valide.")));
                return DeliveryMapScreen(commandeId: id);
              },
            ),
          ],
        ),
      ],
    );
  }
}

// SplashScreen pour initialisation
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Chargement...")));
}
