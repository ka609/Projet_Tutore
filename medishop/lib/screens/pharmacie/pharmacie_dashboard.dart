import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/auth_provider.dart';
import 'package:medishop/models/user_type.dart';

// --- IMPORTS DES ÉCRANS DU DASHBOARD ---
import 'package:medishop/screens/pharmacie/pharmacie_screen.dart';
import 'package:medishop/screens/pharmacie/stock_management_screen.dart';
import 'package:medishop/screens/pharmacie/orders_management_screen.dart';
import 'package:medishop/screens/pharmacie/medicament_list_screen.dart';
import 'package:medishop/screens/shared/notification_screen.dart';
import 'package:medishop/screens/shared/parametres_screen.dart';
import 'package:medishop/screens/shared/settings_screen.dart';
import 'package:medishop/screens/pharmacie/medicament_add_edit_screen.dart';

class PharmacieDashboard extends StatelessWidget {
  const PharmacieDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Vérification de sécurité
    if (auth.userType != UserType.PHARMACIE) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const DashboardLayout();
  }
}

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  // L'index par défaut est 0 (MedicamentListScreen / Home)
  int _currentIndex = 0;

  // Configuration des couleurs "Pro"
  final Color _primaryColor = const Color(0xFF009688); // Teal Médical
  final Color _backgroundColor =
      const Color(0xFFF5F7FA); // Gris bleuté très léger

  // Liste des écrans ordonnée selon ta demande spécifique
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      // 1. En bas à gauche : Home (MedicamentList)
      const MedicamentListScreen(),

      // 2. Milieu Gauche : Stock
      const StockManagementScreen(),

      // 3. Milieu Droite : Suivi de Commande
      const OrdersManagementScreen(),

      // 4. En bas à droite : Pharmacie Screen
      const PharmacieScreen(),
    ];
  }

  // Titres dynamiques pour l'AppBar
  final List<String> _titles = [
    "Médicaments",
    "Gestion de Stock",
    "Suivi des Commandes",
    "Ma Pharmacie",
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildProAppBar(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),

      // ⭐ Ajoute ce bloc pour afficher le bouton (+)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MedicamentAddEditScreen(),
                  ),
                );
              },
            )
          : null,

      bottomNavigationBar: _buildModernBottomNavBar(),
    );
  }

  // --- APP BAR DESIGN PRO ---
  PreferredSizeWidget _buildProAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        _titles[_currentIndex],
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        // Bouton Notification (Icon)
        IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()));
          },
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined,
                  color: Colors.black87, size: 28),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              )
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Menu Déroulant Profil (Avatar)
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: _primaryColor.withOpacity(0.1),
              backgroundImage: const AssetImage('assets/user_avatar.png'),
              // Gestion d'erreur si l'image n'existe pas pour éviter le crash
              onBackgroundImageError: (_, __) {},
              child: const Icon(Icons.person, color: Colors.teal),
            ),
            onSelected: (value) {
              if (value == 'profil') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ParametresScreen()));
              } else if (value == 'settings') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              } else if (value == 'logout') {
                context.read<AuthProvider>().logout();
                context.go('/login');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              _buildPopupMenuItem('profil', Icons.person_outline, "Profil"),
              _buildPopupMenuItem(
                  'settings', Icons.settings_outlined, "Paramètres"),
              const PopupMenuDivider(),
              _buildPopupMenuItem('logout', Icons.logout, "Déconnexion",
                  isDestructive: true),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String value, IconData icon, String text,
      {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              color: isDestructive ? Colors.red : Colors.grey[700], size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- BOTTOM NAVIGATION BAR DESIGN PRO ---
  Widget _buildModernBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Médicaments (HOME ICON) - Bas Gauche
              _buildNavItem(
                  0, Icons.home_rounded, Icons.home_outlined, "Accueil"),

              // 2. Stock - Milieu
              _buildNavItem(1, Icons.inventory_2_rounded,
                  Icons.inventory_2_outlined, "Stock"),

              // 3. Commandes - Milieu
              _buildNavItem(2, Icons.assignment_rounded,
                  Icons.assignment_outlined, "Commandes"),

              // 4. Pharmacie - Bas Droite
              _buildNavItem(
                  3, Icons.store_rounded, Icons.store_outlined, "Ma Pharma"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? _primaryColor : Colors.grey[500],
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
