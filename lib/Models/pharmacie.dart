
class Pharmacie {
  final int id;
  final String nom;
  final String adresse;
  final int pharmacienId;

  Pharmacie({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.pharmacienId,
  });

  factory Pharmacie.fromJson(Map<String, dynamic> json) {
    return Pharmacie(
      id: json['id'],
      nom: json['nom'],
      adresse: json['adresse'],
      pharmacienId: json['Pharmacien'],
    );
  }
}
