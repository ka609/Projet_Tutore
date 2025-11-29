// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/auth_provider.dart';
import 'package:medishop/models/user_type.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  UserType? _selectedUserType = UserType.CLIENT;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate() || _selectedUserType == null) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Les mots de passe ne correspondent pas.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        type: _selectedUserType!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Bienvenue ! Compte ${_selectedUserType!.name.toLowerCase()} créé avec succès.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C8BF5), Color(0xFF00C6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.app_registration,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Créer un compte',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  // --- Sélection du rôle ---
                  DropdownButtonFormField<UserType>(
                    decoration: InputDecoration(
                      labelText: 'Type de compte',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: _selectedUserType,
                    items: const [
                      DropdownMenuItem(
                          value: UserType.CLIENT, child: Text('Client')),
                      DropdownMenuItem(
                          value: UserType.PHARMACIE, child: Text('Pharmacie')),
                      DropdownMenuItem(
                          value: UserType.LIVREUR, child: Text('Livreur')),
                    ],
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() => _selectedUserType = value);
                    },
                    validator: (value) =>
                        value == null ? 'Veuillez choisir un rôle.' : null,
                  ),
                  const SizedBox(height: 20),

                  // --- Nom et prénom ---
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nomController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Requis.' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _prenomController,
                          decoration: InputDecoration(
                            labelText: 'Prénom',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Requis.' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Email ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Email invalide.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Mot de passe ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value == null || value.length < 8
                        ? 'Au moins 8 caractères.'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // --- Confirmation mot de passe ---
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      prefixIcon:
                          const Icon(Icons.lock_reset, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) => value != _passwordController.text
                        ? 'Les mots de passe ne correspondent pas.'
                        : null,
                  ),
                  const SizedBox(height: 30),

                  // --- Bouton inscription ---
                  _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              elevation: 5,
                            ),
                            child: const Text('S\'INSCRIRE'),
                          ),
                        ),
                  const SizedBox(height: 20),

                  // --- Lien vers login ---
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      "Déjà un compte ? Se connecter",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
