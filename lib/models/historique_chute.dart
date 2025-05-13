import 'package:cloud_firestore/cloud_firestore.dart';

class HistoriqueChute {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String message;

  HistoriqueChute({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.message,
  });

  factory HistoriqueChute.fromFirestore(Map<String, dynamic> data, String docId) {
    return HistoriqueChute(
      id: docId,
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      message: data['message'] ?? '',
    );
  }
}
