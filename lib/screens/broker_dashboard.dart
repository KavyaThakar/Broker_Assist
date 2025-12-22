// lib/screens/broker_dashboard.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/request_provider.dart';

import 'admin_requests_screen.dart';
import 'admin_ipo_screen.dart';
import 'admin_corporate_actions_screen.dart';
import 'new_request_screen.dart';
import 'broker_chat_inbox_screen.dart';
import 'broker_reports_screen.dart';
import 'broker_portfolio_screen.dart';
import 'broker_reminders_screen.dart';

class BrokerDashboard extends StatelessWidget {
  const BrokerDashboard({super.key});

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
    final buttonWidth = (width - 14 * 2 - 8) / 2; // 2 per row

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

    final totalRequests = reqProv.allRequests.length;
    final pending =
        reqProv.allRequests.where((r) => r.status == 'pending').length;
    final inProgress =
        reqProv.allRequests.where((r) => r.status == 'in_progress').length;
    final completed =
        reqProv.allRequests.where((r) => r.status == 'completed').length;

    return Scaffold(
      appBar: AppBar(title: const Text('Broker Dashboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hello, ${user?.name ?? 'Broker'}',
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
                      'Total Requests',
                      '$totalRequests',
                      Icons.receipt_long,
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
                      Icons.work,
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
                  _quickActionButton(
                    context,
                    icon: Icons.chat_bubble,
                    label: 'Client Chats',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BrokerChatInboxScreen(),
                        ),
                      );
                    },
                  ),
                  _quickActionButton(
                    context,
                    icon: Icons.manage_history,
                    label: 'All Requests',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminRequestsScreen(),
                        ),
                      );
                    },
                  ),
                  _quickActionButton(
                    context,
                    icon: Icons.pie_chart,
                    label: 'Client Portfolio',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BrokerPortfolioScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---- ACTIONS ----
              Text(
                'Actions',
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
                      leading: const Icon(Icons.add_box_outlined),
                      title: const Text('Create New Request (as Broker)'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewRequestScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('Manage IPOs'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminIpoScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.campaign),
                      title: const Text('Manage Corporate Actions'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminCorporateActionsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Manage Reports'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BrokerReportsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.alarm),
                      title: const Text('Reminders'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BrokerRemindersScreen(),
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
                'Recent (all)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              if (reqProv.allRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: Text('No requests yet')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: min(8, reqProv.allRequests.length),
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final r = reqProv.allRequests[i];
                    return ListTile(
                      title: Text(r.title),
                      subtitle: Text(
                        r.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(r.status.replaceAll('_', ' ')),
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
