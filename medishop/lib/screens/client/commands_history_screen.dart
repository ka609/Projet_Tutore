// lib/screens/client/commands_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:medishop/providers/commande_provider.dart';
import 'package:medishop/models/commande.dart';

class CommandsHistoryScreen extends StatefulWidget {
  const CommandsHistoryScreen({super.key});

  @override
  State<CommandsHistoryScreen> createState() => _CommandsHistoryScreenState();
}

class _CommandsHistoryScreenState extends State<CommandsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Charger l'historique des commandes au démarrage de l'onglet
    Future.microtask(() => Provider.of<CommandeProvider>(context, listen: false)
        .fetchCommandesHistory());
  }

  @override
  Widget build(BuildContext context) {
    final commandeProvider = Provider.of<CommandeProvider>(context);

    return Scaffold(
      // Utilisation d'un RefreshIndicator pour actualiser l'historique
      body: commandeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : commandeProvider.commandes.isEmpty
              ? _buildEmptyHistory()
              : RefreshIndicator(
                  onRefresh: () => commandeProvider.fetchCommandesHistory(
                      forceRefresh: true),
                  child: ListView.builder(
                    itemCount: commandeProvider.commandes.length,
                    itemBuilder: (context, index) {
                      final commande = commandeProvider.commandes[index];
                      return _buildOrderTile(context, commande);
                    },
                  ),
                ),
    );
  }

  // Widget affichant un message si l'historique est vide
  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history, size: 80, color: Colors.blueGrey),
          SizedBox(height: 16),
          Text(
            "Aucune commande passée pour l'instant.",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Text("Faites votre premier achat sur le catalogue !"),
        ],
      ),
    );
  }

  // Widget affichant une carte pour chaque commande
  Widget _buildOrderTile(BuildContext context, Commande commande) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          _getStatusIcon(commande.statutCommande),
          color: _getStatusColor(commande.statutCommande),
        ),
        title: Text(
          'Commande #${commande.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${commande.dateCommande.toString().split('T')[0]}'),
            Text('Statut: ${_getTranslatedStatus(commande.statutCommande)}'),
            Text('Livraison à: ${commande.adresseLivraison}'),
          ],
        ),
        trailing: Text(
          '${commande.totalMontant.toStringAsFixed(2)} DH',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
        ),
        onTap: () {
          // TODO: Ouvrir un écran de détails de la commande pour voir la liste des articles
          _showOrderDetails(context, commande);
        },
      ),
    );
  }

  // --- Fonctions d'aide pour l'affichage ---

  // Traduire le statut de l'API en une chaîne lisible (en français)
  String _getTranslatedStatus(String status) {
    switch (status) {
      case 'EN_ATTENTE':
        return 'En Attente de Confirmation';
      case 'ACCEPTEE':
        return 'Confirmée et en Cours';
      case 'EN_PREPARATION':
        return 'En Préparation';
      case 'PRET_LIVRAISON':
        return 'Prête pour la Livraison';
      case 'EN_LIVRAISON':
        return 'En Cours de Livraison';
      case 'LIVREE':
        return 'Livrée';
      case 'ANNULEE':
        return 'Annulée';
      default:
        return 'Statut Inconnu';
    }
  }

  // Déterminer la couleur du statut
  Color _getStatusColor(String status) {
    switch (status) {
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'ACCEPTEE':
      case 'EN_PREPARATION':
      case 'PRET_LIVRAISON':
        return Colors.blue;
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

  // Déterminer l'icône du statut
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'EN_ATTENTE':
        return Icons.access_time;
      case 'ACCEPTEE':
        return Icons.check_circle_outline;
      case 'EN_PREPARATION':
        return Icons.medical_services;
      case 'PRET_LIVRAISON':
        return Icons.inventory;
      case 'EN_LIVRAISON':
        return Icons.delivery_dining;
      case 'LIVREE':
        return Icons.done_all;
      case 'ANNULEE':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  // Placeholder pour l'affichage des détails
  void _showOrderDetails(BuildContext context, Commande commande) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Détails Commande #${commande.id}'),
        content: const Text(
            'Affichage de la liste des articles et de la pharmacie (À IMPLÉMENTER)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
