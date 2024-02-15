
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../Models/catagorie.dart';
import '../Models/medicament.dart';
import '../Models/pharmacie.dart';
import 'dart:io';



class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;


  int? _pharmacistId; // Variable pour stocker l'ID du pharmacien
  int? get pharmacistId => _pharmacistId;

  Future<bool> login(String username, String password) async {
    final response = await http.get(Uri.parse('http://192.168.56.141:8000/Pharmacies/Pharmacien/?username=$username&password=$password'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData.isNotEmpty) {
        _isLoggedIn = true;
        _pharmacistId = jsonData[0]['id']; // Stockez l'ID du pharmacien

        notifyListeners();
        return true;

      }
      return false;
    }
    return false;
  }
}

class PharmacieProvider extends ChangeNotifier {
  Pharmacie? _pharmacie;

  Pharmacie? get pharmacie => _pharmacie;

  int? _pharmacieId; // Variable pour stocker l'ID du pharmacie

  int? get pharmacieId => _pharmacieId;

  Future<void> fetchPharmacie(int pharmacienId) async {
    final response = await http.get(Uri.parse('http://192.168.56.141:8000/Pharmacies/$pharmacienId/medicaments/'));
    //_pharmacie = jsonData['pharmacie'].map<Medicament>((data) => Pharmacie.fromJson(data)).toList();
    final jsonData = json.decode(response.body);
    final pharmacieData = jsonData[0]['pharmacie'];
    _pharmacie = Pharmacie.fromJson(pharmacieData);
    _pharmacieId = _pharmacie?.id; // Stocker l'ID du pharmacie dans la variable

    notifyListeners();

  }
}


class MedicamentProvider extends ChangeNotifier {
  List<Medicament> _medicaments = [];

  List<Medicament> get medicaments => _medicaments;
/*
// Méthode pour ajouter un médicament
  Future<void> addMedicament(Medicament newMedicament) async {
    final url = 'http://192.168.56.141:8000/Pharmacies/Medicament/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newMedicament.toJson()),
      );

      if (response.statusCode == 201) {
        // Si la requête est réussie (statut 201), le médicament a été ajouté avec succès
        print('Médicament ajouté avec succès');
      } else {
        // Sinon, s'il y a eu une erreur, imprimez le message d'erreur
        print('Erreur lors de l\'ajout du médicament: ${response.body}');
      }
    } catch (error) {
      // Gérer les erreurs ici, si la requête a échoué pour une autre raison
      print('Erreur lors de l\'ajout du médicament: $error');
    }
  }
*/
  Future<void> addMedicament(Medicament newMedicament, File imageFile) async {
    final url = 'http://192.168.56.141:8000/Pharmacies/Medicament/';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['nom'] = newMedicament.nom;
      request.fields['prix'] = newMedicament.prix.toString();
      request.fields['description'] = newMedicament.description;
      request.fields['quantite'] = newMedicament.quantite.toString();
      request.fields['disponible'] = newMedicament.disponible.toString();
      request.fields['catagorie'] = newMedicament.catagorie.toString();
      request.fields['pharmacie'] = newMedicament.pharmacieId.toString();
      request.files.add(http.MultipartFile(
        'image',
        imageFile.readAsBytes().asStream(),
        imageFile.lengthSync(),
        filename: imageFile.path.split('/').last,
      ));

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        print('Médicament ajouté avec succès');
      } else {
        print('Erreur lors de l\'ajout du médicament: ${response.body}');
      }
    } catch (error) {
      print('Erreur lors de l\'ajout du médicament: $error');
    }
  }

  // Méthode pour modifier un médicament existant
  Future<void> updateMedicament(Medicament updatedMedicament, File imageFile) async {
    final url = 'http://192.168.56.141:8000/Pharmacies/Medicament/${updatedMedicament.id}'; // Ajoutez l'ID du médicament à la fin de l'URL

    try {

      var request = http.MultipartRequest('PUT', Uri.parse(url)); // Utilisez la méthode PUT pour la mise à jour
      request.fields['nom'] = updatedMedicament.nom;
      request.fields['prix'] = updatedMedicament.prix.toString();
      request.fields['description'] = updatedMedicament.description;
      request.fields['quantite'] = updatedMedicament.quantite.toString();
      request.fields['disponible'] = updatedMedicament.disponible.toString();
      request.fields['catagorie'] = updatedMedicament.catagorie.toString();
      request.fields['pharmacie'] = updatedMedicament.pharmacieId.toString();
 // Vérifiez si une nouvelle image est fournie
        request.files.add(http.MultipartFile(
          'image',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),
          filename: imageFile.path.split('/').last,
        ));


      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        print('Médicament mis à jour avec succès');
      } else {
        print('Erreur lors de la mise à jour du médicament: ${response.body}');
      }
    }
  catch (error) {
  print('Erreur lors de l\'ajout du médicament: $error');
  }
  }

  Future<void> fetchMedicaments(int pharmacienId) async {
    final response = await http.get(Uri.parse('http://192.168.56.141:8000/Pharmacies/$pharmacienId/medicaments/'));
    final jsonData = json.decode(response.body);
    final medicamentsData = jsonData[0]['medicaments'];
    _medicaments = medicamentsData.map<Medicament>((data) => Medicament.fromJson(data)).toList();

    notifyListeners();
  }
}


class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Category> get categories => _categories;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> fetchCategories() async {
    _isLoading = true; // Mettre _isLoading à true avant le chargement
    notifyListeners();

    try {
      final url = 'http://192.168.56.141:8000/Pharmacies/Catagorie/';
      final response = await http.get(Uri.parse(url));
      final jsonData = json.decode(response.body) as List<dynamic>;
      _categories = jsonData.map((data) => Category.fromJson(data)).toList();
    } catch (error) {
      // Gérer les erreurs de récupération des catégories ici
      print('Erreur lors de la récupération des catégories: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }
/*

  Future<void> fetchCategories() async {
    final url = 'http://192.168.100.199:8000/Pharmacies/Catagorie/';
    final response = await http.get(Uri.parse(url));
    final jsonData = json.decode(response.body) as List<dynamic>;
    _categories = jsonData.map((data) => Category.fromJson(data)).toList();
    notifyListeners();
  }

 */
  void setSelectedCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
}

