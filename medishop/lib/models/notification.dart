// lib/models/notification.dart (Version Corrigée)

class NotificationModel {
  final int id;
  final String titre;
  final String message;
  final String typeNotification;
  final bool estLue;
  final DateTime dateEnvoi;
  final int? objetId;

  NotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.typeNotification,
    required this.estLue,
    required this.dateEnvoi,
    this.objetId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      // Assurez-vous que l'API renvoie 'titre'. Si elle ne le fait pas toujours,
      // utilisez une chaîne vide ou le message.
      titre: json['titre'] ?? json['message'].split('\n').first,
      message: json['message'],
      typeNotification:
          json['type'], // Si l'API utilise 'type' au lieu de 'typeNotification'
      estLue: json['est_lue'] ?? false,
      dateEnvoi: DateTime.parse(json['date_envoi']),
      objetId: json['objet_id'],
    );
  }

  // Méthode copyWith (utile dans le provider)
  NotificationModel copyWith({
    bool? estLue,
  }) {
    return NotificationModel(
      id: id,
      titre: titre,
      message: message,
      typeNotification: typeNotification,
      estLue: estLue ?? this.estLue,
      dateEnvoi: dateEnvoi,
      objetId: objetId,
    );
  }
}
