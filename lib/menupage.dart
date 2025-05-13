import 'package:flutter/material.dart';
import 'package:flutter_application_seniorcare/RendezVousPage.dart';
import 'package:flutter_application_seniorcare/detectionchutepage.dart';
import 'package:flutter_application_seniorcare/medicamentpage.dart';
import 'package:flutter_application_seniorcare/profilepage.dart';
import 'package:flutter_application_seniorcare/etatemotionnelpage.dart';
import 'package:flutter_application_seniorcare/parametre_superviseur.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc
      body: Column(
        children: [
          // Barre du haut
          Container(
            color: const Color.fromARGB(255, 12, 98, 152), // Bleu marine
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Menu Principal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Icône Paramètres
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ParametreSuperviseurPage()),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.settings, color: Colors.white, size: 28),
                  ),
                ),
                // Icône Profil
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color.fromARGB(255, 12, 98, 152)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Bouton : Rappel Médicaments
          customButton(
            context,
            icon: Icons.medication_outlined,
            label: "Rappel Médicaments",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedicamentPage()),
              );
            },
          ),

          const SizedBox(height: 30),

          // Bouton : Rappel Rendez-vous
          customButton(
            context,
            icon: Icons.calendar_today_outlined,
            label: "Rappel Rendez-vous",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RendezVousPage()),
              );
            },
          ),

          const SizedBox(height: 30),

          // Bouton : Détection Chute
          customButton(
            context,
            icon: Icons.warning_amber_rounded,
            label: "Détection Chute",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetectionChutePage()),
              );
            },
          ),

          const SizedBox(height: 30),

          // Bouton : État Émotionnel
          customButton(
            context,
            icon: Icons.mood,
            label: "État Émotionnel",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EtatEmotionnelPage()),
              );
            },
          ),

          const Spacer(),

          // Bouton retour en bas
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 12, 98, 152),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "← Retour",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire les boutons avec icône
  Widget customButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 65, 168, 232),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 60),
        ),
      ),
    );
  }
}
