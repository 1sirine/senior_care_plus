import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EtatEmotionnelPage extends StatelessWidget {
  const EtatEmotionnelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final uid = user.uid;
    final emotionsRef = FirebaseFirestore.instance
        .collection('emotions')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 12, 98, 152),
        title: const Text(
          'Etat Emotionnel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: emotionsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("Aucune émotion détectée."),
            );
          }

          final latest = docs.first;
          final latestEmotion = latest['emotion'];
          final latestTimestamp = (latest['timestamp'] as Timestamp).toDate();
          final latestIcon = _getIconData(latest['icon']);
          final formattedDate =
              DateFormat('d MMMM yyyy, HH:mm', 'fr_FR').format(latestTimestamp);

          return Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen[100],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(latestIcon, size: 70, color: Colors.green),
                      const SizedBox(height: 10),
                      Text(
                        latestEmotion,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Dernière mise à jour : $formattedDate',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Historique des émotions',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 12, 98, 152)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final emotion = doc['emotion'];
                    final icon = _getIconData(doc['icon']);
                    final date = (doc['timestamp'] as Timestamp).toDate();
                    final dateStr =
                        DateFormat('d MMM yyyy, HH:mm').format(date);

                    final bgColor = _getBackgroundColor(emotion);
                    final iconColor = _getIconColor(emotion);

                    return emotionItem(emotion, dateStr, icon, bgColor, iconColor);
                  },
                ),
              ),
              if (latestEmotion.toLowerCase() == 'triste')
                Container(
                  width: double.infinity,
                  color: Colors.red[300],
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Alerte ! Emotion critique détectée : Triste (${DateFormat('HH:mm').format(latestTimestamp)})',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget emotionItem(String emotion, String date, IconData icon, Color? bgColor,
      Color? iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                emotion,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'sentiment_dissatisfied':
        return Icons.sentiment_dissatisfied;
      case 'sentiment_neutral':
        return Icons.sentiment_neutral;
      case 'sentiment_very_dissatisfied':
        return Icons.sentiment_very_dissatisfied;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied;
      default:
        return Icons.sentiment_satisfied_alt;
    }
  }

  Color? _getBackgroundColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'triste':
        return Colors.blue[100];
      case 'stressé':
        return Colors.yellow[100];
      case 'en colère':
        return Colors.red[100];
      case 'heureux':
        return Colors.lightGreen[100];
      default:
        return Colors.grey[200];
    }
  }

  Color? _getIconColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'triste':
        return Colors.blue;
      case 'stressé':
        return Colors.orange;
      case 'en colère':
        return Colors.red;
      case 'heureux':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}
