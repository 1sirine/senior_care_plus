import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_seniorcare/models/histrique_rendezvous.dart';

class HistoriqueRendezVousPage extends StatelessWidget {
  const HistoriqueRendezVousPage({super.key});

  @override
  Widget build(BuildContext context) {
    final utilisateur = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des Rendez-vous"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('historique_rendezvous')
            .where('email', isEqualTo: utilisateur?.email)
            .orderBy('date', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text("Erreur lors du chargement des données."),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Aucun historique trouvé."));
          }

          return ListView(
            children: docs.map((doc) {
              final rdv = HistoriqueRendezVous.fromMap(doc.id, doc.data() as Map<String, dynamic>);
              return ListTile(
                title: Text(rdv.titre),
                subtitle: Text('Date : ${rdv.date} - Heure : ${rdv.heure}\nLieu : ${rdv.lieu}'),
                leading: Icon(
                  rdv.effectue ? Icons.check_circle : Icons.cancel,
                  color: rdv.effectue ? Colors.green : Colors.red,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
