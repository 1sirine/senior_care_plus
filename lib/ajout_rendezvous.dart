import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AjoutRendezVousPage extends StatefulWidget {
  const AjoutRendezVousPage({Key? key}) : super(key: key);

  @override
  _AjoutRendezVousPageState createState() => _AjoutRendezVousPageState();
}

class _AjoutRendezVousPageState extends State<AjoutRendezVousPage> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _reminderOptions = [
    "1 jour avant",
    "2 jours avant",
    "1 heure avant",
    "30 min avant"
  ];
  final List<String> _selectedReminders = [];

  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    setState(() {
      user = currentUser;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 55, 146),
        title: const Text(
          "Ajouter un Rendez-vous",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            user != null
                ? Text('Connecté en tant que: ${user!.email}')
                : const Text('Veuillez vous connecter.'),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Titre du rendez-vous"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: "Lieu"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _doctorController,
              decoration: const InputDecoration(labelText: "Nom du médecin"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: "Notes"),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            ListTile(
              title: Text(_selectedDate == null
                  ? "Sélectionner une date"
                  : "Date : ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),

            ListTile(
              title: Text(_selectedTime == null
                  ? "Sélectionner une heure"
                  : "Heure : ${_selectedTime!.format(context)}"),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
            const SizedBox(height: 20),

            const Text("Rappels :"),
            Wrap(
              spacing: 8.0,
              children: _reminderOptions.map((option) {
                final isSelected = _selectedReminders.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedReminders.add(option);
                      } else {
                        _selectedReminders.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez vous connecter')),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('rendezvous').add({
                    'userId': user!.uid,
                    'titre': _titleController.text,
                    'lieu': _locationController.text,
                    'medecin': _doctorController.text,
                    'notes': _notesController.text,
                    'date': _selectedDate?.toIso8601String(),
                    'heure': _selectedTime != null
                        ? '${_selectedTime!.hour}:${_selectedTime!.minute}'
                        : null,
                    'rappels': _selectedReminders,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rendez-vous enregistré avec succès')),
                  );

                  _titleController.clear();
                  _locationController.clear();
                  _doctorController.clear();
                  _notesController.clear();
                  setState(() {
                    _selectedDate = null;
                    _selectedTime = null;
                    _selectedReminders.clear();
                  });
                } catch (e) {
                  if (kDebugMode) {
                    print("Erreur lors de l'enregistrement : $e");
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 6, 55, 146),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: const Text("Ajouter le rendez-vous"),
            ),
          ],
        ),
      ),
    );
  }
}
