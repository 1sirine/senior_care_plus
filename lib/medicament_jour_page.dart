import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ignore: must_be_immutable
class MedicamentsJourPage extends StatefulWidget {
  const MedicamentsJourPage({super.key});

  @override
  State<MedicamentsJourPage> createState() => _MedicamentsJourPageState();
}

class _MedicamentsJourPageState extends State<MedicamentsJourPage> {
  List<Map<String, dynamic>> listeMedicaments = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String nomMedicament) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'prise_channel',
      'Notification de prise de médicament',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Rappel Médicament',
      'Il est temps de prendre votre médicament : $nomMedicament',
      platformChannelSpecifics,
    );
  }

  void _enregistrerPrise(String nom, String heure, String date, String email) async {
    await FirebaseFirestore.instance.collection('historique_medicaments').add({
      'nom': nom,
      'heure_prevue': heure,
      'date': date,
      'email': email,
      'statut': 'pris',
      'heure_prise': DateTime.now().toIso8601String(),
    });
  }

  void _enregistrerNonPrise(String nom, String heure, String date, String email) async {
    await FirebaseFirestore.instance.collection('historique_medicaments').add({
      'nom': nom,
      'heure_prevue': heure,
      'date': date,
      'email': email,
      'statut': 'non pris',
      'heure_detection': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? utilisateur = FirebaseAuth.instance.currentUser;
    final CollectionReference medicamentsCollection = FirebaseFirestore.instance.collection('medicaments');

    return FutureBuilder<QuerySnapshot>(
      future: medicamentsCollection.where('email', isEqualTo: utilisateur?.email).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Médicaments à prendre aujourd'hui\n${utilisateur?.email ?? ''}"),
              backgroundColor: Colors.teal,
              toolbarHeight: 70,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Médicaments à prendre aujourd'hui\n${utilisateur?.email ?? ''}"),
              backgroundColor: Colors.teal,
              toolbarHeight: 70,
            ),
            body: const Center(
              child: Text(
                "Erreur lors du chargement des médicaments.",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
          );
        }

        final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
        listeMedicaments = documents.map((doc) {
          return {
            'nom': doc['nom'],
            'heure': doc['heure'],
            'quantite': doc['quantite'],
            'date': doc['date'],
          };
        }).toList();

        DateTime today = DateTime.now();
        List<Map<String, dynamic>> medicamentsJour = listeMedicaments.where((medicament) {
          DateTime medicamentDate = DateTime.parse(medicament['date']);
          return medicamentDate.year == today.year &&
              medicamentDate.month == today.month &&
              medicamentDate.day == today.day;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text("Médicaments à prendre aujourd'hui\n${utilisateur?.email ?? ''}"),
            backgroundColor: Colors.teal,
            toolbarHeight: 70,
          ),
          body: medicamentsJour.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun médicament à prendre aujourd'hui.",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: medicamentsJour.length,
                  itemBuilder: (context, index) {
                    final medicament = medicamentsJour[index];
                    final nom = medicament['nom'];
                    final heure = medicament['heure'];
                    final date = medicament['date'];
                    final email = utilisateur?.email ?? '';

                    // Calculer le moment de rappel (1h après l'heure prévue)
                    DateTime heurePrevue = DateTime.parse('$date ${heure.padLeft(5, '0')}:00');
                    Duration delai = heurePrevue.add(const Duration(hours: 1)).difference(DateTime.now());

                    if (delai.inSeconds > 0) {
                      Timer(delai, () {
                        _enregistrerNonPrise(nom, heure, date, email);
                      });
                    }

                    // Affichage de la notification immédiate (utile à l'ouverture)
                    _showNotification(nom);

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(nom),
                        subtitle: Text('Heure : $heure\nQuantité : ${medicament['quantite']}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _enregistrerPrise(nom, heure, date, email);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Médicament '$nom' marqué comme pris.")),
                            );
                          },
                          child: const Text("Pris"),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
