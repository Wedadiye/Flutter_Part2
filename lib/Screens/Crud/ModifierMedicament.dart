
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Models/medicament.dart';
import '../../Provider/AuthProvider.dart';
import 'AjouterMedicament.dart';

class EditMedicamentPage extends StatefulWidget {
//  Medicament medicament;
  final Medicament medicament; // Déclarez l'attribut medicament

  const EditMedicamentPage({Key? key, required this.medicament}) : super(key: key);




  //const EditMedicamentPage({Key? key, required this.medicament}) : super(key: key);

  @override
  _EditMedicamentPageState createState() => _EditMedicamentPageState();
}

class _EditMedicamentPageState extends State<EditMedicamentPage> {
  late TextEditingController _nomController;
  late TextEditingController _prixController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantiteController;
  late bool _disponible;
  late int _selectedCategoryId;
  late Medicament medicament; // Variable d'instance pour stocker l'objet Medicament
  File? _image;


  @override
  void initState() {
    super.initState();
    Provider.of<CategoryProvider>(context, listen: false).fetchCategories();

    // Récupérer l'objet Medicament passé en argument


    _nomController = TextEditingController(text: widget.medicament.nom);
    _prixController = TextEditingController(text: widget.medicament.prix.toString());
    _descriptionController = TextEditingController(text: widget.medicament.description);
    _quantiteController = TextEditingController(text: widget.medicament.quantite.toString());
    _disponible = widget.medicament.disponible;
    _selectedCategoryId = widget.medicament.catagorie;
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le médicament'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
            SizedBox(height: 20),


            SizedBox(height: 20),


            SwitchListTile(
              title: Text('Disponible'),
              value: _disponible,
              onChanged: (value) {
                setState(() {
                  _disponible = value;
                });
              },
            ),
// Utilisez le Consumer<CategoryProvider> ici
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                return categoryProvider.isLoading
                    ? CircularProgressIndicator()
                    : DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategoryId = newValue!;
                    });
                  },
                  items: categoryProvider.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Catégorie'),
                );
              },
            ),
            /*
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategoryId = newValue!;
                });
              },
              items: Provider.of<CategoryProvider>(context).categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Catégorie'),
            ),

             */
            SizedBox(height: 20),

            AddMedicamentImagePicker(medicament: widget.medicament),

            ElevatedButton(
              onPressed: () async {

                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final medicamentProvider = Provider.of<MedicamentProvider>(context, listen: false);
                // Récupérer l'image sélectionnée
                final imageProvider = Provider.of<ImagePickerProvider>(context, listen: false);
                final _image = imageProvider.pickedImage;
                final pharmacieId=authProvider.pharmacistId;

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

                // Créer un nouvel objet Medicament avec les données mises à jour
                final updatedMedicament = Medicament(
                  id: widget.medicament.id,
                  nom: _nomController.text,
                  prix: double.parse(_prixController.text),
                  description: _descriptionController.text,
                  quantite: int.parse(_quantiteController.text),
                  disponible: _disponible,
                  image: '',
                  catagorie: _selectedCategoryId,
                  pharmacieId: widget.medicament.pharmacieId,
                );

                // Appeler la méthode de mise à jour dans le fournisseur de médicaments
                await medicamentProvider.updateMedicament(updatedMedicament,_image);
                await medicamentProvider.fetchMedicaments(pharmacieId!);

                // Retourner à l'écran précédent

    // Afficher une alerte de succès
    showDialog(
    context: context,
    builder: (BuildContext context) {
    return AlertDialog(
    title: Text('Succès'),
    content: Text('Le médicament a été modifié avec succès.'),
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
              child: Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }
}


class AddMedicamentImagePicker extends StatelessWidget {
  final Medicament medicament;

  const AddMedicamentImagePicker({Key? key, required this.medicament}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ImagePickerProvider>(
      builder: (context, imagePickerProvider, _) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (imagePickerProvider.pickedImage != null)
                  Image.file(
                    imagePickerProvider.pickedImage!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                else if (medicament.image.isNotEmpty)
                  Image.network(
                    medicament.image,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                else
                  SizedBox(),
              ],
            ),
            ElevatedButton(
              onPressed: () {
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

