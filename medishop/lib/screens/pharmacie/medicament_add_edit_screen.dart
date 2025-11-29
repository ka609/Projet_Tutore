import 'dart:io' show File; // IMPORTANT : éviter conflit Web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:medishop/models/medicament.dart';
import 'package:medishop/providers/medicament_provider.dart';
import 'dart:typed_data';

class MedicamentAddEditScreen extends StatefulWidget {
  final Medicament? medicamentToEdit;
  const MedicamentAddEditScreen({super.key, this.medicamentToEdit});

  @override
  State<MedicamentAddEditScreen> createState() =>
      _MedicamentAddEditScreenState();
}

class _MedicamentAddEditScreenState extends State<MedicamentAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCommercialController = TextEditingController();
  final _nomScientifiqueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categorieController = TextEditingController();
  final _priceController = TextEditingController();
  bool _necessitePrescription = false;

  dynamic _photoData; // File or Uint8List
  String? _initialPhotoUrl;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.medicamentToEdit != null) {
      final m = widget.medicamentToEdit!;
      _nomCommercialController.text = m.nomCommercial;
      _nomScientifiqueController.text = m.nomScientifique ?? '';
      _descriptionController.text = m.description ?? '';
      _categorieController.text = m.categorie ?? '';
      _necessitePrescription = m.necessitePrescription;
      _initialPhotoUrl = m.photoUrl;
      _priceController.text = m.price.toString();
    }
  }

  @override
  void dispose() {
    _nomCommercialController.dispose();
    _nomScientifiqueController.dispose();
    _descriptionController.dispose();
    _categorieController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // -------------------------------------
  // IMAGE PICKER WEB + MOBILE
  // -------------------------------------
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _photoData = bytes); // Uint8List
      } else {
        setState(() => _photoData = File(pickedFile.path)); // File
      }
    }
  }

  // -------------------------------------
  // SUBMIT
  // -------------------------------------
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<MedicamentProvider>(context, listen: false);

    try {
      final nomCom = _nomCommercialController.text;
      final nomSci = _nomScientifiqueController.text.isEmpty
          ? null
          : _nomScientifiqueController.text;
      final desc = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;
      final cat =
          _categorieController.text.isEmpty ? null : _categorieController.text;

      final price =
          num.tryParse(_priceController.text.replaceAll(",", ".")) ?? 0;

      // -----------------------------
      // IMPORTANT FIX : preparer le fichier avant l’envoi
      // -----------------------------
      dynamic fileToUpload;

      if (_photoData != null) {
        if (_photoData is File) {
          fileToUpload = _photoData; // use as File
        } else if (_photoData is Uint8List) {
          fileToUpload = _photoData; // will be handled using fromBytes
        }
      }

      // -----------------------------
      // CREATE vs UPDATE
      // -----------------------------
      if (widget.medicamentToEdit == null) {
        await provider.createMedicament(
          nomCommercial: nomCom,
          nomScientifique: nomSci,
          description: desc,
          categorie: cat,
          necessitePrescription: _necessitePrescription,
          photoFile: fileToUpload,
          price: price,
        );
        _showMessage('Médicament créé avec succès !', Colors.green);
      } else {
        await provider.updateMedicament(
          widget.medicamentToEdit!,
          nomCommercial: nomCom,
          nomScientifique: nomSci,
          description: desc,
          categorie: cat,
          necessitePrescription: _necessitePrescription,
          photoFile: fileToUpload,
          price: price,
        );

        _showMessage('Médicament mis à jour avec succès !', Colors.green);
      }

      context.pop();
    } catch (e) {
      _showMessage(
          "Erreur : ${e.toString().replaceAll('Exception: ', '')}", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -------------------------------------
  // DECORATION
  // -------------------------------------
  InputDecoration _getInputDecoration(String label, IconData icon,
      {String? suffixText}) {
    const primaryColor = Color(0xFF1E88E5);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      suffixText: suffixText,
      suffixStyle:
          const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // -------------------------------------
  // UI
  // -------------------------------------
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medicamentToEdit != null;
    const primaryColor = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEditing ? "Modifier Médicament" : "Ajouter Médicament"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPhotoUploadWidget(primaryColor),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomCommercialController,
                decoration: _getInputDecoration(
                    "Nom Commercial *", Icons.local_pharmacy),
                validator: (v) =>
                    v!.isEmpty ? "Le nom commercial est requis" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomScientifiqueController,
                decoration:
                    _getInputDecoration("Nom Scientifique", Icons.science),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categorieController,
                decoration: _getInputDecoration("Catégorie", Icons.category),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: _getInputDecoration("Prix Unitaire *", Icons.money,
                    suffixText: "FCFA"),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Le prix est requis.";
                  if (num.tryParse(value.replaceAll(",", ".")) == null) {
                    return "Entrez un nombre valide.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration:
                    _getInputDecoration("Description", Icons.description),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text("Nécessite Prescription Médicale"),
                value: _necessitePrescription,
                onChanged: (v) => setState(() => _necessitePrescription = v),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save),
                label: Text(
                    isEditing ? "Sauvegarder les Modifications" : "Ajouter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------
  // IMAGE PREVIEW
  // -------------------------------------
  Widget _buildPhotoUploadWidget(Color primaryColor) {
    Widget imageWidget;

    if (_photoData != null) {
      if (kIsWeb) {
        imageWidget = Image.memory(_photoData as Uint8List, fit: BoxFit.cover);
      } else {
        imageWidget = Image.file(_photoData as File, fit: BoxFit.cover);
      }
    } else if (_initialPhotoUrl != null) {
      imageWidget = Image.network(_initialPhotoUrl!, fit: BoxFit.cover);
    } else {
      imageWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 50),
            const SizedBox(height: 8),
            const Text("Ajouter une photo..."),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageWidget,
        ),
      ),
    );
  }
}
