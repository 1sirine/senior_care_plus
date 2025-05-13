import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/historique_medicament.dart';

class HistoriqueMedicamentPage extends StatelessWidget {
  const HistoriqueMedicamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final utilisateur = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des Médicaments"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('historique_medicaments')
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
              final medoc = HistoriqueMedicament.fromMap(doc.id, doc.data() as Map<String, dynamic>);
              return ListTile(
                title: Text(medoc.nom),
                subtitle: Text('Date : ${medoc.date} - Heure : ${medoc.heure}'),
                trailing: Text("Quantité : ${medoc.quantite}"),
                leading: Icon(
                  medoc.pris ? Icons.check_circle : Icons.cancel,
                  color: medoc.pris ? Colors.green : Colors.red,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
