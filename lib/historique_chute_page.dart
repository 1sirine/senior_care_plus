import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_seniorcare/models/historique_chute.dart';


class HistoriqueChutePage extends StatelessWidget {
  const HistoriqueChutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des chutes'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chutes')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("Aucune chute enregistrée."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final chute = HistoriqueChute.fromFirestore(data, docs[index].id);

              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(chute.message),
                subtitle: Text(
                  'Date : ${chute.timestamp.toLocal().toString().substring(0, 19)}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
