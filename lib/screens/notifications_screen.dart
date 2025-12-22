import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _initCalled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initCalled) {
      _initCalled = true;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final notifProv =
          Provider.of<NotificationProvider>(context, listen: false);
      final email = auth.currentUser?.email ?? '';
      if (email.isNotEmpty) {
        Future.microtask(() => notifProv.loadForUser(email));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProv = Provider.of<NotificationProvider>(context);

    if (!notifProv.loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final items = notifProv.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all read',
              onPressed: () => notifProv.markAllRead(),
            )
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const Center(child: Text('No notifications yet'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final n = items[i];
                  return _notificationTile(n);
                },
              ),
      ),
    );
  }

  Widget _notificationTile(NotificationItem n) {
    return ListTile(
      leading: Icon(
        n.read ? Icons.notifications_none : Icons.notifications_active,
      ),
      title: Text(n.title),
      subtitle: Text(
        n.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(n.createdAt),
        style: const TextStyle(fontSize: 11, color: Colors.black54),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
