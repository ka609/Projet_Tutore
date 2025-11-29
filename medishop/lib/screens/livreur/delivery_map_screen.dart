// lib/screens/livreur/delivery_map_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/delivery_provider.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String title;

  LocationData(
      {required this.latitude, required this.longitude, required this.title});
}

class DeliveryMapScreen extends StatelessWidget {
  // L'ID de la commande est passé en paramètre lors de la navigation
  final int commandeId;

  // Clé pour identifier l'écran dans le GoRouter si nous avons besoin de données
  const DeliveryMapScreen({super.key, required this.commandeId});

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = Provider.of<DeliveryProvider>(context);

    // Trouver la commande dans la liste des livraisons en cours
    final commande = deliveryProvider.myDeliveries.firstWhere(
      (c) => c.id == commandeId,
      orElse: () => throw Exception("Commande non trouvée ou non assignée."),
    );

    // --- Données de localisation simulées ---
    // En production, ces données seraient extraites de la commande (adresse, coordonnées)
    final pharmacyLocation = LocationData(
        latitude: 33.58,
        longitude: -7.61,
        title: "Pharmacie Source (Casablanca)");
    final customerLocation = LocationData(
        latitude: 33.59,
        longitude: -7.63,
        title: "Client: ${commande.adresseLivraison}");

    return Scaffold(
      appBar: AppBar(
        title: Text('Livraison #$commandeId'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          // 1. Zone de Carte (Simulée)
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 80, color: Colors.indigo),
                    const Text('Carte en direct (Simulation)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      'Départ: ${pharmacyLocation.title} (${pharmacyLocation.latitude.toStringAsFixed(2)})',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Arrivée: ${customerLocation.title} (${customerLocation.latitude.toStringAsFixed(2)})',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Bouton pour ouvrir un vrai service de navigation
                    ElevatedButton.icon(
                      onPressed: () {
                        // Action réelle: Lancer Google Maps ou Waze avec l'itinéraire
                        _launchExternalMap(customerLocation);
                      },
                      icon: const Icon(Icons.navigation),
                      label: const Text('Lancer la Navigation (Externe)'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Détails et Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statut Actuel: ${commande.statutCommande}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(commande.statutCommande)),
                ),
                const SizedBox(height: 10),
                Text('Adresse de Livraison : ${commande.adresseLivraison}'),
                Text(
                    'Total à encaisser : ${commande.totalMontant.toStringAsFixed(2)} DH (Paiement à la livraison)'),

                const SizedBox(height: 20),

                // Boutons d'Action Rapide
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: commande.statutCommande == 'LIVREE'
                            ? null
                            : () => _handleUpdateStatus(context,
                                deliveryProvider, commande.id, 'LIVREE'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Livrée'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: commande.statutCommande == 'LIVREE'
                            ? null
                            : () => _handleUpdateStatus(
                                context,
                                deliveryProvider,
                                commande.id,
                                'ECHEC_LIVRAISON'),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Échec'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour simuler le lancement d'une application de carte externe
  void _launchExternalMap(LocationData destination) {
    // Utiliser le package url_launcher pour ouvrir Waze ou Google Maps
    // Exemple pour Google Maps:
    // final url = 'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
    // launchUrl(Uri.parse(url));
    print('Lancement de la navigation vers: ${destination.title}...');
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EN_LIVRAISON':
        return Colors.amber.shade700;
      case 'LIVREE':
        return Colors.green;
      case 'ECHEC_LIVRAISON':
        return Colors.red;
      default:
        return Colors.indigo;
    }
  }

  Future<void> _handleUpdateStatus(BuildContext context,
      DeliveryProvider provider, int commandeId, String status) async {
    try {
      await provider.updateDeliveryStatus(commandeId, status);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut de livraison mis à jour à $status.')),
      );

      // Rediriger vers l'écran principal des livraisons après la finalisation
      if (status == 'LIVREE' || status == 'ECHEC_LIVRAISON') {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erreur: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    }
  }
}
