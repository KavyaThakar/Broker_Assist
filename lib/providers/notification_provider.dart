import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  static const _notifKey = 'brokerassist_notifications';

  List<NotificationItem> _all = [];
  bool _loaded = false;
  String _currentEmail = '';

  bool get loaded => _loaded;

  List<NotificationItem> get notifications {
    final list = _all
        .where(
          (n) => n.forEmail.toLowerCase() == _currentEmail.toLowerCase(),
        )
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int get unreadCount => notifications.where((n) => !n.read).length;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_notifKey) ?? [];
    _all = list.map((s) => NotificationItem.fromJson(s)).toList();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _all.map((n) => n.toJson()).toList();
    await prefs.setStringList(_notifKey, list);
  }

  Future<void> loadForUser(String email) async {
    _currentEmail = email;
    await _loadFromPrefs();
    _loaded = true;
    notifyListeners();
  }

  Future<void> addNotification({
    required String forEmail,
    required String title,
    required String body,
  }) async {
    if (!_loaded) {
      await _loadFromPrefs();
    }

    // avoid exact duplicate notifications
    final exists = _all.any(
      (n) =>
          n.forEmail.toLowerCase() == forEmail.toLowerCase() &&
          n.title == title &&
          n.body == body,
    );
    if (exists) return;

    final item = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      forEmail: forEmail,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      read: false,
    );

    _all.add(item);
    await _saveToPrefs();

    if (forEmail.toLowerCase() == _currentEmail.toLowerCase()) {
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    if (!_loaded) return;
    bool changed = false;
    _all = _all.map((n) {
      if (n.forEmail.toLowerCase() == _currentEmail.toLowerCase() && !n.read) {
        changed = true;
        return n.copyWith(read: true);
      }
      return n;
    }).toList();
    if (changed) {
      await _saveToPrefs();
      notifyListeners();
    }
  }

  void reset() {
    _currentEmail = '';
    _loaded = false;
    notifyListeners();
  }
}
