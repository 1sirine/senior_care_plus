import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_seniorcare/models/medicament.dart';
import 'ajoutmedicament.dart';

class ListeMedicamentsPage extends StatefulWidget {
  const ListeMedicamentsPage({super.key});

  @override
  State<ListeMedicamentsPage> createState() => _ListeMedicamentsPageState();
}

class _ListeMedicamentsPageState extends State<ListeMedicamentsPage> {
  User? utilisateur;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    utilisateur = FirebaseAuth.instance.currentUser;
    if (utilisateur == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
    setState(() {}); // Pour déclencher le build
  }

  void _ajouterMedicament() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AjoutMedicamentPage()),
    );
    // Aucun setState nécessaire car StreamBuilder écoute les changements Firestore
  }

  void _afficherDetails(Medicament med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(med.nom),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Type : ${med.type}"),
              Text("Médecin : ${med.medecin}"),
              Text("Début : ${med.dateDebut}"),
              Text("Fin : ${med.dateFin}"),
              Text("Heure : ${med.heure}"),
              Text("Fréquence : ${med.frequence}/jour"),
              Text("Quantité : ${med.quantite}"),
              Text("Stock : ${med.stock}"),
              Text("Remarques : ${med.remarques}"),
              Text("Code Barre : ${med.codeBarres}"),
              Text("Notifications : ${med.notifications == true ? 'Oui' : 'Non'}"),
              if (med.ordonnanceImagePath != null &&
                  File(med.ordonnanceImagePath!).existsSync())
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(
                    File(med.ordonnanceImagePath!),
                    height: 100,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Fermer"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (utilisateur == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Médicaments'),
        backgroundColor: Colors.indigo.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medicaments')
            .where('userId', isEqualTo: utilisateur!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun médicament ajouté"));
          }

          final medicamentDocs = snapshot.data!.docs;
          final medicaments = medicamentDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Medicament(
              nom: data['nom'] ?? '',
              type: data['type'] ?? '',
              medecin: data['medecin'] ?? '',
              dateDebut: data['dateDebut'] ?? '',
              dateFin: data['dateFin'] ?? '',
              heure: data['heure'] ?? '',
              frequence: data['frequence'] ?? 0,
              quantite: data['quantite'] ?? 0,
              stock: data['stock'] ?? 0,
              remarques: data['remarques'] ?? '',
              codeBarres: data['codeBarres'] ?? '',
              ordonnanceImagePath: data['ordonnanceImagePath'],
              notifications: data['notifications'] ?? true, nomMedecin: '', utilisation: '', quantiteParPrise: '', stockTotal: '', ordonnancePath: '', notificationsActive: true,
            );
          }).toList();

          return ListView.builder(
            itemCount: medicaments.length,
            itemBuilder: (context, index) {
              final med = medicaments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: ListTile(
                  title: Text(med.nom),
                  subtitle: Text("Dr ${med.medecin} - ${med.type}"),
                  trailing: Text("x${med.quantite}"),
                  onTap: () => _afficherDetails(med),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade900,
        onPressed: _ajouterMedicament,
        child: const Icon(Icons.add),
      ),
    );
  }
}
