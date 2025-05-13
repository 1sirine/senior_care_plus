import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ParametreUtilisateur extends StatefulWidget {
  const ParametreUtilisateur({super.key});

  @override
  _ParametreUtilisateurState createState() => _ParametreUtilisateurState();
}

class _ParametreUtilisateurState extends State<ParametreUtilisateur> {
  bool rappelsActifs = true;
  bool notificationsActives = true;
  bool messagesVocauxActifs = true;
  String langue = 'Français';

  final List<String> languesDisponibles = ['Français', 'Arabe', 'Anglais'];

  static const Color bleuCiel = Color(0xFF87CEEB);
  static const Color bleuMarine = Color(0xFF003366);

  // Initialisation de Firebase Cloud Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // Demande d'autorisation pour les notifications push
    _firebaseMessaging.requestPermission();

    // Gestion de la réception de la notification en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Gestion de la réception de la notification en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotificationDialog(message.notification!.title, message.notification!.body);
      }
    });
  }

  // Fonction pour gérer la réception des notifications en arrière-plan
  Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    if (kDebugMode) {
      print("Notification reçue en arrière-plan: ${message.notification?.title}");
    }
    // Afficher un message ou un Dialog quand la notification est reçue en arrière-plan
  }

  // Fonction pour afficher un AlertDialog avec le contenu de la notification
  void _showNotificationDialog(String? title, String? body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Alerte'),
          content: Text(body ?? 'Vous avez reçu une notification.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fonction pour enregistrer les paramètres de l'utilisateur
  void enregistrerParametres() async {
    final utilisateur = FirebaseAuth.instance.currentUser;

    if (utilisateur != null) {
      await FirebaseFirestore.instance
          .collection('parametres_utilisateur')
          .doc(utilisateur.uid)
          .set({
        'rappelsActifs': rappelsActifs,
        'notificationsActives': notificationsActives,
        'messagesVocauxActifs': messagesVocauxActifs,
        'langue': langue,
        'dateEnregistrement': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres enregistrés avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion requise pour enregistrer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bleuCiel.withOpacity(0.1),
      appBar: AppBar(
        title: const Text('Paramètres des rappels'),
        backgroundColor: bleuMarine,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Activer les rappels médicaux'),
              activeColor: bleuMarine,
              value: rappelsActifs,
              onChanged: (val) {
                setState(() {
                  rappelsActifs = val;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Activer les notifications téléphone'),
              activeColor: bleuMarine,
              value: notificationsActives,
              onChanged: (val) {
                setState(() {
                  notificationsActives = val;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Activer les messages vocaux'),
              activeColor: bleuMarine,
              value: messagesVocauxActifs,
              onChanged: (val) {
                setState(() {
                  messagesVocauxActifs = val;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Langue du message vocal',
                border: OutlineInputBorder(),
              ),
              value: langue,
              items: languesDisponibles
                  .map((lang) =>
                      DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    langue = val;
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: enregistrerParametres,
              style: ElevatedButton.styleFrom(
                backgroundColor: bleuMarine,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Enregistrer',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
