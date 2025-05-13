import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RendezVous {
  String titre;
  DateTime date;
  TimeOfDay heure;
  String lieu;
  String nomMedecin;
  String remarques;
  String type;
  int rappelAvantJours;
  bool notificationsEnabled;

  RendezVous({
    required this.titre,
    required this.date,
    required this.heure,
    required this.lieu,
    required this.nomMedecin,
    required this.remarques,
    required this.type,
    required this.rappelAvantJours,
    required this.notificationsEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'date': date.toIso8601String(),
      'heure': '${heure.hour}:${heure.minute.toString().padLeft(2, '0')}',
      'lieu': lieu,
      'nomMedecin': nomMedecin,
      'remarques': remarques,
      'type': type,
      'rappelAvantJours': rappelAvantJours,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  static RendezVous fromMap(Map<String, dynamic> map) {
    return RendezVous(
      titre: map['titre'],
      date: DateTime.parse(map['date']),
      heure: TimeOfDay(
        hour: int.parse(map['heure'].split(':')[0]),
        minute: int.parse(map['heure'].split(':')[1]),
      ),
      lieu: map['lieu'],
      nomMedecin: map['nomMedecin'],
      remarques: map['remarques'],
      type: map['type'],
      rappelAvantJours: map['rappelAvantJours'],
      notificationsEnabled: map['notificationsEnabled'],
    );
  }

  // Enregistre ce rendez-vous dans Firestore pour l'utilisateur connecté
  Future<void> saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('rendezvous')
          .doc(); // ID auto-généré

      await docRef.set(toMap());
    } else {
      throw Exception("Utilisateur non connecté.");
    }
  }

  // Récupère tous les rendez-vous de l'utilisateur connecté depuis Firestore
  static Future<List<RendezVous>> getRendezVousFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('rendezvous')
          .get();

      return snapshot.docs
          .map((doc) => RendezVous.fromMap(doc.data()))
          .toList();
    } else {
      throw Exception("Utilisateur non connecté.");
    }
  }

  static fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}
