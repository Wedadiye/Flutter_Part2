
import 'dart:convert';
import 'package:flutter/material.dart';
import './Provider/AuthProvider.dart' ;
import 'package:provider/provider.dart';

import 'Models/medicament.dart';
import 'Screens/Crud/AjouterMedicament.dart';
import 'Screens/Crud/ListeMedicaments.dart';
import 'Screens/Crud/ModifierMedicament.dart';
import 'Screens/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PharmacieProvider()), // Ajoutez votre provider de pharmacie ici
          ChangeNotifierProvider(create: (_) => MedicamentProvider()), // Assurez-vous d'ajouter MedicamentProvider
          ChangeNotifierProvider(create: (_) => ImagePickerProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),

          // Ajoutez d'autres providers si nécessaire
        ],
      child: MaterialApp(
        title: 'Login App',
        initialRoute: '/login', // Définissez la route initiale sur la page de connexion
        routes: {
          '/login': (context) => LoginPage(), // Configurez la route pour la page de connexion
          '/medication_crud': (context) => MedicationCRUDPage(),
          '/add_medicament': (context) => AddMedicamentPage(),
         // '/edit_medicament': (context) => EditMedicamentPage(), // Ajoutez votre route pour EditMedicamentPage ici

          '/edit_medicament': (context) {
            // Récupérez l'argument Medicament passé avec la route
            final Medicament medicament = ModalRoute.of(context)!.settings.arguments as Medicament;
            // Retournez votre page en lui passant l'argument Medicament
            return EditMedicamentPage(medicament: medicament);
          },
// Configurez la route pour la page MedicationCRUDPage
          // Ajoutez d'autres routes si nécessaire

        },
      ),
    );
  }
}