// lib/screens/pharmacie/orders_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:medishop/providers/commande_provider.dart';
import 'package:medishop/models/commande.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  // Liste des statuts possibles (doit correspondre aux valeurs de votre API Django)
  final List<String> statusList = [
    'EN_ATTENTE',
    'ACCEPTEE',
    'EN_PREPARATION',
    'PRET_LIVRAISON',
    'EN_LIVRAISON',
    'LIVREE',
    'ANNULEE'
  ];

  @override
  void initState() {
    super.initState();
    // Charger les commandes spécifiques à cette pharmacie au démarrage
    Future.microtask(() => Provider.of<CommandeProvider>(context, listen: false)
        .fetchPharmacyOrders());
  }

  @override
  Widget build(BuildContext context) {
    final commandeProvider = Provider.of<CommandeProvider>(context);

    return Scaffold(
      body: commandeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : commandeProvider.pharmacyOrders.isEmpty
              ? _buildEmptyOrders()
              : RefreshIndicator(
                  onRefresh: () =>
                      commandeProvider.fetchPharmacyOrders(forceRefresh: true),
                  child: ListView.builder(
                    itemCount: commandeProvider.pharmacyOrders.length,
                    itemBuilder: (context, index) {
                      final commande = commandeProvider.pharmacyOrders[index];
                      return _buildOrderCard(
                          context, commande, commandeProvider);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Aucune commande en attente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Actualiser"),
            onPressed: () =>
                Provider.of<CommandeProvider>(context, listen: false)
                    .fetchPharmacyOrders(forceRefresh: true),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, Commande commande, CommandeProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre & ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${commande.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal),
                ),
                Text(
                  commande.dateCommande.toString().split(' ')[0],
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(),

            // Statut actuel
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 18),
                const SizedBox(width: 8),
                Text('Statut actuel: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  commande.statutCommande,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(commande.statutCommande),
                  ),
                ),
              ],
            ),

            // Détails
            Text('Total: ${commande.totalMontant.toStringAsFixed(2)} DH'),
            Text('Adresse: ${commande.adresseLivraison}'),

            // Sélecteur de Statut (Dropdown)
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mettre à jour le statut:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                DropdownButton<String>(
                  value: commande.statutCommande,
                  items: statusList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newStatus) {
                    if (newStatus != null &&
                        newStatus != commande.statutCommande) {
                      provider.updateCommandeStatus(commande.id, newStatus);
                    }
                  },
                ),
              ],
            ),

            // TODO: Ajouter un bouton pour voir les articles de la commande (détails)
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'ACCEPTEE':
      case 'EN_PREPARATION':
        return Colors.blue;
      case 'PRET_LIVRAISON':
      case 'EN_LIVRAISON':
        return Colors.amber.shade700;
      case 'LIVREE':
        return Colors.green;
      case 'ANNULEE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
