import 'package:flutter/material.dart';
import 'acceuil.dart'; // nouvelle page à afficher après clic

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image plein écran
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Bouton en bas de l'écran
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 165, 216),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AcceuilPage()),
                );
              },
              child: const Text(
                "Démarrer l'application",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}