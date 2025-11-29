// lib/providers/notification_provider.dart

import 'package:flutter/material.dart';
import 'package:medishop/api_service/api_service.dart';
import 'package:medishop/api_service/api_constants.dart';
import 'package:medishop/models/notification.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.estLue).length;

  NotificationProvider(this._apiService);

  // --- Charger les notifications ---
  Future<void> fetchNotifications({bool forceRefresh = false}) async {
    if (_notifications.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.authDio.get(
        '${ApiConstants.baseUrl}/notifications/me/',
      );

      _notifications = (response.data as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      _error = "Impossible de récupérer les notifications.";
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Marquer une notification comme lue ---
  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);

    if (index != -1 && !_notifications[index].estLue) {
      _notifications[index] = _notifications[index].copyWith(estLue: true);
      notifyListeners();

      try {
        await _apiService.authDio.patch(
          '${ApiConstants.baseUrl}/notifications/$notificationId/read/',
        );
      } catch (e) {
        fetchNotifications(forceRefresh: true);
      }
    }
  }

  // --- Marquer toutes comme lues ---
  Future<void> markAllAsRead() async {
    try {
      await _apiService.authDio.patch(
        '${ApiConstants.baseUrl}/notifications/read_all/',
      );

      _notifications =
          _notifications.map((n) => n.copyWith(estLue: true)).toList();

      notifyListeners();
    } catch (e) {
      throw Exception("Échec de l’opération");
    }
  }

  // À l logout
  void clearState() {
    _notifications = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
