class ParametreUtilisateur {
  final int id;
  final String utilisateur;
  final String cleParametre;
  final String valeurParametre;

  ParametreUtilisateur({
    required this.id,
    required this.utilisateur,
    required this.cleParametre,
    required this.valeurParametre,
  });

  factory ParametreUtilisateur.fromJson(Map<String, dynamic> json) {
    return ParametreUtilisateur(
      id: json['id'],
      utilisateur: json['utilisateur'],
      cleParametre: json['cle_parametre'],
      valeurParametre: json['valeur_parametre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cle_parametre': cleParametre,
      'valeur_parametre': valeurParametre,
    };
  }
}
