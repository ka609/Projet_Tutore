// lib/screens/client/panier_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:medishop/providers/panier_provider.dart';
import 'package:medishop/models/panier_article.dart';

class PanierScreen extends StatelessWidget {
  const PanierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Écouter le PanierProvider pour les mises à jour en temps réel
    final panierProvider = Provider.of<PanierProvider>(context);

    return Column(
      children: <Widget>[
        // --- 1. Liste des Articles ---
        Expanded(
          child: panierProvider.articles.isEmpty
              ? _buildEmptyCart() // État si le panier est vide
              : ListView.builder(
                  itemCount: panierProvider.articles.length,
                  itemBuilder: (context, index) {
                    final article = panierProvider.articles[index];
                    return _buildCartItem(context, panierProvider, article);
                  },
                ),
        ),

        // --- 2. Récapitulatif et Bouton de Commande ---
        _buildCheckoutSummary(context, panierProvider),
      ],
    );
  }

  // --- Widget 1: État Panier Vide ---
  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.deepOrangeAccent),
          SizedBox(height: 16),
          Text(
            "Votre Panier est vide",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Ajoutez des médicaments depuis le catalogue.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- Widget 2: Tuile d'Article de Panier ---
  Widget _buildCartItem(
      BuildContext context, PanierProvider provider, PanierArticle article) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: const Icon(Icons.medication_liquid, color: Colors.blue),
        title: Text(article.medicament.nomCommercial,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Prix unitaire: ${article.prixUnitaire.toStringAsFixed(2)} DH',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Décrémenter
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: article.quantite > 1
                  ? () => provider.setArticleQuantity(
                      article.medicament.id, article.quantite - 1)
                  : null, // Désactiver si quantité = 1
            ),
            // Quantité actuelle
            Text('${article.quantite}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            // Incrémenter
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () {
                // TODO: Ajouter une vérification du stock réel ici si l'on augmente la quantité
                provider.setArticleQuantity(
                    article.medicament.id, article.quantite + 1);
              },
            ),
            // Supprimer définitivement
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => provider.removeArticle(article.medicament.id),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget 3: Récapitulatif et Paiement ---
  Widget _buildCheckoutSummary(BuildContext context, PanierProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total du Panier:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '${provider.totalAmount.toStringAsFixed(2)} DH',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: provider.articles.isEmpty
                ? null // Désactiver si le panier est vide
                : () {
                    // TODO: Démarrer le processus de checkout (Adresse, Paiement, Création Commande API)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Début du processus de commande (À IMPLÉMENTER)')),
                    );
                  },
            icon: const Icon(Icons.payment),
            label: Text(
              'PROCÉDER À LA COMMANDE (${provider.itemCount})',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
