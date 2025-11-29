import 'panier_article.dart';

class Panier {
  final int id;
  final String client;
  final DateTime dateCreation;
  final DateTime dateDerniereMaj;
  final List<PanierArticle> articles;

  Panier({
    required this.id,
    required this.client,
    required this.dateCreation,
    required this.dateDerniereMaj,
    required this.articles,
  });

  factory Panier.fromJson(Map<String, dynamic> json) {
    return Panier(
      id: json['id'],
      client: json['client'],
      dateCreation: DateTime.parse(json['date_creation']),
      dateDerniereMaj: DateTime.parse(json['date_derniere_maj']),
      articles: (json['articles'] as List)
          .map((e) => PanierArticle.fromJson(e))
          .toList(),
    );
  }
}
