// lib/screens/livreur/livreur_home.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/auth_provider.dart';
import 'package:medishop/providers/delivery_provider.dart';
import 'package:medishop/models/commande.dart';

// --- Constantes de Style ---
const Color _kDeliveryColor = Colors.indigo;
const Color _kAvailableColor = Colors.orange;

class LivreurHome extends StatelessWidget {
  const LivreurHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Vérification de sécurité (peut être activée si la vérification de type est stricte)
    /*
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.userType != UserType.LIVREUR) {
      context.go('/login');
      return const SizedBox.shrink();
    }
    */

    // Initialise les chargements des livraisons
    Future.microtask(() {
      final provider = Provider.of<DeliveryProvider>(context, listen: false);
      // Nous ne forçons pas le rafraîchissement au démarrage pour laisser le Provider gérer la mise en cache
      provider.fetchAvailableDeliveries();
      provider.fetchMyDeliveries();
    });

    return DefaultTabController(
      length: 2, // Onglets : Disponibles et Mes Livraisons
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MediShop - Livreur',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: _kDeliveryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Déconnexion',
              onPressed: () async {
                Provider.of<DeliveryProvider>(context, listen: false)
                    .clearDeliveries();
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();
                context.go('/login');
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: 'Disponibles'),
              Tab(icon: Icon(Icons.delivery_dining), text: 'Mes Livraisons'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Onglet 1: Commandes à accepter
            AvailableDeliveriesScreen(),

            // Onglet 2: Commandes en cours
            MyDeliveriesScreen(),

            // NOTE IMPORTANTE: L'écran ProfileScreen a été retiré car il y avait une
            // incohérence avec la TabBarView (2 tabs vs 3 enfants).
          ],
        ),
      ),
    );
  }
}

// --- Écrans d'Onglets ---

/// 1. Écran : Commandes Disponibles (À ACCEPTER)
class AvailableDeliveriesScreen extends StatelessWidget {
  const AvailableDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeliveryProvider>(context);

    if (provider.isLoading && provider.availableDeliveries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.availableDeliveries.isEmpty) {
      return _buildEmptyState(
        'Aucune nouvelle livraison disponible à accepter pour l\'instant.',
        Icons.local_shipping_outlined,
        _kAvailableColor,
        () => provider.fetchAvailableDeliveries(forceRefresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchAvailableDeliveries(forceRefresh: true),
      child: ListView.builder(
        itemCount: provider.availableDeliveries.length,
        itemBuilder: (context, index) {
          final commande = provider.availableDeliveries[index];
          return _buildDeliveryCard(
            context,
            commande,
            cardColor: Colors.white,
            // Action principale: Accepter
            mainAction: ElevatedButton.icon(
              icon: const Icon(Icons.thumb_up_alt),
              label: const Text('ACCEPTER'),
              onPressed: () async {
                await _handleAccept(context, provider, commande.id);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _kAvailableColor,
                  foregroundColor: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

/// 2. Écran : Mes Livraisons (EN COURS)
class MyDeliveriesScreen extends StatelessWidget {
  const MyDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeliveryProvider>(context);

    if (provider.isLoading && provider.myDeliveries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.myDeliveries.isEmpty) {
      return _buildEmptyState(
        'Vous n\'avez pas de livraison en cours.',
        Icons.pedal_bike,
        _kDeliveryColor,
        () => provider.fetchMyDeliveries(forceRefresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchMyDeliveries(forceRefresh: true),
      child: ListView.builder(
        itemCount: provider.myDeliveries.length,
        itemBuilder: (context, index) {
          final commande = provider.myDeliveries[index];

          // Actionnable si elle est prête à être livrée ou déjà en cours de route
          final bool isActionable = commande.statutCommande == 'EN_LIVRAISON' ||
              commande.statutCommande == 'PRET_LIVRAISON';

          return _buildDeliveryCard(
            context,
            commande,
            cardColor: isActionable ? Colors.lightBlue.shade50 : Colors.white,
            // Actions multiples
            mainAction: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Bouton Détails (Partagé: /orders/:id)
                TextButton.icon(
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Détails'),
                    onPressed: () => context.go('/orders/${commande.id}')),

                const SizedBox(width: 8),

                // Bouton Carte/Livrer
                if (isActionable)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('Livrer'),
                    onPressed: () {
                      context.go('/livreur/home/map/${commande.id}');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _kDeliveryColor,
                        foregroundColor: Colors.white),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- Widgets et Fonctions Partagés ---

Widget _buildEmptyState(
    String message, IconData icon, Color color, VoidCallback onRefresh) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: color.withOpacity(0.6)),
        const SizedBox(height: 16),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black54)),
        TextButton.icon(
          icon: Icon(Icons.refresh, color: color),
          label: Text("Actualiser", style: TextStyle(color: color)),
          onPressed: onRefresh,
        ),
      ],
    ),
  );
}

Widget _buildStatusChip(String status) {
  Color color;
  String text;
  switch (status) {
    case 'EN_ATTENTE':
      color = Colors.blueGrey;
      text = 'Nouvelle';
      break;
    case 'PRET_LIVRAISON':
      color = Colors.orange;
      text = 'Prête à Enlever';
      break;
    case 'EN_LIVRAISON':
      color = Colors.indigo;
      text = 'En Cours';
      break;
    default:
      color = Colors.grey;
      text = status.replaceAll('_', ' ');
  }
  return Chip(
    label:
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    backgroundColor: color,
    visualDensity: VisualDensity.compact,
  );
}

Widget _buildDeliveryCard(BuildContext context, Commande commande,
    {required Widget mainAction, required Color cardColor}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    elevation: 4,
    color: cardColor,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${commande.id}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _kDeliveryColor),
              ),
              _buildStatusChip(commande.statutCommande),
            ],
          ),
          const Divider(height: 15),

          _buildInfoRow(
              Icons.location_on, 'Adresse', commande.adresseLivraison),
          _buildInfoRow(Icons.local_pharmacy, 'Pharmacie', commande.pharmacie),
          // Supposons que le modèle Commande inclut 'clientName'
          // _buildInfoRow(Icons.person, 'Client', commande.clientName),

          _buildInfoRow(
              Icons.attach_money,
              'Total',
              '${commande.totalMontant.toStringAsFixed(2)} DH',
              Colors.green.shade700),

          const SizedBox(height: 15),
          // Affiche l'action principale (bouton Accepter ou Row de boutons pour la livraison)
          mainAction,
        ],
      ),
    ),
  );
}

Widget _buildInfoRow(IconData icon, String label, String value,
    [Color? color]) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Expanded(
            child: Text(value,
                style:
                    TextStyle(fontSize: 14, color: color ?? Colors.black87))),
      ],
    ),
  );
}

Future<void> _handleAccept(
    BuildContext context, DeliveryProvider provider, int commandeId) async {
  try {
    // Afficher un indicateur de chargement léger
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Acceptation en cours...')),
    );

    await provider.acceptDelivery(commandeId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Livraison acceptée! Rendez-vous à la pharmacie.')),
    );
    // Changer d'onglet vers "Mes Livraisons" (index 1)
    DefaultTabController.of(context).animateTo(1);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.red,
          content:
              Text('Erreur: ${e.toString().replaceFirst('Exception: ', '')}')),
    );
  }
}
