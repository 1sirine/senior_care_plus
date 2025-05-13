import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RendezVousJourPage extends StatelessWidget {
  RendezVousJourPage({super.key});

  List<Map<String, dynamic>> listeRendezVous = [];

  @override
  Widget build(BuildContext context) {
    final User? utilisateur = FirebaseAuth.instance.currentUser;
    final CollectionReference rendezVousCollection =
        FirebaseFirestore.instance.collection('rendezvous');

    return FutureBuilder<QuerySnapshot>(
      future: rendezVousCollection
          .where('email', isEqualTo: utilisateur?.email)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title:
                  Text("Rendez-vous du jour\n${utilisateur?.email ?? ''}"),
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
              title:
                  Text("Rendez-vous du jour\n${utilisateur?.email ?? ''}"),
              backgroundColor: Colors.teal,
              toolbarHeight: 70,
            ),
            body: const Center(
              child: Text(
                "Erreur lors du chargement des rendez-vous.",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
          );
        }

        final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
        listeRendezVous = documents.map((doc) {
          return {
            'id': doc.id,
            'titre': doc['titre'],
            'heure': doc['heure'],
            'lieu': doc['lieu'],
            'date': doc['date'],
            'effectué': doc['effectué'] ?? false,
          };
        }).toList();

        DateTime today = DateTime.now();
        List<Map<String, dynamic>> rendezVousJour = listeRendezVous.where(
          (rendezVousItem) {
            DateTime rendezVousDate = DateTime.parse(rendezVousItem['date']);
            return rendezVousDate.year == today.year &&
                rendezVousDate.month == today.month &&
                rendezVousDate.day == today.day;
          },
        ).toList();

        return Scaffold(
          appBar: AppBar(
            title:
                Text("Rendez-vous du jour\n${utilisateur?.email ?? ''}"),
            backgroundColor: Colors.teal,
            toolbarHeight: 70,
          ),
          body: rendezVousJour.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun rendez-vous aujourd'hui.",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: rendezVousJour.length,
                  itemBuilder: (context, index) {
                    final rendezVous = rendezVousJour[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(rendezVous['titre']),
                        subtitle: Text(
                          'Heure : ${rendezVous['heure']}\nLieu : ${rendezVous['lieu']}',
                        ),
                        trailing: rendezVous['effectué']
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : ElevatedButton(
                                onPressed: () async {
                                  try {
                                    // Marquer comme effectué dans "rendezvous"
                                    await FirebaseFirestore.instance
                                        .collection('rendezvous')
                                        .doc(rendezVous['id'])
                                        .update({'effectué': true});

                                    // Enregistrer dans "historique_rendezvous"
                                    await FirebaseFirestore.instance
                                        .collection('historique_rendezvous')
                                        .add({
                                      'email': utilisateur?.email,
                                      'titre': rendezVous['titre'],
                                      'date': rendezVous['date'],
                                      'heure': rendezVous['heure'],
                                      'lieu': rendezVous['lieu'],
                                      'effectué': true,
                                      'timestamp': Timestamp.now(),
                                    });

                                    // Message de confirmation
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Rendez-vous marqué comme effectué."),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Erreur lors de l'enregistrement : $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                                child: const Text("Aller au rendez-vous"),
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
