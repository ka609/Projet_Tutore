// lib/screens/shared/settings_screen.dart (Mis à Jour)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/user_settings_provider.dart'; // Utiliser le nouveau provider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les paramètres au démarrage de l'écran
    Future.microtask(() =>
        Provider.of<UserSettingsProvider>(context, listen: false)
            .fetchSettings());
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<UserSettingsProvider>(context);

    // Lecture d'un paramètre de type booléen (doit être converti)
    final String darkModeValue =
        settingsProvider.getSettingValue('dark_mode') ?? 'false';
    final bool isDarkModeEnabled = darkModeValue.toLowerCase() == 'true';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres Utilisateur'),
      ),
      body: settingsProvider.isLoading && settingsProvider.settings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- Option 1: Thème Sombre ---
                SwitchListTile(
                  title: const Text('Activer le mode sombre'),
                  subtitle: const Text(
                      'Ajuste l\'interface pour la faible luminosité.'),
                  secondary: const Icon(Icons.dark_mode),
                  value: isDarkModeEnabled,
                  onChanged: (bool newValue) async {
                    try {
                      // Mettre à jour en utilisant la clé et la valeur (stockée en String)
                      await settingsProvider.updateSetting(
                        key: 'dark_mode',
                        value: newValue
                            .toString(), // Convertir en 'true' ou 'false' (String)
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Mode sombre mis à jour: $newValue')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: ${e.toString()}')),
                      );
                    }
                  },
                ),

                const Divider(),

                // --- Option 2: Exemple de Langue ---
                ListTile(
                  title: const Text('Langue de l\'application'),
                  subtitle: Text(settingsProvider.getSettingValue('language') ??
                      'Français'),
                  leading: const Icon(Icons.language),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    // Exemple de mise à jour simple
                    final currentLang =
                        settingsProvider.getSettingValue('language') ??
                            'Français';
                    final newLang =
                        (currentLang == 'Français') ? 'Anglais' : 'Français';
                    await settingsProvider.updateSetting(
                        key: 'language', value: newLang);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Langue changée en $newLang')),
                    );
                  },
                ),

                const Divider(),
              ],
            ),
    );
  }
}
