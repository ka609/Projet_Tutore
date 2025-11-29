import 'utilisateur.dart';

class Client {
  final int id;
  final Utilisateur utilisateur;

  Client({
    required this.id,
    required this.utilisateur,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      utilisateur: Utilisateur.fromJson(json['utilisateur']),
    );
  }
}
