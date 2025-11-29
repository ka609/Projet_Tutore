// lib/screens/pharmacie/stock_add_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:medishop/providers/stock_provider.dart';
import 'package:medishop/providers/pharmacie_provider.dart';
import 'package:medishop/models/stock.dart';
import 'package:medishop/models/medicament.dart';

class StockAddEditScreen extends StatefulWidget {
  final Stock? stockToEdit;

  const StockAddEditScreen({super.key, this.stockToEdit});

  @override
  State<StockAddEditScreen> createState() => _StockAddEditScreenState();
}

class _StockAddEditScreenState extends State<StockAddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late int _quantite;
  late double _prixUnitaire;
  Medicament? _selectedMedicament;

  @override
  void initState() {
    super.initState();

    if (widget.stockToEdit != null) {
      _quantite = widget.stockToEdit!.quantite;
      _prixUnitaire = widget.stockToEdit!.prixUnitaire;
      _selectedMedicament = widget.stockToEdit!.medicament;
    } else {
      _quantite = 0;
      _prixUnitaire = 0.0;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedMedicament == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un médicament.')),
      );
      return;
    }

    final provider = Provider.of<StockProvider>(context, listen: false);

    try {
      await provider.addOrUpdateStock(
        medicamentId: _selectedMedicament!.id,
        quantite: _quantite,
        prixUnitaire: _prixUnitaire,
        stockId: widget.stockToEdit?.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock ${widget.stockToEdit == null ? 'ajouté' : 'mis à jour'} avec succès!',
          ),
        ),
      );

      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _selectMedicament(BuildContext context) async {
    final StockProvider stockProvider =
        Provider.of<StockProvider>(context, listen: false);

    final Medicament? selected = await showSearch<Medicament?>(
      context: context,
      delegate: MedicamentSearchDelegate(stockProvider: stockProvider),
    );

    if (selected != null) {
      setState(() {
        _selectedMedicament = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.stockToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le Stock' : 'Ajouter un Article'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Affichage Pharmacie ---
              _buildPharmacieDisplay(context),
              const SizedBox(height: 20),

              // --- Médicament ---
              _buildMedicamentSelector(context, isEditing),
              const SizedBox(height: 20),

              // --- Quantité ---
              TextFormField(
                initialValue: _quantite.toString(),
                decoration: const InputDecoration(
                  labelText: 'Quantité en Stock',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 0) {
                    return 'Quantité invalide.';
                  }
                  return null;
                },
                onSaved: (value) => _quantite = int.parse(value!),
              ),
              const SizedBox(height: 20),

              // --- Prix unitaire ---
              TextFormField(
                initialValue: _prixUnitaire.toStringAsFixed(2),
                decoration: const InputDecoration(
                  labelText: 'Prix Unitaire (FCFA)',
                  prefixIcon: Icon(Icons.sell),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Prix invalide.';
                  }
                  return null;
                },
                onSaved: (value) => _prixUnitaire = double.parse(value!),
              ),
              const SizedBox(height: 40),

              // --- Bouton enregistrer ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: Provider.of<StockProvider>(context).isLoading
                      ? null
                      : _submitForm,
                  icon: Provider.of<StockProvider>(context).isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(
                    isEditing
                        ? 'Sauvegarder les modifications'
                        : 'Ajouter au Stock',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Affichage de la pharmacie ---
  Widget _buildPharmacieDisplay(BuildContext context) {
    final pharmacieProvider =
        Provider.of<PharmacieProvider>(context, listen: false);

    final pharmacie = pharmacieProvider.myPharmacies.isNotEmpty
        ? pharmacieProvider.myPharmacies.first
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pharmacie :',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(pharmacie?.nomPharmacie ?? 'Aucune pharmacie disponible'),
      ],
    );
  }

  Widget _buildMedicamentSelector(BuildContext context, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Médicament associé:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.medical_services),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  _selectedMedicament?.nomCommercial ??
                      'Sélectionnez un médicament',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedMedicament == null
                        ? Colors.grey[600]
                        : Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isEditing ? null : () => _selectMedicament(context),
                child: Text(isEditing ? 'Sélectionné' : 'Rechercher'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.grey : Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (isEditing)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Le médicament ne peut être modifié après l\'ajout (seul le prix et la quantité peuvent l\'être).',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// --- Recherche Médicament ---
class MedicamentSearchDelegate extends SearchDelegate<Medicament?> {
  final StockProvider stockProvider;

  MedicamentSearchDelegate({required this.stockProvider});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(backgroundColor: Colors.teal),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return const Center(child: Text("Entrez au moins 3 caractères."));
    }

    return FutureBuilder<List<Medicament>>(
      future: stockProvider.searchMedicaments(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Erreur : ${snapshot.error}"));
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return const Center(child: Text("Aucun médicament trouvé."));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final medicament = results[index];

            return ListTile(
              title: Text(medicament.nomCommercial),
              subtitle: Text(medicament.nomScientifique ?? 'N/A'),
              trailing: const Icon(Icons.add_circle, color: Colors.teal),
              onTap: () => close(context, medicament),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) =>
      const Center(child: Text("Recherchez un médicament..."));
}
