import 'package:cloud_firestore/cloud_firestore.dart';
class Emotion {
  final String emotion;
  final String icon;
  final DateTime timestamp;

  Emotion({
    required this.emotion,
    required this.icon,
    required this.timestamp,
  });

  // Méthode pour convertir Firestore en objet Emotion
  factory Emotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Emotion(
      emotion: data['emotion'] ?? '',
      icon: data['icon'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

   // Méthode fromMap pour créer une instance de Emotion à partir d'un Map
  static Emotion fromMap(Map<String, dynamic> data) {
    return Emotion(
      emotion: data['emotion'] ?? '',
      icon: data['icon'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
