// lib/screens/shared/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/auth_provider.dart';
import 'package:medishop/models/utilisateur.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialise les contrôleurs avec les données actuelles de l'utilisateur
    final currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: currentUser?.nom ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fonction de sauvegarde (Mise à jour du profil)
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Construire le payload de mise à jour
      Map<String, dynamic> updateData = {
        'nom': _nameController.text,
        'email': _emailController.text,
      };

      if (_passwordController.text.isNotEmpty) {
        updateData['password'] = _passwordController.text;
      }

      try {
        await authProvider.updateUserProfile(updateData);

        // Réinitialiser les champs et sortir du mode édition
        setState(() {
          _isEditing = false;
          _passwordController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la mise à jour: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final Utilisateur? user = authProvider.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- En-tête du Profil ---
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 60),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.nom ?? 'Utilisateur Inconnu',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rôle: ${user?.typeUtilisateur.toString().split('.').last ?? 'N/A'}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // --- Bouton Modifier/Annuler ---
              Align(
                alignment: Alignment.centerRight,
                child: _isEditing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                // Réinitialiser les contrôleurs si annulation
                                _nameController.text = user?.nom ?? '';
                                _emailController.text = user?.email ?? '';
                                _passwordController.clear();
                              });
                            },
                            child: const Text('Annuler',
                                style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Sauvegarder'),
                          ),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier le Profil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
              ),

              const Divider(height: 30),

              // --- Champs de Formulaire ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom Complet',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email.';
                  }
                  // Validation d'email simple
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Champ de Mot de Passe (Optionnel, seulement pour la mise à jour)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nouveau Mot de Passe (Laisser vide si inchangé)',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
