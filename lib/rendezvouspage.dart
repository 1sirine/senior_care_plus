import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_seniorcare/ajout_rendezvous.dart';

class RendezVousPage extends StatelessWidget {
  const RendezVousPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? utilisateur = FirebaseAuth.instance.currentUser;

    // Référence à la collection des rendez-vous dans Firestore
    final userRendezVousRef = FirebaseFirestore.instance
        .collection('rendezvous')
        .where('userId', isEqualTo: utilisateur?.uid);  // Filtrer par l'ID de l'utilisateur

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rappels Rendez-vous\n${utilisateur?.email ?? ''}",
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream qui récupère les rendez-vous en temps réel
        stream: userRendezVousRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun rendez-vous pour l’instant."));
          }

          final rendezvous = snapshot.data!.docs;
          return ListView.builder(
            itemCount: rendezvous.length,
            itemBuilder: (context, index) {
              final data = rendezvous[index].data() as Map<String, dynamic>;
              final date = data['date'] ?? 'Non spécifiée';
              final heure = data['heure'] ?? 'Non spécifiée';

              return ListTile(
                title: Text("Rendez-vous: $date à $heure"),
                subtitle: Text(data['description'] ?? 'Pas de description'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjoutRendezVousPage()),
          );
        },
        tooltip: 'Ajouter un rendez-vous',
        child: const Icon(Icons.add),
      ),
    );
  }
}
