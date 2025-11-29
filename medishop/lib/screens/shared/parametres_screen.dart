import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/parametre_utilisateur_provider.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  static const String CLE_THEME = 'theme_preference';
  static const String CLE_EMAIL_NOTIFICATIONS = 'email_notifications_enabled';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ParametreUtilisateurProvider>(context, listen: false)
          .fetchParametres();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParametreUtilisateurProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0A4C86),
        foregroundColor: Colors.white,
        title: const Text(
          "Paramètres",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: provider.isLoading && provider.parametres.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(provider),
    );
  }

  Widget _buildBody(ParametreUtilisateurProvider provider) {
    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    final currentTheme = provider.getParametreValue(CLE_THEME) ?? 'light';
    final emailEnabled =
        provider.getParametreValue(CLE_EMAIL_NOTIFICATIONS) == 'true';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle("Apparence"),
        _settingCard(
          icon: Icons.palette_rounded,
          title: "Thème de l'application",
          subtitle: currentTheme == 'dark' ? "Sombre" : "Clair",
          trailing: DropdownButton<String>(
            value: currentTheme,
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 'light', child: Text("Clair")),
              DropdownMenuItem(value: 'dark', child: Text("Sombre")),
            ],
            onChanged: provider.isLoading
                ? null
                : (v) {
                    if (v != null) {
                      provider.updateParametre(CLE_THEME, v);
                    }
                  },
          ),
        ),
        const SizedBox(height: 20),
        _sectionTitle("Notifications"),
        _settingCard(
          icon: Icons.email_outlined,
          title: "Notifications par e-mail",
          subtitle: "Recevoir les alertes sur les commandes",
          trailing: Switch(
            value: emailEnabled,
            activeColor: const Color(0xFF0A4C86),
            onChanged: provider.isLoading
                ? null
                : (v) {
                    provider.updateParametre(
                        CLE_EMAIL_NOTIFICATIONS, v.toString());
                  },
          ),
        ),
        if (provider.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0A4C86).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0A4C86)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
