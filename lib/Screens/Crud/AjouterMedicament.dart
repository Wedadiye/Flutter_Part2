import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../Models/medicament.dart';
import '../../Provider/AuthProvider.dart';

class AddMedicamentPage extends StatefulWidget {
  @override
  _AddMedicamentPageState createState() => _AddMedicamentPageState();
}

class _AddMedicamentPageState extends State<AddMedicamentPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  bool _disponible = true;
  File? _image;
  int? _selectedCategoryId;

  @override

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Consumer<PharmacieProvider>(
          builder: (context, pharmacieProvider, child) {
            final pharmacieId = pharmacieProvider.pharmacieId;
            return Text(pharmacieId != null ? 'Pharmacie ID: $pharmacieId' : 'Chargement...');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom du médicament'),
              ),
              TextField(
                controller: _prixController,
                decoration: InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: _quantiteController,
                decoration: InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
              ),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  return categoryProvider.isLoading
                      ? CircularProgressIndicator()
                      : DropdownButton<int>(
                    value: categoryProvider.selectedCategoryId,
                    onChanged: (newValue) {
                      categoryProvider.setSelectedCategory(newValue);
                    },
                    items: categoryProvider.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    isExpanded: true,
                    underline: Container(
                      height: 0,
                    ),
                    hint: Text('Sélectionner une catégorie'),
                  );
                },
              ),
              SizedBox(height: 20),
//affichage image

              AddMedicamentImagePicker(),
              /*
             AddMedicamentImagePicker(
                onImageSelected: (File image) {
                  setState(() {
                    _image = image;
                  });
                },
              ),
              */

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);

                  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                  final pharmacieProvider = Provider.of<PharmacieProvider>(context, listen: false);
                  final medicamentProvider = Provider.of<MedicamentProvider>(context, listen: false);
                  // Récupérer l'image sélectionnée
                  final imageProvider = Provider.of<ImagePickerProvider>(context, listen: false);
                  final _image = imageProvider.pickedImage;
                  final pharmacieId=authProvider.pharmacistId;
                  // Vérifier si une image a été sélectionnée
                  if (_image == null) {
                    // Afficher une alerte si aucune image n'a été sélectionnée
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Erreur'),
                          content: Text('Veuillez sélectionner une image.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }

                  var newMedicament = Medicament(
                    id: 0,
                    nom: _nomController.text,
                    prix: double.parse(_prixController.text),
                    description: _descriptionController.text,
                    quantite: int.parse(_quantiteController.text),
                    disponible: _disponible,
                    image: '', // L'image est envoyée séparément, pas comme une URL
                    catagorie: categoryProvider.selectedCategoryId!,
                    pharmacieId: pharmacieProvider.pharmacieId!,
                  );
                  // Appeler la méthode d'ajout de médicament avec l'image récupérée
                  await medicamentProvider.addMedicament(newMedicament, _image);
                  await medicamentProvider.fetchMedicaments(pharmacieId!);

                  // Afficher une alerte de succès
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Succès'),
                        content: Text('Le médicament a été ajouté avec succès.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              // Revenir à la page de liste mise à jour lorsque l'utilisateur appuie sur "OK"
                              Navigator.of(context).pop();
                              Navigator.pop(context); // Revenir à la page précédente
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Ajouter'),
              ),

/*
              ElevatedButton(
                onPressed: () async {
                  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                  final pharmacieProvider = Provider.of<PharmacieProvider>(context, listen: false);
                  final medicamentProvider = Provider.of<MedicamentProvider>(context, listen: false);
                  //File? _image = Provider.of<ImagePickerProvider>(context, listen: false).pickedImage;

                  if (_image == null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Erreur'),
                          content: Text('Veuillez sélectionner une image.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }

                  var newMedicament = Medicament(
                    id: 0,
                    nom: _nomController.text,
                    prix: double.parse(_prixController.text),
                    description: _descriptionController.text,
                    quantite: int.parse(_quantiteController.text),
                    disponible: _disponible,
                    image: '', // L'image est envoyée séparément, pas comme une URL
                    catagorie: categoryProvider.selectedCategoryId!,
                    pharmacieId: pharmacieProvider.pharmacieId!,
                  );

                  await medicamentProvider.addMedicament(newMedicament, _image!);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Succès'),
                        content: Text('Le médicament a été ajouté avec succès.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );



                  /*
                  var newMedicament = Medicament(
                    id: 0,
                    nom: _nomController.text,
                    prix: double.parse(_prixController.text),
                    description: _descriptionController.text,
                    quantite: int.parse(_quantiteController.text),
                    disponible: _disponible,
                    image: _image!.path,
                    catagorie: categoryProvider.selectedCategoryId!,
                    pharmacieId: pharmacieProvider.pharmacieId!,
                  );

                  await medicamentProvider.addMedicament(newMedicament);
*/              },

                child: Text('Ajouter'),
              ),
              */

            ]
          ),
        ),
      ),
    );
  }
}



class AddMedicamentImagePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ImagePickerProvider>(
      builder: (context, imagePickerProvider, _) {
        return Column(
          children: [
            imagePickerProvider.pickedImage != null
                ? Image.file(
              imagePickerProvider.pickedImage!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
                : SizedBox(),
            ElevatedButton(
              onPressed: () {
                // Utilisation du provider pour sélectionner une image
                context.read<ImagePickerProvider>().getImage();
              },
              child: Text('Sélectionner une image'),
            ),
          ],
        );
      },
    );
  }
}


class ImagePickerProvider extends ChangeNotifier {
  File? _pickedImage;
  File? get pickedImage => _pickedImage;
  String? _pickedImagePath;
  String? get pickedImagePath => _pickedImagePath;

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      _pickedImage = File(pickedImage.path);
      _pickedImagePath = pickedImage.path;
      notifyListeners();
    }
  }
}