// lib/screens/client/medicament_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:medishop/providers/stock_provider.dart';
import 'package:medishop/providers/panier_provider.dart';
import 'package:medishop/models/stock.dart';
import 'package:medishop/models/medicament.dart';

class MedicamentDetailScreen extends StatefulWidget {
  final int medicamentId;

  const MedicamentDetailScreen({super.key, required this.medicamentId});

  @override
  State<MedicamentDetailScreen> createState() => _MedicamentDetailScreenState();
}

class _MedicamentDetailScreenState extends State<MedicamentDetailScreen> {
  Stock? _stockItem;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMedicamentDetails();
  }

  // Récupérer les détails de l'article de stock
  Future<void> _fetchMedicamentDetails() async {
    try {
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final fetchedStock =
          await stockProvider.fetchStockItemDetail(widget.medicamentId);

      setState(() {
        _stockItem = fetchedStock;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
        appBar: AppBar(title: Text('Détails du Médicament')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _stockItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Text('Erreur: $_error'),
        ),
      );
    }

    final medicament = _stockItem!.medicament;

    return Scaffold(
      appBar: AppBar(
        title: Text(medicament.nomCommercial),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(context, medicament, _stockItem!),
    );
  }

  Widget _buildBody(
      BuildContext context, Medicament medicament, Stock stockItem) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image et Nom Principal ---
          Center(
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[200],
                // Afficher l'image si disponible
                image: medicament.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(medicament.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: medicament.photoUrl == null
                  ? const Icon(Icons.medication,
                      size: 80, color: Colors.blueGrey)
                  : null,
            ),
          ),
          const SizedBox(height: 20),

          // --- Nom Commercial & Prix ---
          Text(
            medicament.nomCommercial,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Text(
            '${stockItem.prixUnitaire.toStringAsFixed(2)} DH',
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.w900, color: Colors.green),
          ),
          const Divider(height: 30),

          // --- Description ---
          if (medicament.description != null) ...[
            _buildSectionTitle('Description'),
            Text(medicament.description!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
          ],

          // --- Détails techniques ---
          _buildSectionTitle('Informations Détaillées'),
          _buildDetailRow(Icons.science, 'Nom Scientifique',
              medicament.nomScientifique ?? 'N/A'),
          _buildDetailRow(
              Icons.category, 'Catégorie', medicament.categorie ?? 'N/A'),

          _buildDetailRow(
              medicament.necessitePrescription
                  ? Icons.receipt_long
                  : Icons.verified,
              'Prescription',
              medicament.necessitePrescription ? 'OUI (Requis)' : 'Non Requis'),

          _buildDetailRow(Icons.store, 'Pharmacie', stockItem.pharmacie),
          _buildDetailRow(Icons.inventory, 'Quantité en Stock',
              stockItem.quantite.toString()),

          const SizedBox(height: 50),

          // --- Bouton Ajouter au Panier ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: stockItem.quantite > 0
                  ? () {
                      Provider.of<PanierProvider>(context, listen: false)
                          .addOrUpdateArticle(stockItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${medicament.nomCommercial} ajouté au panier!')),
                      );
                    }
                  : null,
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(
                stockItem.quantite > 0 ? 'Ajouter au Panier' : 'Stock Épuisé',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    stockItem.quantite > 0 ? Colors.indigo : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
