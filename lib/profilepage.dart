import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ajout Firestore

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _motdepasseController = TextEditingController();
  final TextEditingController _confirmerMotdepasseController = TextEditingController();
  final TextEditingController _paysController = TextEditingController();

  String _role = "Personne âgée";

  final Color bleuMarine = const Color(0xFF003366);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> _selectImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pop(context);
  }

  Future<void> _saveProfile() async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('utilisateurs').doc(currentUser!.uid).set({
        'uid': currentUser!.uid,
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'telephone': _telController.text,
        'adresse': _adresseController.text,
        'motdepasse': _motdepasseController.text,
        'confirmerMotdepasse': _confirmerMotdepasseController.text,
        'pays': _paysController.text,
        'role': _role,
        'email': currentUser!.email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Données sauvegardées")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: bleuMarine,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            _buildTextField("Nom", _nomController),
            _buildTextField("Prénom", _prenomController),
            _buildTextField("Téléphone", _telController, type: TextInputType.phone),
            _buildTextField("Adresse", _adresseController),
            _buildTextField("Mot de passe", _motdepasseController, isPassword: true),
            _buildTextField("Confirmer le mot de passe", _confirmerMotdepasseController, isPassword: true),
            _buildTextField("Pays", _paysController),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Rôle", style: TextStyle(fontWeight: FontWeight.bold, color: bleuMarine)),
            ),
            _buildRadio("Personne âgée"),
            _buildRadio("Membre familial"),
            _buildRadio("Médecin"),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: bleuMarine,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("Sauvegarder les données", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: bleuMarine,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Se déconnecter", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: bleuMarine),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: bleuMarine),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: bleuMarine, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildRadio(String value) {
    return RadioListTile<String>(
      title: Text(value),
      activeColor: bleuMarine,
      value: value,
      groupValue: _role,
      onChanged: (val) {
        setState(() {
          _role = val!;
        });
      },
    );
  }
}
