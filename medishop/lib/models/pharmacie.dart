import 'utilisateur.dart';

class Pharmacie {
  final int id;
  final Utilisateur utilisateur;
  final String nomPharmacie;
  final String licenceNumero;
  final double? latitude;
  final double? longitude;

  Pharmacie({
    required this.id,
    required this.utilisateur,
    required this.nomPharmacie,
    required this.licenceNumero,
    this.latitude,
    this.longitude,
  });

  factory Pharmacie.fromJson(Map<String, dynamic> json) {
    return Pharmacie(
      id: json['id'],
      utilisateur: Utilisateur.fromJson(json['utilisateur']),
      nomPharmacie: json['nom_pharmacie'],
      licenceNumero: json['licence_numero'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }
}
