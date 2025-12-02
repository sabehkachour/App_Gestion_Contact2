class Person {
  final int? id;
  final String nom;
  final String prenom;
  final String telephone;

  Person({this.id, required this.nom, required this.prenom, required this.telephone});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
      };
}