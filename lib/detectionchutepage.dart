import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialisation de Firebase Cloud Messaging (FCM)
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  // Demander l'autorisation pour recevoir des notifications
  await FirebaseMessaging.instance.requestPermission();

  // Récupérer le token de l'appareil de la superviseure
  String? token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) {
    print("Token de la superviseure : $token");
  }

  runApp(const MyApp());
}

// Handler pour recevoir les notifications en arrière-plan
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Notification en arrière-plan: ${message.notification?.title}");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DetectionChutePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DetectionChutePage extends StatefulWidget {
  const DetectionChutePage({super.key});

  @override
  _DetectionChutePageState createState() => _DetectionChutePageState();
}

class _DetectionChutePageState extends State<DetectionChutePage> {
  bool hasFallen = false;
  DateTime? timeOfFall;
  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    simulateFallDetection();
  }

  // Récupérer l'utilisateur actuel
  Future<void> _getCurrentUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? utilisateur) {
      setState(() {
        user = utilisateur;
      });
    });
  }

  // Simuler la détection de chute
  Future<void> simulateFallDetection() async {
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      hasFallen = true;
      timeOfFall = DateTime.now();
    });

    // Envoyer une notification FCM à la superviseure
    String? superviseurToken = 'TON_TOKEN_DE_SUPERVISEUR';  // Remplacer par le token FCM réel
    sendNotificationToSuperviseur(superviseurToken, 'Une chute a été détectée. Vérifiez immédiatement.');

    await enregistrerChuteDansFirestore();

    // Timer de 7 minutes pour envoi d'alerte prolongée
    Timer(const Duration(minutes: 7), () {
      if (hasFallen) {
        debugPrint('⚠️ Alerte prolongée : la chute n’a pas été annulée.');
        // ➕ À compléter : envoyer SMS / notification FCM ici
      }
    });
  }

  // Fonction pour envoyer la notification FCM
  Future<void> sendNotificationToSuperviseur(String token, String message) async {
    const String serverKey = 'VOTRE_SERVER_KEY_FCM'; // Remplace par ta clé FCM
    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> payload = {
      'to': token,
      'notification': {
        'title': 'Alerte de Chute',
        'body': message,
      },
      'priority': 'high',
    };

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Notification envoyée à la superviseure.');
      }
    } else {
      if (kDebugMode) {
        print('Échec de l’envoi de la notification.');
      }
    }
  }

  // Enregistrer la chute dans Firestore
  Future<void> enregistrerChuteDansFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('chutes').add({
        'userId': user?.uid ?? 'anonyme',
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Chute détectée automatiquement',
      });
      debugPrint('✅ Chute enregistrée dans Firestore.');
    } catch (e) {
      debugPrint('❌ Erreur lors de l’enregistrement de la chute : $e');
    }
  }

  // Annuler l'alerte manuellement
  void annulerAlerte() {
    setState(() {
      hasFallen = false;
      timeOfFall = null;
    });
    debugPrint('✅ Alerte de chute annulée manuellement.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détection de chute'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: hasFallen
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '⚠️ Chute détectée !',
                    style: TextStyle(fontSize: 24, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Heure : ${timeOfFall?.toLocal().toString().substring(0, 19)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: annulerAlerte,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Annuler l’alerte'),
                  ),
                ],
              )
            : const Text(
                '✅ Aucune chute détectée',
                style: TextStyle(fontSize: 24),
              ),
      ),
    );
  }
}
