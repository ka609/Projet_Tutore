class Medicament {
  final int id;
  final String nomCommercial;
  final String? nomScientifique;
  final String? description;
  final String? categorie;
  final bool necessitePrescription;
  final String? photoUrl;

  // NOUVEAU : Ajout de la propriété prix
  final num price;

  Medicament({
    required this.id,
    required this.nomCommercial,
    this.nomScientifique,
    this.description,
    this.categorie,
    required this.necessitePrescription,
    this.photoUrl,
    required this.price, // Obligatoire lors de la création
  });

  factory Medicament.fromJson(Map<String, dynamic> json) {
    // IMPORTANT : Assurez-vous que votre JSON contient bien une clé 'price'
    // qui est parsée comme un nombre (double ou int).
    return Medicament(
      id: json['id'],
      nomCommercial: json['nom_commercial'],
      nomScientifique: json['nom_scientifique'],
      description: json['description'],
      categorie: json['categorie'],
      necessitePrescription: json['necessite_prescription'] ?? false,
      photoUrl: json['photo_url'],
      price: json['price'] ??
          0.0, // Assurez-vous d'avoir une valeur par défaut sûre
    );
  }

  // MÉTHODE CORRIGÉE : Définit le formatage du prix pour l'affichage dans l'UI
  String getFormattedPrice() {
    return 'DZD ${price.toStringAsFixed(2)}'; // Remplacez DZD par votre devise (DA, TND, USD, EUR, etc.)
  }
}
