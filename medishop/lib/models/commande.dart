import 'ligne_commande.dart';

class Commande {
  final int id;
  final String client;
  final String pharmacie;
  final String? livreur;
  final DateTime dateCommande;
  final String statutCommande;
  final double totalMontant;
  final String adresseLivraison;
  final List<LigneCommande> lignes;

  Commande({
    required this.id,
    required this.client,
    required this.pharmacie,
    this.livreur,
    required this.dateCommande,
    required this.statutCommande,
    required this.totalMontant,
    required this.adresseLivraison,
    required this.lignes,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'],
      client: json['client'],
      pharmacie: json['pharmacie'],
      livreur: json['livreur'],
      dateCommande: DateTime.parse(json['date_commande']),
      statutCommande: json['statut_commande'],
      totalMontant: double.tryParse(json['total_montant'].toString()) ?? 0.0,
      adresseLivraison: json['adresse_livraison'],
      lignes: (json['lignes'] as List)
          .map((e) => LigneCommande.fromJson(e))
          .toList(),
    );
  }
}
