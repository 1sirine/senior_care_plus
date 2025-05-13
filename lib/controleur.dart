import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_seniorcare/models/medicament.dart';
import 'package:flutter_application_seniorcare/models/rendezvous.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ControleurRappels {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  ControleurRappels(this.flutterLocalNotificationsPlugin);

  Future<void> initialiserNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> envoyerNotification(String titre, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'canal_rappel',
      'Rappels Médicaments',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      titre,
      message,
      platformChannelSpecifics,
    );
  }

  Future<void> verifierEtEnvoyerRappels(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final param = await _firestore
        .collection('parametres_utilisateur')
        .doc(user.uid)
        .get();

    final data = param.data();
    if (data == null) return;

    final role = data['role']; // "utilisateur" ou "superviseur"
    final rappelsActifs = data['rappelsActifs'] ?? true;
    final notificationsActives = data['notificationsActives'] ?? true;
    final messagesVocauxActifs = data['messagesVocauxActifs'] ?? true;

    if (!rappelsActifs) return;

    final now = DateTime.now();

    // 🔔 Rappels Médicaments
    final medicamentsSnapshot = await _firestore
        .collection('utilisateurs')
        .doc(user.uid)
        .collection('medicaments')
        .get();

    for (final doc in medicamentsSnapshot.docs) {
      final medicament = Medicament.fromFirestore(doc);

      if (_doitAfficherRappel(medicament, now)) {
        if (role == 'utilisateur' && messagesVocauxActifs) {
          _afficherAlertDialog(context, medicament.nom);
        }

        if ((role == 'utilisateur' || role == 'superviseur') &&
            notificationsActives) {
          await envoyerNotification(
            'Rappel Médicament',
            'Prenez votre médicament : ${medicament.nom}',
          );
        }
      }
    }

    // 📅 Rappels Rendez-vous
    final rdvSnapshot = await _firestore
        .collection('utilisateurs')
        .doc(user.uid)
        .collection('rendezvous')
        .get();

    for (final doc in rdvSnapshot.docs) {
      final rdv = RendezVous.fromFirestore(doc);

      if (_estAujourdHui(rdv.date)) {
        if ((role == 'utilisateur' || role == 'superviseur') &&
            notificationsActives) {
          await envoyerNotification(
            'Rappel Rendez-vous',
            'Vous avez un rendez-vous à ${rdv.heure}',
          );
        }
      }
    }

    // 🚨 Alerte d'urgence (exemple simulation)
    if (role == 'superviseur') {
      final urgenceSnapshot =
          await _firestore.collection('alertes_urgentes').doc(user.uid).get();

      if (urgenceSnapshot.exists) {
        await envoyerNotification(
          'Alerte Urgence',
          'Une chute ou urgence a été détectée !',
        );
      }
    }
  }

  void _afficherAlertDialog(BuildContext context, String nomMedicament) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rappel Médicament'),
        content: Text('Il est temps de prendre : $nomMedicament'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  bool _doitAfficherRappel(Medicament medicament, DateTime maintenant) {
    // À adapter avec heure et fréquence du médicament
    final heureMedicament = TimeOfDay.fromDateTime(medicament.heure as DateTime);
    final heureActuelle = TimeOfDay.fromDateTime(maintenant);

    return heureMedicament.hour == heureActuelle.hour &&
        heureMedicament.minute == heureActuelle.minute;
  }

  bool _estAujourdHui(DateTime date) {
    final maintenant = DateTime.now();
    return date.year == maintenant.year &&
        date.month == maintenant.month &&
        date.day == maintenant.day;
  }
}
