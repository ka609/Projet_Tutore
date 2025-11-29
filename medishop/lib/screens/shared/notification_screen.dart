import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medishop/providers/notification_provider.dart';
import 'package:medishop/models/notification.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    if (provider.notifications.isEmpty && !provider.isLoading) {
      Future.microtask(() => provider.fetchNotifications());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notifications'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (provider.unreadCount > 0 && !provider.isLoading)
            TextButton(
              onPressed: () async {
                try {
                  await provider.markAllAsRead();
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Impossible de marquer toutes les notifications comme lues")),
                  );
                }
              },
              child: const Text('Tout marquer lu',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, NotificationProvider provider) {
    if (provider.isLoading)
      return const Center(child: CircularProgressIndicator());

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => provider.fetchNotifications(forceRefresh: true),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return const Center(child: Text("Aucune notification pour l'instant."));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchNotifications(forceRefresh: true),
      child: ListView.builder(
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final notification = provider.notifications[index];
          return NotificationTile(notification: notification);
        },
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final titleText =
        notification.titre ?? notification.message.split('\n').first;

    return ListTile(
      tileColor: notification.estLue ? Colors.white : Colors.teal.shade50,
      leading: Icon(
        _getIcon(notification.typeNotification),
        color: notification.estLue ? Colors.grey : Colors.teal.shade700,
      ),
      title: Text(titleText,
          style: TextStyle(
              fontWeight:
                  notification.estLue ? FontWeight.normal : FontWeight.bold)),
      subtitle: Text(notification.message),
      trailing: Text(_formatDate(notification.dateEnvoi),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      onTap: () {
        if (!notification.estLue) provider.markAsRead(notification.id);
        _handleTapAction(context, notification);
      },
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'COMMANDE':
        return Icons.shopping_bag;
      case 'STOCK':
        return Icons.warning_amber;
      case 'PAIEMENT':
        return Icons.payment;
      default:
        return Icons.info_outline;
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}j';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Maintenant';
  }

  void _handleTapAction(BuildContext context, NotificationModel notif) {
    if (notif.typeNotification == 'COMMANDE' && notif.objetId != null) {
      context.go('/orders/${notif.objetId}');
    } else if (notif.typeNotification == 'STOCK_FAIBLE' &&
        notif.objetId != null) {
      context.go('/pharmacie/dashboard/stock/item/${notif.objetId}');
    }
  }
}
