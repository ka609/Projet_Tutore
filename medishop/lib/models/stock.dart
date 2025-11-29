import 'medicament.dart';

class Stock {
  final int id;
  final String pharmacie;
  final Medicament medicament;
  final int quantite;
  final double prixUnitaire;

  Stock({
    required this.id,
    required this.pharmacie,
    required this.medicament,
    required this.quantite,
    required this.prixUnitaire,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      pharmacie: json['pharmacie'],
      medicament: Medicament.fromJson(json['medicament']),
      quantite: json['quantite'],
      prixUnitaire: double.tryParse(json['prix_unitaire'].toString()) ?? 0.0,
    );
  }
}
