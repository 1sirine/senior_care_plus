import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'homepage.dart';

// Initialisation de la notification locale
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Code exécuté lorsque l'application est en arrière-plan ou terminée
  if (kDebugMode) {
    print("Received background message: ${message.notification?.title}");
  }
  showNotification(message.notification?.title ?? "Nouvelle Notification", message.notification?.body ?? "");
}

void setupFirebaseMessaging() async {
  // Initialisation de Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      if (kDebugMode) {
        print('Notification reçue : ${message.notification?.title}');
      }
      showNotification(message.notification?.title ?? "Nouvelle notification", message.notification?.body ?? "Aucun corps");
    }
  });
}

void setupLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void showNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    channelDescription: 'channel_description',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformDetails,
    payload: 'item x', // Données supplémentaires
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //  Initialisation de Firebase
  setupLocalNotifications(); // Initialisation des notifications locales
  setupFirebaseMessaging(); // Configuration des notifications Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Robot Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 4, 37, 93),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}
