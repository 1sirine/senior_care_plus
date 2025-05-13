import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_seniorcare/ajoutmedicament.dart';

class MedicamentPage extends StatelessWidget {
  const MedicamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? utilisateur = FirebaseAuth.instance.currentUser;

    // Référence à la collection des médicaments dans Firestore
    final userMedicamentRef = FirebaseFirestore.instance
        .collection('medicaments')
        .where('userId', isEqualTo: utilisateur?.uid);  // Filtrer par l'ID de l'utilisateur

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rappels Médicaments\n${utilisateur?.email ?? ''}",
          textAlign: TextAlign.center,
        ),
        toolbarHeight: 70,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream qui récupère les médicaments en temps réel
        stream: userMedicamentRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun médicament ajouté pour le moment."));
          }

          final medicaments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: medicaments.length,
            itemBuilder: (context, index) {
              final data = medicaments[index].data() as Map<String, dynamic>;
              final nom = data['nom'] ?? 'Non spécifié';
              final type = data['type'] ?? 'Non spécifié';
              final heure = data['heure'] ?? 'Non spécifiée';

              return ListTile(
                title: Text("Médicament: $nom ($type)"),
                subtitle: Text("Heure de prise: $heure"),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjoutMedicamentPage()),
          );
        },
        tooltip: 'Ajouter un médicament',
        child: const Icon(Icons.add),
      ),
    );
  }
}
