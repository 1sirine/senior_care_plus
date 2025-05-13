import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_seniorcare/models/emotion.dart';

class HistoriqueEmotionsPage extends StatelessWidget {
  const HistoriqueEmotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des émotions')),
      body: StreamBuilder(
        // Utilisation de Firestore pour récupérer l'historique en temps réel
        stream: FirebaseFirestore.instance
            .collection('emotions')
            .orderBy('timestamp', descending: true)  // Trie par date (les plus récentes en premier)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final emotions = snapshot.data!.docs.map((doc) {
            return Emotion.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: emotions.length,
            itemBuilder: (context, index) {
              final emotion = emotions[index];
              return ListTile(
                leading: Icon(_getIconData(emotion.icon)),
                title: Text(emotion.emotion),
                subtitle: Text('Le ${emotion.timestamp.toLocal()}'),
              );
            },
          );
        },
      ),
    );
  }

  // Fonction pour retourner l'icône selon le nom
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'joy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
