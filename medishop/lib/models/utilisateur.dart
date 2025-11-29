import 'user_type.dart';

class Utilisateur {
  final int id;
  final String email;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? adresse;
  final UserType typeUtilisateur;
  final String? photoUrl;

  Utilisateur({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.adresse,
    required this.typeUtilisateur,
    this.photoUrl,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      typeUtilisateur: userTypeFromString(json['type_utilisateur']),
      photoUrl: json['photo_url'],
    );
  }
}
