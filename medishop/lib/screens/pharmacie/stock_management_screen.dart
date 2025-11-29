import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:medishop/providers/stock_provider.dart';
import 'package:medishop/models/stock.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Charger le stock de la pharmacie
    Future.microtask(() => Provider.of<StockProvider>(context, listen: false)
        .fetchAvailableStock(forceRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de mon Stock'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- Barre de Recherche ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par nom de médicament ou catégorie...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (query) {
                stockProvider.setSearchQuery(query);
              },
            ),
          ),

          // --- Indicateur de Chargement/Erreur ---
          if (stockProvider.isLoading)
            const LinearProgressIndicator(color: Colors.teal)
          else if (stockProvider.errorMessage != null)
            _buildErrorState(stockProvider.errorMessage!)
          else
            // --- Liste du Stock ---
            Expanded(
              child: stockProvider.filteredStock.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      itemCount: stockProvider.filteredStock.length,
                      itemBuilder: (context, index) {
                        final stockItem = stockProvider.filteredStock[index];
                        return _StockItemTile(stockItem: stockItem);
                      },
                    ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Redirection vers la page d'ajout de stock
          context.go('/pharmacie/dashboard/stock/add');
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un nouveau stock',
      ),
    );
  }

  // Widget d'erreur
  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Erreur de chargement: $message',
            style:
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// --- Widget pour l'état vide ---
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // évite l'overflow
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 80, color: Colors.blueGrey),
          const SizedBox(height: 16),
          const Text(
            "Votre stock est vide.",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Utilisez le bouton + ci-dessous pour ajouter.",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// --- Widget personnalisé pour un article de Stock ---
class _StockItemTile extends StatelessWidget {
  final Stock stockItem;

  const _StockItemTile({required this.stockItem});

  // Construit le statut visuel
  Widget _buildStatusChip(int quantity) {
    Color color;
    String label;

    if (quantity > 20) {
      color = Colors.green;
      label = 'Bon Stock';
    } else if (quantity > 0) {
      color = Colors.orange;
      label = 'Faible Stock';
    } else {
      color = Colors.red;
      label = 'Épuisé';
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: const Icon(Icons.medical_services_outlined,
            color: Colors.teal, size: 30),
        title: Text(
          stockItem.medicament.nomCommercial,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min, // évite l'overflow
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Référence: ${stockItem.medicament.nomScientifique ?? 'N/A'}'),
            const SizedBox(height: 4),
            _buildStatusChip(stockItem.quantite),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min, // évite l'overflow
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${stockItem.prixUnitaire.toStringAsFixed(2)} FCFA',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 16),
            ),
            Text(
              'Qty: ${stockItem.quantite}',
              style: TextStyle(
                  color: stockItem.quantite > 0 ? Colors.teal : Colors.red,
                  fontWeight: FontWeight.w500),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              tooltip: 'Modifier stock',
              onPressed: () {
                context.go(
                  '/pharmacie/dashboard/stock/edit',
                  extra: stockItem,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
