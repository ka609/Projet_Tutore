// lib/screens/client/catalogue_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:medishop/providers/stock_provider.dart';
import 'package:medishop/models/stock.dart';

class CatalogueScreen extends StatelessWidget {
  const CatalogueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue de Médicaments'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // --- IMAGE D’ARRIÈRE PLAN ---
          Positioned.fill(
            child: Image.asset(
              'assets/images/pha_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // --- OVERLAY sombre (pour lisibilité) ---
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          // --- CONTENU ---
          Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.90),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white70),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText:
                          'Rechercher un médicament (nom, symptôme, catégorie)...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: (query) => stockProvider.setSearchQuery(query),
                  ),
                ),
              ),

              if (stockProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: LinearProgressIndicator(),
                ),

              if (stockProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Erreur: ${stockProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),

              Expanded(
                child: stockProvider.filteredStock.isEmpty &&
                        !stockProvider.isLoading
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => stockProvider.fetchAvailableStock(
                            forceRefresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          itemCount: stockProvider.filteredStock.length,
                          itemBuilder: (context, index) {
                            final stockItem =
                                stockProvider.filteredStock[index];
                            return _buildStockTile(context, stockItem);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Carte d’un médicament (STYLE PRO)
  Widget _buildStockTile(BuildContext context, Stock stockItem) {
    final medicament = stockItem.medicament;
    final pharmacieName = stockItem.pharmacie;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: medicament.photoUrl != null
              ? Image.network(
                  medicament.photoUrl!,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.local_pharmacy, color: Colors.teal),
                )
              : const Icon(Icons.local_pharmacy, color: Colors.teal, size: 32),
        ),
        title: Text(
          medicament.nomCommercial,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Pharmacie: $pharmacieName\nPrix: ${stockItem.prixUnitaire.toStringAsFixed(2)} FCFA",
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
          onPressed: () {
            // TODO: intégrer PanierProvider.addArticle(stockItem)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                    '${medicament.nomCommercial} ajouté au panier (à implémenter)'),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- État vide (UI PRO)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.medication_liquid, size: 90, color: Colors.white),
          SizedBox(height: 16),
          Text(
            "Aucun produit trouvé.",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
