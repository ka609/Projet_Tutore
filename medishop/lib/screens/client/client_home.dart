import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/auth_provider.dart';
import 'package:medishop/providers/notification_provider.dart';
import 'package:medishop/models/user_type.dart';
import 'catalogue_screen.dart';
import 'panier_screen.dart';
import 'commands_history_screen.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CatalogueScreen(),
    PanierScreen(),
    CommandsHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.userType != UserType.CLIENT) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(body: Center(child: Text('Accès refusé.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A4C86),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "MediShop",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty && !provider.isLoading) {
                provider.fetchNotifications();
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () => context.go('/notifications'),
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.white),
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          provider.unreadCount > 9
                              ? '9+'
                              : provider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
          IconButton(
            onPressed: () => context.go('/client/home/panier'),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF0A4C86),
        child: Column(
          children: [
            const DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _drawerItem(
              icon: Icons.person_outline,
              label: "Profil",
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              icon: Icons.settings_outlined,
              label: "Paramètres",
              onTap: () => context.go('/parametres'),
            ),
            _drawerItem(
              icon: Icons.logout,
              label: "Déconnexion",
              onTap: () async {
                await auth.logout();
                context.go('/login');
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "MediShop © 2025",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            )
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomButton(
              index: 0,
              icon: Icons.home_filled,
            ),
            _bottomButton(
              index: 1,
              icon: Icons.shopping_cart,
            ),
            _bottomButton(
              index: 2,
              icon: Icons.receipt_long,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButton({required int index, required IconData icon}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A4C86) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}
