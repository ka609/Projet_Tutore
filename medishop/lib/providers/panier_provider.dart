// lib/providers/panier_provider.dart

import 'package:flutter/material.dart';
import 'package:medishop/models/stock.dart';
import 'package:medishop/models/panier_article.dart';

class PanierProvider with ChangeNotifier {
  // CLÉ CORRIGÉE: Utiliser l'ID du Stock (qui inclut le prix/pharmacie)
  final Map<int, PanierArticle> _items = {};

  // Getter pour la liste des articles affichés dans l'UI
  List<PanierArticle> get articles => _items.values.toList();

  // Getter pour le nombre total d'articles différents dans le panier
  int get itemCount => _items.length;

  // Getter pour le montant total du panier
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, article) {
      total += article.quantite * article.prixUnitaire;
    });
    return total;
  }

  // --- 1. Ajouter / Mettre à jour un article ---
  void addOrUpdateArticle(Stock stockItem) {
    final stockId = stockItem.id;

    if (_items.containsKey(stockId)) {
      _items.update(stockId, (existingArticle) {
        return PanierArticle(
          id: existingArticle.id,
          panierId: existingArticle.panierId,
          stock: existingArticle.stock,
          medicament: existingArticle.medicament,
          quantite: existingArticle.quantite + 1,
        );
      });
    } else {
      _items.putIfAbsent(stockId, () {
        return PanierArticle(
          stock: stockItem,
          quantite: 1,
          medicament: stockItem.medicament,
        );
      });
    }
    notifyListeners();
  }

  // --- 2. Modifier la quantité ---
  void setArticleQuantity(int stockId, int quantite) {
    if (_items.containsKey(stockId) && quantite > 0) {
      _items.update(stockId, (existingArticle) {
        return PanierArticle(
          id: existingArticle.id,
          panierId: existingArticle.panierId,
          stock: existingArticle.stock,
          medicament: existingArticle.medicament,
          quantite: quantite,
        );
      });
    } else if (quantite <= 0) {
      removeArticle(stockId);
    }
    notifyListeners();
  }

  // --- 3. Supprimer un article ---
  void removeArticle(int stockId) {
    _items.remove(stockId);
    notifyListeners();
  }

  // --- 4. Vider le panier (pour CommandeProvider) ---
  void clearPanier() {
    _items.clear();
    notifyListeners();
  }
}
