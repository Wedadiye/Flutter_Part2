
class Medicament {
  final int id;
  final String nom;
  final double prix;
  final String description;
  final bool disponible;
  final String image;
  final int quantite;
  final int catagorie;
  final int pharmacieId;


  Medicament({
    required this.id,
    required this.nom,
    required this.quantite,
    required this.prix,
    required this.description,
    required this.disponible,
    required this.image,
    required this.catagorie,
    required this.pharmacieId,


  });

  factory Medicament.fromJson(Map<String, dynamic> json) {
    var url ='http://192.168.1.153:8000/';

    return Medicament(
      id: json['id'],
      nom: json['nom'],
      quantite: json['quantite'],

      prix: double.parse(json['prix']),
      description: json['description'],
      disponible: json['disponible'],
      image: '${url}${json['image']}',
      catagorie: json['catagorie'],
      pharmacieId: json['pharmacie'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prix': prix,
      'description': description,
      'quantite': quantite,
      'disponible': disponible,
      'image': image,
      'catagorie': catagorie,
      'pharmacieId': pharmacieId,
    };
  }
}
