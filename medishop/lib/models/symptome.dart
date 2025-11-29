class Symptome {
  final int id;
  final String nomSymptome;
  final String? description;

  Symptome({
    required this.id,
    required this.nomSymptome,
    this.description,
  });

  factory Symptome.fromJson(Map<String, dynamic> json) {
    return Symptome(
      id: json['id'],
      nomSymptome: json['nom_symptome'],
      description: json['description'],
    );
  }
}
