import 'package:flutter/material.dart';
import 'package:flutter_application_seniorcare/loginpage.dart';
// ignore: depend_on_referenced_packages

class AcceuilPage extends StatelessWidget {
  const AcceuilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond plein écran
          SizedBox.expand(
            child: Image.asset(
              'assets/images/acceuil.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Ligne contenant les deux flèches
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔙 Flèche gauche : retour à la page précédente
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 40, color: Color.fromARGB(255, 231, 233, 235)),
                  onPressed: () {
                    Navigator.pop(context); // Retour à la page précédente
                  },
                ),

                // 🔜 Flèche droite : aller vers la page Login
                IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 40, color: Color.fromARGB(255, 233, 235, 236)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}