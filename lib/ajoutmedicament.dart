import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AjoutMedicamentPage extends StatefulWidget {
  const AjoutMedicamentPage({super.key});

  @override
  State<AjoutMedicamentPage> createState() => _AjoutMedicamentPageState();
}

class _AjoutMedicamentPageState extends State<AjoutMedicamentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomMedicamentController = TextEditingController();
  final TextEditingController nomMedecinController = TextEditingController();
  final TextEditingController dateDebutController = TextEditingController();
  final TextEditingController dateFinController = TextEditingController();
  final TextEditingController heureController = TextEditingController();
  final TextEditingController frequenceController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController remarquesController = TextEditingController();
  final TextEditingController codeBarreController = TextEditingController();

  String? typeMedicament = "Solide";
  bool notificationsActive = true;
  File? ordonnanceImage;

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickOrdonnanceImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        ordonnanceImage = File(picked.path);
      });
    }
  }

  Future<void> _saveMedicament() async {
    if (!_formKey.currentState!.validate()) {
      // Afficher une erreur si formulaire invalide
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires.")),
      );
      return;
    }

    // Afficher une boîte de confirmation avant de procéder
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer l'ajout"),
          content: const Text("Êtes-vous sûr de vouloir ajouter ce médicament ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Confirmer"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == null || !confirmed) {
      return; // Si l'utilisateur annule, ne rien faire
    }

    String? imageUrl;
    if (ordonnanceImage != null) {
      try {
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref()
            .child('ordonnances/${DateTime.now().toString()}.jpg')
            .putFile(ordonnanceImage!);
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        if (kDebugMode) {
          print("Erreur lors de la sauvegarde de l'image : $e");
        }
      }
    }

    try {
      await FirebaseFirestore.instance.collection('medicaments').add({
        'nomMedicament': nomMedicamentController.text,
        'nomMedecin': nomMedecinController.text,
        'dateDebut': dateDebutController.text,
        'dateFin': dateFinController.text,
        'heure': heureController.text,
        'frequence': frequenceController.text,
        'quantite': quantiteController.text,
        'stock': stockController.text,
        'remarques': remarquesController.text,
        'codeBarre': codeBarreController.text,
        'typeMedicament': typeMedicament,
        'notificationsActive': notificationsActive,
        'imageOrdonnance': imageUrl,
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Médicament ajouté avec succès!")),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print("Erreur Firestore : $e");
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'ajout du médicament")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        title: const Text("Ajouter un médicament", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Nom du médicament", nomMedicamentController),
              _buildTextField("Nom du médecin", nomMedecinController),
              const SizedBox(height: 10),
              const Text("Type de médicament", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Solide"),
                      value: "Solide",
                      groupValue: typeMedicament,
                      activeColor: Colors.indigo.shade900,
                      onChanged: (value) {
                        setState(() => typeMedicament = value);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Liquide"),
                      value: "Liquide",
                      groupValue: typeMedicament,
                      activeColor: Colors.indigo.shade900,
                      onChanged: (value) {
                        setState(() => typeMedicament = value);
                      },
                    ),
                  )
                ],
              ),
              _buildDateField("Date de début", dateDebutController),
              _buildDateField("Date de fin", dateFinController),
              _buildTextField("Heure", heureController),
              _buildNumberField("Fréquence (par jour)", frequenceController),
              _buildNumberField("Quantité par prise", quantiteController),
              _buildNumberField("Stock total", stockController),
              _buildTextField("Remarques", remarquesController, maxLines: 2),
              _buildTextField("Code barre", codeBarreController),
              SwitchListTile(
                title: const Text("Notifications"),
                value: notificationsActive,
                activeColor: Colors.indigo.shade900,
                onChanged: (val) {
                  setState(() => notificationsActive = val);
                },
              ),
              ListTile(
                title: const Text("Ordonnance (image)"),
                trailing: IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickOrdonnanceImage,
                ),
              ),
              if (ordonnanceImage != null)
                Image.file(ordonnanceImage!, height: 100),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveMedicament,
                child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Champ obligatoire' : null,
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Champ obligatoire' : null,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(controller),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Champ obligatoire' : null,
      ),
    );
  }
}
