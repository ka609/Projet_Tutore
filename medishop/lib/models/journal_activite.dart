class JournalActivite {
  final int id;
  final String utilisateur;
  final String actionFaite;
  final String? details;
  final DateTime dateAction;

  JournalActivite({
    required this.id,
    required this.utilisateur,
    required this.actionFaite,
    this.details,
    required this.dateAction,
  });

  factory JournalActivite.fromJson(Map<String, dynamic> json) {
    return JournalActivite(
      id: json['id'],
      utilisateur: json['utilisateur'],
      actionFaite: json['action_faite'],
      details: json['details'],
      dateAction: DateTime.parse(json['date_action']),
    );
  }
}
