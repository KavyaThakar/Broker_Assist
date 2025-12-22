import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/request_provider.dart';
import '../providers/notification_provider.dart';

import 'login_screen.dart';
import 'new_request_screen.dart';
import 'my_requests_screen.dart';
import 'admin_requests_screen.dart';
import 'client_dashboard.dart';
import 'broker_dashboard.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart'; // 👈 NEW

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final reqProv = Provider.of<RequestProvider>(context, listen: false);
    final notifProv = Provider.of<NotificationProvider>(context, listen: false);

    await auth.logout();
    reqProv.clear();
    notifProv.reset();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openDashboardForRole(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final role = (auth.currentUser?.role ?? '').toLowerCase();
    if (role == 'broker') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BrokerDashboard()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ClientDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProv = Provider.of<NotificationProvider>(context);
    final user = auth.currentUser;
    final isBroker = (user?.role ?? '').toLowerCase() == 'broker';

    return Scaffold(
      appBar: AppBar(
        title: const Text('BrokerAssist Home'),
        actions: [
          // profile icon
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          // notifications
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications),
                if (notifProv.unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        notifProv.unreadCount.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          // logout
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user found')
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome, ${user.name}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text('Role: ${user.role}'),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.dashboard_customize),
                        label: const Text('Open Dashboard'),
                        onPressed: () => _openDashboardForRole(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create New Request'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewRequestScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.list),
                        label: const Text('My Requests'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyRequestsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    if (isBroker) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.dashboard),
                          label: const Text('Admin: All Requests'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminRequestsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
