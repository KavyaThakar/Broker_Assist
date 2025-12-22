// lib/screens/client_dashboard.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/request_provider.dart';

import 'new_request_screen.dart';
import 'my_requests_screen.dart';
import 'client_ipo_screen.dart';
import 'client_corporate_actions_screen.dart';
import 'client_reports_screen.dart';
import 'client_portfolio_screen.dart';
import 'client_reminders_screen.dart';
import 'client_chat_screen.dart'; // ✅ added

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.16),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;
    final buttonWidth = (width - 14 * 2 - 8) / 2; // 2 buttons per row

    return SizedBox(
      width: buttonWidth,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final reqProv = Provider.of<RequestProvider>(context);
    final user = auth.currentUser;
    final myRequests = reqProv.myRequests;

    final total = myRequests.length;
    final pending = myRequests.where((r) => r.status == 'pending').length;
    final inProgress =
        myRequests.where((r) => r.status == 'in_progress').length;
    final completed = myRequests.where((r) => r.status == 'completed').length;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting
              Text(
                'Hello, ${user?.name ?? "User"}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // ---- STATS ----
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'Your Requests',
                      '$total',
                      Icons.list_alt,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statCard(
                      'Pending',
                      '$pending',
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'In Progress',
                      '$inProgress',
                      Icons.work_outline,
                      Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statCard(
                      'Completed',
                      '$completed',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ---- QUICK ACTIONS ----
              Text(
                'Quick actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // ✅ Chat with Broker
                  _quickActionButton(
                    context,
                    icon: Icons.chat_bubble,
                    label: 'Chat with Broker',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClientChatScreen(),
                        ),
                      );
                    },
                  ),
                  _quickActionButton(
                    context,
                    icon: Icons.add,
                    label: 'Create Request',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewRequestScreen(),
                        ),
                      );
                    },
                  ),
                  _quickActionButton(
                    context,
                    icon: Icons.list_alt,
                    label: 'My Requests',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyRequestsScreen(),
                        ),
                      );
                    },
                  ),
                  _quickActionButton(
                    context,
                    icon: Icons.pie_chart,
                    label: 'My Portfolio',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClientPortfolioScreen(),
                        ),
                      );
                    },
                  ),
                  _quickActionButton(
                    context,
                    icon: Icons.alarm,
                    label: 'My Reminders',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClientRemindersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---- MORE SECTION ----
              Text(
                'More',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.event_note),
                      title: const Text('View IPO Calendar'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ClientIpoScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.campaign),
                      title: const Text('Corporate Action Alerts'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ClientCorporateActionsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('My Reports & Documents'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ClientReportsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---- RECENT REQUESTS ----
              Text(
                'Recent (yours)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              if (myRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: Text('You have no requests yet')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: min(5, myRequests.length),
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final r = myRequests[i];
                    return ListTile(
                      title: Text(r.title),
                      subtitle: Text(
                        r.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(r.status.replaceAll('_', ' ')),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(r.title),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: ${r.status}'),
                              const SizedBox(height: 8),
                              Text(r.description),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
