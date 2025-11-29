import 'medicament.dart';

class LigneCommande {
  final int id;
  final int commandeId;
  final Medicament medicament;
  final int quantiteCommandee;
  final double prixVente;

  LigneCommande({
    required this.id,
    required this.commandeId,
    required this.medicament,
    required this.quantiteCommandee,
    required this.prixVente,
  });

  factory LigneCommande.fromJson(Map<String, dynamic> json) {
    return LigneCommande(
      id: json['id'],
      commandeId: json['commande'],
      medicament: Medicament.fromJson(json['medicament']),
      quantiteCommandee: json['quantite_commandee'],
      prixVente: double.tryParse(json['prix_vente'].toString()) ?? 0.0,
    );
  }
}
