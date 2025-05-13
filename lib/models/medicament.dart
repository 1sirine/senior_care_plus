import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Medicament {
  String nom;
  String nomMedecin;
  String utilisation;
  String type;
  String dateDebut;
  String dateFin;
  String heure;
  String frequence;
  String quantiteParPrise;
  String stockTotal;
  String remarques;
  String ordonnancePath; // chemin de l'image
  String codeBarres;
  bool notificationsActive;

  Medicament({
    required this.nom,
    required this.nomMedecin,
    required this.utilisation,
    required this.type,
    required this.dateDebut,
    required this.dateFin,
    required this.heure,
    required this.frequence,
    required this.quantiteParPrise,
    required this.stockTotal,
    required this.remarques,
    required this.ordonnancePath,
    required this.codeBarres,
    required this.notificationsActive, required medecin, required notifications, required ordonnanceImagePath, required quantite, required stock,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'nomMedecin': nomMedecin,
      'utilisation': utilisation,
      'type': type,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'heure': heure,
      'frequence': frequence,
      'quantiteParPrise': quantiteParPrise,
      'stockTotal': stockTotal,
      'remarques': remarques,
      'ordonnancePath': ordonnancePath,
      'codeBarres': codeBarres,
      'notificationsActive': notificationsActive,
    };
  }

  factory Medicament.fromJson(Map<String, dynamic> json) {
    return Medicament(
      nom: json['nom'],
      nomMedecin: json['nomMedecin'],
      utilisation: json['utilisation'],
      type: json['type'],
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      heure: json['heure'],
      frequence: json['frequence'],
      quantiteParPrise: json['quantiteParPrise'],
      stockTotal: json['stockTotal'],
      remarques: json['remarques'],
      ordonnancePath: json['ordonnancePath'],
      codeBarres: json['codeBarres'],
      notificationsActive: json['notificationsActive'], medecin: null, notifications: null, ordonnanceImagePath: null, quantite: null, stock: null,
    );
  }

  // Méthode pour enregistrer ce médicament dans Firestore avec l'utilisateur connecté
  Future<void> saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicaments')
          .doc(); // ID auto-généré

      await docRef.set(toJson());
    } else {
      throw Exception("Utilisateur non connecté.");
    }
  }

  static Future<List<Medicament>> getMedicamentsFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicaments')
          .get();

      return snapshot.docs
          .map((doc) => Medicament.fromJson(doc.data()))
          .toList();
    } else {
      throw Exception("Utilisateur non connecté.");
    }
  }

  get medecin => null;
  get quantite => null;
  get stock => null;
  bool? get notifications => null;
  get ordonnanceImagePath => null;

  static fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}
