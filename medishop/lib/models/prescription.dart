class Prescription {
  final int id;
  final String client;
  final String? pharmacie;
  final String? fichierUrl;
  final DateTime dateTelechargement;
  final String statutValidation;

  Prescription({
    required this.id,
    required this.client,
    this.pharmacie,
    this.fichierUrl,
    required this.dateTelechargement,
    required this.statutValidation,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      client: json['client'],
      pharmacie: json['pharmacie'],
      fichierUrl: json['fichier_url'],
      dateTelechargement: DateTime.parse(json['date_telechargement']),
      statutValidation: json['statut_validation'],
    );
  }
}
