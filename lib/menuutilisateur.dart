import 'package:flutter/material.dart';
import 'package:flutter_application_seniorcare/medicament_jour_page.dart';
import 'package:flutter_application_seniorcare/profilepage.dart';
import 'package:flutter_application_seniorcare/rendezvous_jour_page.dart';
import 'package:flutter_application_seniorcare/parametre_utilisateur.dart'; 

class MenuUtilisateurPage extends StatelessWidget {
  const MenuUtilisateurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Menu Utilisateur"),
        backgroundColor: const Color.fromARGB(255, 77, 148, 224),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            customButton(
              context,
              icon: Icons.medication_outlined,
              label: "Médicaments à prendre aujourd'hui",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicamentsJourPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            customButton(
              context,
              icon: Icons.calendar_today_outlined,
              label: "Rendez-vous du jour",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RendezVousJourPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            // 🔧 Nouveau bouton Paramètres
            customButton(
              context,
              icon: Icons.settings,
              label: "Paramètres",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ParametreUtilisateur()),
                );
              },
            ),

            const Spacer(),

            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 77, 148, 224),
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
      ),
    );
  }

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
          backgroundColor: const Color.fromARGB(255, 13, 107, 154),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 60),
        ),
      ),
    );
  }
}
