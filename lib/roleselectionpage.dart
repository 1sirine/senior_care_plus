import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Importation de Firestore
import 'package:firebase_auth/firebase_auth.dart';  // Importation de Firebase Auth
import 'package:flutter_application_seniorcare/menupage.dart';
import 'package:flutter_application_seniorcare/menuutilisateur.dart'; // Assurez-vous d'importer MenuUtilisateurPage

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Future<void> _enregistrerRole(String role) async {
    // Récupérer l'utilisateur actuellement connecté
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Enregistrer le rôle de l'utilisateur dans Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'role': role,  // Enregistrement du rôle choisi (superviseur/utilisateur)
        }, SetOptions(merge: true));

        // Affichage d'un message de succès
        if (kDebugMode) {
          print("Rôle $role enregistré avec succès !");
        }
      } catch (e) {
        // Gestion des erreurs
        if (kDebugMode) {
          print("Erreur lors de l'enregistrement du rôle : $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366), // Bleu marine
      appBar: AppBar(
        title: const Text(
          'Choisissez votre rôle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF003366),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Veuillez sélectionner votre rôle pour continuer',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            // Bouton Superviseur
            ElevatedButton(
              onPressed: () async {
                await _enregistrerRole('superviseur');  // Enregistrement du rôle Superviseur dans Firestore
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF003366),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Se connecter comme Superviseur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Bouton Utilisateur
            ElevatedButton(
              onPressed: () async {
                await _enregistrerRole('utilisateur');  // Enregistrement du rôle Utilisateur dans Firestore
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuUtilisateurPage()), // Navigation vers MenuUtilisateurPage
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF003366),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Se connecter comme Utilisateur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
