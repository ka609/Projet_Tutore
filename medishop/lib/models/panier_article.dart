import 'package:medishop/models/stock.dart';
import 'medicament.dart';

class PanierArticle {
  final int? id;
  final int? panierId;
  final Stock stock;
  final Medicament medicament; // maintenant obligatoire
  final int quantite;

  PanierArticle({
    this.id,
    this.panierId,
    required this.stock,
    required this.medicament,
    required this.quantite,
  });

  // --- GETTERS PRATIQUES ---
  double get prixUnitaire => stock.prixUnitaire;
  String get nomMedicament =>
      medicament.nomCommercial; // utiliser medicament directement
  int get stockId => stock.id;

  // --- FACTORY FROM JSON ---
  factory PanierArticle.fromJson(Map<String, dynamic> json) {
    final stockObj = Stock.fromJson(json['stock']);
    final medicamentObj = stockObj.medicament; // récupérer depuis le stock

    return PanierArticle(
      id: json['id'] as int?,
      panierId: json['panier'] as int?,
      stock: stockObj,
      medicament: medicamentObj,
      quantite: json['quantite'] as int,
    );
  }

  // --- TO JSON (pour envoyer à l'API) ---
  Map<String, dynamic> toJson() {
    return {
      'stock_id': stock.id,
      'quantite': quantite,
    };
  }
}
