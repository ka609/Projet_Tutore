class Paiement {
  final int id;
  final String commande;
  final String methodePaiement;
  final double montant;
  final String statutPaiement;
  final String referenceTransaction;
  final DateTime datePaiement;

  Paiement({
    required this.id,
    required this.commande,
    required this.methodePaiement,
    required this.montant,
    required this.statutPaiement,
    required this.referenceTransaction,
    required this.datePaiement,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'],
      commande: json['commande'],
      methodePaiement: json['methode_paiement'],
      montant: double.tryParse(json['montant'].toString()) ?? 0.0,
      statutPaiement: json['statut_paiement'],
      referenceTransaction: json['reference_transaction'],
      datePaiement: DateTime.parse(json['date_paiement']),
    );
  }
}
