import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/medicament.dart';
import '../../Provider/AuthProvider.dart';
import '../login.dart';
import './AjouterMedicament.dart';
import 'ModifierMedicament.dart';

class MedicationCRUDPage extends StatelessWidget {
  // Méthode pour naviguer vers la page de modification
  void _editMedicament(BuildContext context, Medicament medicament) {
    Navigator.pushNamed(context, '/edit_medicament', arguments: medicament);
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pharmacienId = authProvider.pharmacistId;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
        centerTitle: true,
        title: Consumer<PharmacieProvider>(
        builder: (context, provider, _) {
      if (provider.pharmacie == null) {
        provider.fetchPharmacie(pharmacienId!);
        return Text('Chargement...');
      } else {
        return Text(provider.pharmacie!.nom.toUpperCase());

      }
    },
    ),
    actions: [
    IconButton(
    icon: Icon(Icons.search), // Icône de recherche
    onPressed: () {
    // Action de recherche
    },
    ),

    IconButton(
    icon: Icon(Icons.add),
    onPressed: () {
    // Action pour Ajouter le médicament
    Navigator.pushNamed(context, '/add_medicament');

    },
    ),

    ],
      ),
      body:  Consumer<MedicamentProvider>(
        builder: (context, provider, _) {
          if (provider.medicaments.isEmpty) {
            provider.fetchMedicaments(pharmacienId as int);
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: provider.medicaments.length,
              itemBuilder: (context, index) {
                final medicament = provider.medicaments[index];
                return  Column(
                  children: [
                  ListTile(
                  title: Text(medicament.nom,
                      style: TextStyle(fontSize: 13), // Taille de la police

                ),
                  //subtitle: Text('Prix: ${medicament.prix}'),
                  leading: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      medicament.image,
                      fit: BoxFit.cover,
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Action pour modifier le médicament
                          _editMedicament(context, medicament);

                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Action pour supprimer le médicament
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_red_eye),
                        onPressed: () {
                          // Action pour afficher le médicament
                        },
                      ),
                    ],
                  ),
                ),

                    SizedBox(height: 8), // Ajouter un espace de 8 pixels entre chaque médicament

                  ]
                );
              },
            );
          }
        },
      ),


    );

  }
}
