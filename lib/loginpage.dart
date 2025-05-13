import 'package:flutter/material.dart';
import 'package:flutter_application_seniorcare/roleselectionpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inscriptionpage.dart';
import 'motdepasseoubliepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool passwordVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isEmailValid(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Veuillez remplir tous les champs.");
      return;
    }

    if (!isEmailValid(email)) {
      _showMessage("Adresse e-mail invalide.");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      final doc = await FirebaseFirestore.instance.collection('utilisateurs').doc(userId).get();

      if (doc.exists) {
        _showMessage("Connexion réussie !");
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      } else {
        _showMessage("Utilisateur non trouvé.");
      }
    } catch (e) {
      String messageErreur = "Une erreur est survenue.";

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            messageErreur = "Aucun utilisateur trouvé avec cet e-mail.";
            break;
          case 'wrong-password':
            messageErreur = "Mot de passe incorrect.";
            break;
          case 'invalid-email':
            messageErreur = "Adresse e-mail invalide.";
            break;
          default:
            messageErreur = "Erreur : ${e.message}";
        }
      }

      _showMessage(messageErreur);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/login.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 60),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Adresse e-mail",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: !passwordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Mot de passe",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 4, 37, 93),
                        foregroundColor: const Color.fromARGB(255, 247, 246, 246),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MotDePasseOubliePage()),
                        );
                      },
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(color: Color.fromARGB(255, 4, 56, 124)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InscriptionPage()),
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: "Vous n'avez pas de compte ? ",
                          style: TextStyle(color: Color.fromARGB(255, 4, 56, 124)),
                          children: [
                            TextSpan(
                              text: "Inscrivez-vous",
                              style: TextStyle(
                                color: Color.fromARGB(255, 30, 150, 242),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "Retour à la page précédente",
                    style: TextStyle(color: Color.fromARGB(255, 4, 38, 112)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
