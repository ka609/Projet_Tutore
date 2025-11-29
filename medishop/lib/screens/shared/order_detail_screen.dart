// lib/screens/shared/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/commande_provider.dart';
import 'package:medishop/models/commande.dart';
import 'package:medishop/models/ligne_commande.dart';

// Cet écran sera partagé mais affichera des actions différentes selon l'utilisateur
class OrderDetailScreen extends StatefulWidget {
  final int commandeId;

  const OrderDetailScreen({super.key, required this.commandeId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Commande? _commande;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCommandeDetails();
  }

  Future<void> _fetchCommandeDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final commandeProvider =
          Provider.of<CommandeProvider>(context, listen: false);
      // NOTE: Le CommandeProvider doit avoir une méthode pour récupérer une commande par ID
      final Commande? fetchedCommande =
          await commandeProvider.fetchCommandeById(widget.commandeId);

      setState(() {
        _commande = fetchedCommande;
      });
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les détails de la commande.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Détails Commande')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    if (_commande == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Introuvable')),
        body: Center(
          child: Text('Commande #${widget.commandeId} introuvable.'),
        ),
      );
    }

    // Si la commande est disponible
    final commande = _commande!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${commande.id}'),
        backgroundColor: _getStatusColor(commande.statutCommande),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Statut & Total ---
            _buildHeaderCard(commande),
            const SizedBox(height: 20),

            // --- 2. Informations de Livraison ---
            _buildSectionTitle('Informations de Livraison'),
            _buildDetailRow(
                Icons.location_on, 'Adresse', commande.adresseLivraison),
            _buildDetailRow(Icons.person, 'Client', commande.client),
            _buildDetailRow(
                Icons.local_pharmacy, 'Pharmacie', commande.pharmacie),
            if (commande.livreur != null)
              _buildDetailRow(
                  Icons.delivery_dining, 'Livreur', commande.livreur!),

            const Divider(height: 30),

            // --- 3. Articles Commandés ---
            _buildSectionTitle(
                'Articles Commandés (${commande.lignes.length})'),
            ...commande.lignes
                .map((ligne) => _buildLigneCommandeTile(ligne))
                .toList(),

            const Divider(height: 30),

            // --- 4. Total Final ---
            _buildTotalSummary(commande.totalMontant),

            const SizedBox(height: 40),

            // --- 5. Actions (À adapter par rôle) ---
            _buildActionButtons(context, commande),
          ],
        ),
      ),
    );
  }

  // Afficheur de statut
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'LIVREE':
        return Colors.green;
      case 'EN_COURS':
        return Colors.orange;
      case 'EN_ATTENTE':
        return Colors.blueGrey;
      case 'ANNULEE':
        return Colors.red;
      default:
        return Colors.blueAccent;
    }
  }

  // --- Widgets de construction ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
    );
  }

  Widget _buildHeaderCard(Commande commande) {
    return Card(
      elevation: 4,
      color: _getStatusColor(commande.statutCommande).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut: ${commande.statutCommande.replaceAll('_', ' ')}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _getStatusColor(commande.statutCommande),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commandé le: ${commande.dateCommande.day}/${commande.dateCommande.month}/${commande.dateCommande.year} à ${commande.dateCommande.hour}:${commande.dateCommande.minute}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Montant Total: ${commande.totalMontant.toStringAsFixed(2)} DH',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLigneCommandeTile(LigneCommande ligne) {
    return ListTile(
      leading: const Icon(Icons.medication),
      title: Text(ligne.medicament.nomCommercial),
      subtitle: Text('Quantité: ${ligne.quantiteCommandee}'),
      trailing: Text(
        '${(ligne.prixVente * ligne.quantiteCommandee).toStringAsFixed(2)} DH',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTotalSummary(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'TOTAL FINAL: ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Text(
          '${total.toStringAsFixed(2)} DH',
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.deepOrange),
        ),
      ],
    );
  }

  // Exemples d'actions basées sur le rôle (À adapter avec AuthProvider)
  Widget _buildActionButtons(BuildContext context, Commande commande) {
    // Simplification: Afficher un bouton d'annulation si la commande n'est pas encore en cours de livraison
    if (commande.statutCommande == 'EN_ATTENTE') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Implémenter la logique d'annulation via CommandeProvider
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Annulation en cours...')),
            );
          },
          icon: const Icon(Icons.cancel),
          label: const Text('Annuler la Commande'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }
    // Aucune action si la commande est livrée/annulée
    return const SizedBox.shrink();
  }
}
