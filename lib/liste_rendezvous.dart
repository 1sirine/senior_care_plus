import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_seniorcare/ajout_rendezvous.dart';

class ListeRendezVousPage extends StatefulWidget {
  const ListeRendezVousPage({super.key});

  @override
  State<ListeRendezVousPage> createState() => _ListeRendezVousPageState();
}

class _ListeRendezVousPageState extends State<ListeRendezVousPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  // Fonction pour récupérer les rendez-vous depuis Firestore
  Stream<QuerySnapshot> _getRendezVous() {
    return _firestore.collection('rendezvous').snapshots();
  }

  // Fonction pour supprimer un rendez-vous
  void _supprimerRendezVous(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer ce rendez-vous ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              _firestore.collection('rendezvous').doc(id).delete();
              Navigator.of(ctx).pop();
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Fonction de modification du rendez-vous
  void _modifierRendezVous(String id, Map<String, dynamic> rdv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AjoutRendezVousPage(
          
        ),
      ),
    );
  }

  // Déconnexion
  Future<void> _deconnecter() async {
    await _auth.signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 55, 146),
        title: const Text("Liste des Rendez-vous", style: TextStyle(color: Colors.white)),
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _deconnecter,
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getRendezVous(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun rendez-vous ajouté.", style: TextStyle(fontSize: 18)));
          }

          final rendezVousList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rendezVousList.length,
            itemBuilder: (context, index) {
              final rdv = rendezVousList[index].data() as Map<String, dynamic>;
              final String id = rendezVousList[index].id;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(rdv['titre'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Text("${rdv['date']} à ${rdv['heure']}\nLieu : ${rdv['lieu']}\nMédecin : ${rdv['medecin']}\nRappel : ${rdv['rappel']}", style: const TextStyle(fontSize: 16)),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'modifier') {
                        _modifierRendezVous(id, rdv);
                      } else if (value == 'supprimer') {
                        _supprimerRendezVous(id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'modifier', child: Text("Modifier")),
                      const PopupMenuItem(value: 'supprimer', child: Text("Supprimer")),
                    ],
                  ),
                ),
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
        backgroundColor: const Color.fromARGB(255, 6, 55, 146),
        child: const Icon(Icons.add),
      ),
    );
  }
}
