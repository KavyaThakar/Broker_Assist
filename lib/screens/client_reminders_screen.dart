import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_model.dart';

class ClientRemindersScreen extends StatelessWidget {
  const ClientRemindersScreen({super.key});

 @override
Widget build(BuildContext context) {
  final auth = Provider.of<AuthProvider>(context);
  final reminderProv = Provider.of<ReminderProvider>(context);

  if (!reminderProv.initialized) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  final user = auth.currentUser;
  if (user == null) {
    return const Scaffold(
      body: Center(child: Text("No user found")),
    );
  }

  final reminders = List<ReminderModel>.from(
    reminderProv.forClient(user.email),
  );


    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reminders"),
      ),
      body: reminders.isEmpty
          ? const Center(
              child: Text(
                "No reminders yet.\nYour broker will add reminders here.",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final r = reminders[i];
                final dueText =
                    "${r.dueAt.day}/${r.dueAt.month}/${r.dueAt.year}";

                return ListTile(
                  leading: Icon(
                    r.done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: r.done ? Colors.green : Colors.grey,
                  ),
                  title: Text(r.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Due: $dueText"),
                      if (r.details != null && r.details!.isNotEmpty)
                        Text(
                          r.details!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  onTap: () {
                    reminderProv.toggleDone(r.id);
                  },
                );
              },
            ),
    );
  }
}
