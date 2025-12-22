import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import '../models/user_model.dart';

class BrokerReportsScreen extends StatefulWidget {
  const BrokerReportsScreen({super.key});

  @override
  State<BrokerReportsScreen> createState() => _BrokerReportsScreenState();
}

class _BrokerReportsScreenState extends State<BrokerReportsScreen> {
  String? selectedClient;
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String selectedType = "Ledger";

  final List<String> types = [
    "Ledger",
    "Contract Note",
    "Holding Statement",
    "P&L Report",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final reportProv = Provider.of<ReportProvider>(context);

    List<UserModel> users = auth
        .getAllUsers()
        .where((u) => u.role.toLowerCase() != "broker")
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Reports")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CLIENT DROPDOWN
              const Text("Select Client",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedClient,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: users
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.email,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedClient = v),
                hint: const Text("Choose client"),
              ),

              const SizedBox(height: 20),

              // TYPE SELECTOR
              const Text("Report Type",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: types
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v!),
              ),

              const SizedBox(height: 20),

              // TITLE
              const Text("Report Title",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "e.g. Ledger April 2025",
                ),
              ),

              const SizedBox(height: 20),

              // DESCRIPTION
              const Text("Description (optional)",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              TextField(
                controller: descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "notes...",
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedClient == null ||
                        titleCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Select client & enter report title"),
                        ),
                      );
                      return;
                    }

                    await reportProv.addReport(
                      clientEmail: selectedClient!,
                      title: titleCtrl.text.trim(),
                      type: selectedType,
                      date: DateTime.now(),
                      description: descCtrl.text.trim(),
                    );

                    titleCtrl.clear();
                    descCtrl.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Report added successfully!"),
                      ),
                    );
                  },
                  child: const Text("Add Report"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
