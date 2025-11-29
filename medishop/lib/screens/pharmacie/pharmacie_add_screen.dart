import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/pharmacie_provider.dart';

class PharmacieAddScreen extends StatefulWidget {
  const PharmacieAddScreen({super.key});

  @override
  State<PharmacieAddScreen> createState() => _PharmacieAddScreenState();
}

class _PharmacieAddScreenState extends State<PharmacieAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _licenceController = TextEditingController();
  final _latController =
      TextEditingController(); // Maintenant pour saisie manuelle
  final _lngController =
      TextEditingController(); // Maintenant pour saisie manuelle

  bool _isLoading = false;
  // bool _isGettingLocation = false; // SUPPRIMÉ

  @override
  void dispose() {
    _nameController.dispose();
    _licenceController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  /// -------------------------
  /// GÉOLOCALISATION AUTOMATIQUE
  /// -------------------------
  // La méthode _getLocation a été SUPPRIMÉE

  /// -------------------------
  /// SOUMISSION DU FORMULAIRE
  /// -------------------------
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation des champs Lat/Lng même s'ils sont saisis manuellement
    if (_latController.text.isEmpty || _lngController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez saisir la Latitude et la Longitude."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation pour s'assurer que les valeurs sont des nombres
    final double? latitude = double.tryParse(_latController.text);
    final double? longitude = double.tryParse(_lngController.text);

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "La Latitude et la Longitude doivent être des nombres valides."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<PharmacieProvider>(context, listen: false);

      await provider.createPharmacie(
        nom: _nameController.text,
        licenceNumero: _licenceController.text,
        latitude: latitude,
        longitude: longitude,
      );

      // Succès: Redirection vers le tableau de bord
      context.go('/pharmacie/dashboard/pharmacie');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur d'ajout : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// -------------------------
  /// UI
  /// -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer votre Pharmacie'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.add_business, size: 80, color: Colors.teal),
              const SizedBox(height: 30),

              // NOM
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom Commercial de la Pharmacie',
                  prefixIcon: Icon(Icons.business_center),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer le nom.' : null,
              ),
              const SizedBox(height: 20),

              // LICENCE NUMERO
              TextFormField(
                controller: _licenceController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de Licence (Obligatoire)',
                  prefixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty
                    ? 'Veuillez entrer le numéro de licence.'
                    : null,
              ),
              const SizedBox(height: 20),

              // LATITUDE (maintenant saisie manuelle)
              TextFormField(
                controller: _latController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Latitude (ex: 14.5678)',
                  prefixIcon: Icon(Icons.explore),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez saisir la Latitude.' : null,
              ),
              const SizedBox(height: 20),

              // LONGITUDE (maintenant saisie manuelle)
              TextFormField(
                controller: _lngController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Longitude (ex: -17.1234)',
                  prefixIcon: Icon(Icons.explore_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez saisir la Longitude.' : null,
              ),
              const SizedBox(height: 40),

              // SUBMIT BUTTON
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isLoading ? 'Enregistrement...' : 'Enregistrer ma Pharmacie',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
