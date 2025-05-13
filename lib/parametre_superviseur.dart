import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ParametreSuperviseurPage extends StatefulWidget {
  const ParametreSuperviseurPage({super.key});

  @override
  State<ParametreSuperviseurPage> createState() => _ParametreSuperviseurPageState();
}

class _ParametreSuperviseurPageState extends State<ParametreSuperviseurPage> {
  bool notificationsActives = true;
  bool alertesVocalesActives = true;
  String methodeAlerte = 'les deux';

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void sauvegarderParametres() async {
    await firestore.collection('parametres_superviseur').doc('parametres').set({
      'notificationsActives': notificationsActives,
      'alertesVocalesActives': alertesVocalesActives,
      'methodeAlerte': methodeAlerte,
    });
  }

  void envoyerNotificationSuperviseur() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // Cette fonction suppose que tu as déjà configuré FCM
    await messaging.subscribeToTopic("superviseur_notifications");
    // En prod, c'est ton backend qui doit envoyer la vraie notification
    if (kDebugMode) {
      print("Notification fictive envoyée au superviseur");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres Superviseur"),
        backgroundColor: const Color.fromARGB(255, 77, 148, 224),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            switchTile(
              title: "Activer les notifications",
              value: notificationsActives,
              onChanged: (val) => setState(() => notificationsActives = val),
            ),
            switchTile(
              title: "Activer les alertes vocales",
              value: alertesVocalesActives,
              onChanged: (val) => setState(() => alertesVocalesActives = val),
            ),
            const SizedBox(height: 20),
            const Text("Méthode d'alerte :", style: TextStyle(fontSize: 16)),
            methodeAlerteRadio("notification seule"),
            methodeAlerteRadio("voix seule"),
            methodeAlerteRadio("les deux"),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  sauvegarderParametres();
                  envoyerNotificationSuperviseur();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Paramètres sauvegardés")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 13, 107, 154),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text("Enregistrer", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget switchTile({required String title, required bool value, required Function(bool) onChanged}) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color.fromARGB(255, 13, 107, 154),
    );
  }

  Widget methodeAlerteRadio(String value) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: methodeAlerte,
      activeColor: const Color.fromARGB(255, 13, 107, 154),
      onChanged: (val) => setState(() => methodeAlerte = val!),
    );
  }
}
