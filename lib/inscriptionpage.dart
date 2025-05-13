import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _confirmerMotDePasseController = TextEditingController();
  final _numeroTelephoneController = TextEditingController();
  final _paysController = TextEditingController();

  String? _role;
  bool _accepterConditions = false;
  File? _imageFile;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    _confirmerMotDePasseController.dispose();
    _numeroTelephoneController.dispose();
    _paysController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _uploadImageToStorage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      if (kDebugMode) print("Erreur d'upload image: $e");
      return null;
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _inscrire() async {
    if (_formKey.currentState!.validate() && _accepterConditions && _role != null) {
      _showLoadingDialog();
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _motDePasseController.text.trim(),
        );

        String? photoURL;
        if (_imageFile != null) {
          photoURL = await _uploadImageToStorage(_imageFile!);
        }

        await FirebaseFirestore.instance.collection('utilisateurs').doc(userCredential.user!.uid).set({
          'nom': _nomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'email': _emailController.text.trim(),
          'numeroTelephone': _numeroTelephoneController.text.trim(),
          'pays': _paysController.text.trim(),
          'role': _role,
          'photoProfil': photoURL ?? '',
        });

        if (mounted) Navigator.pop(context); // Fermer le loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte créé avec succès')),
        );
        if (mounted) Navigator.pop(context); // Retour à la page précédente
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        String message = "Une erreur est survenue";
        if (e.code == 'email-already-in-use') {
          message = "Cet email est déjà utilisé.";
        } else if (e.code == 'weak-password') {
          message = "Mot de passe trop faible.";
        } else {
          message = e.message ?? message;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et accepter les conditions.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Page d'inscription", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null ? const Icon(Icons.add_a_photo, size: 30) : null,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nomController, "Nom"),
                  _buildTextField(_prenomController, "Prénom"),
                  _buildTextField(_numeroTelephoneController, "Téléphone", keyboardType: TextInputType.phone),
                  _buildTextField(_emailController, "Email", keyboardType: TextInputType.emailAddress),
                  _buildTextField(_motDePasseController, "Mot de passe", isPassword: true),
                  _buildTextField(_confirmerMotDePasseController, "Confirmer mot de passe", isPassword: true),
                  _buildTextField(_paysController, "Pays"),
                  _buildDropdownField(),
                  Row(
                    children: [
                      Checkbox(
                        value: _accepterConditions,
                        onChanged: (value) {
                          setState(() {
                            _accepterConditions = value!;
                          });
                        },
                      ),
                      const Text("Accepter les conditions"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _inscrire,
                    child: const Text("Créer un compte"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Déjà inscrit ? Connectez-vous"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez entrer $label';
          }
          if (label == "Confirmer mot de passe" && value != _motDePasseController.text) {
            return "Les mots de passe ne correspondent pas";
          }
          if (label == "Email" && !value.contains("@")) {
            return "Veuillez entrer un email valide";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _role,
        items: ['Personne âgée', 'Proche', 'Médecin'].map((role) {
          return DropdownMenuItem(
            value: role,
            child: Text(role),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _role = value;
          });
        },
        decoration: const InputDecoration(
          labelText: "Rôle",
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null ? 'Veuillez choisir un rôle' : null,
      ),
    );
  }
}
