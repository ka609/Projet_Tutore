import 'utilisateur.dart';

class Livreur {
  final int id;
  final Utilisateur utilisateur;
  final String statutDisponibilite;
  final String? vehiculeType;

  Livreur({
    required this.id,
    required this.utilisateur,
    required this.statutDisponibilite,
    this.vehiculeType,
  });

  factory Livreur.fromJson(Map<String, dynamic> json) {
    return Livreur(
      id: json['id'],
      utilisateur: Utilisateur.fromJson(json['utilisateur']),
      statutDisponibilite: json['statut_disponibilite'],
      vehiculeType: json['vehicule_type'],
    );
  }
}
