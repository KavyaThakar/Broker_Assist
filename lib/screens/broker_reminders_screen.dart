// lib/screens/broker_reminders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reminder_provider.dart';
import '../providers/auth_provider.dart';
import '../models/reminder_model.dart';

class BrokerRemindersScreen extends StatefulWidget {
  const BrokerRemindersScreen({super.key});

  @override
  State<BrokerRemindersScreen> createState() => _BrokerRemindersScreenState();
}

class _BrokerRemindersScreenState extends State<BrokerRemindersScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _detailsCtrl = TextEditingController();

  DateTime? _selectedDate;
  String _selectedClientEmail = "none";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.refreshUsers();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final reminderProv = Provider.of<ReminderProvider>(context);

    final brokerEmail = auth.currentUser!.email;

    /// reminders created by broker
    final all = reminderProv.createdBy(brokerEmail);

    final pending = all.where((r) => !r.done).toList();
    final completed = all.where((r) => r.done).toList();

    /// users
    final clients = auth
        .getAllUsers()
        .where((u) => u.role.toLowerCase() == "client")
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Reminders")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                  hintText: "Reminder title", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailsCtrl,
              decoration: const InputDecoration(
                  hintText: "Details (optional)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedClientEmail,
              items: [
                const DropdownMenuItem(
                    value: "none", child: Text("General reminder")),
                ...clients.map(
                  (u) => DropdownMenuItem(
                    value: u.email,
                    child: Text(u.name),
                  ),
                )
              ],
              onChanged: (v) => setState(() => _selectedClientEmail = v!),
              decoration: const InputDecoration(
                  labelText: "Assign", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );

                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Text(_selectedDate == null
                  ? "Pick due date"
                  : "Due: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                if (_titleCtrl.text.trim().isEmpty) {
                  return;
                }

                if (_selectedDate == null) {
                  return;
                }

                await reminderProv.addReminder(
                  title: _titleCtrl.text.trim(),
                  details: _detailsCtrl.text.trim(),
                  dueAt: _selectedDate!,
                  createdByEmail: brokerEmail,
                  clientEmail: _selectedClientEmail == "none"
                      ? null
                      : _selectedClientEmail,
                );

                _titleCtrl.clear();
                _detailsCtrl.clear();
                _selectedClientEmail = "none";
                _selectedDate = null;
              },
              child: const Text("Create Reminder"),
            ),
            const SizedBox(height: 30),
            const Text("Pending",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...pending.map(
              (r) => ListTile(
                title: Text(r.title),
                subtitle: Text("${r.dueAt.day}/${r.dueAt.month}/${r.dueAt.year}"
                    "${r.clientEmail != null ? " – ${r.clientEmail}" : ""}"),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => reminderProv.toggleDone(r.id),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
