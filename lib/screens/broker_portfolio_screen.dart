import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/portfolio_provider.dart';

class BrokerPortfolioScreen extends StatefulWidget {
  const BrokerPortfolioScreen({super.key});

  @override
  State<BrokerPortfolioScreen> createState() => _BrokerPortfolioScreenState();
}

class _BrokerPortfolioScreenState extends State<BrokerPortfolioScreen> {
  String? selectedEmail;
  final investedCtrl = TextEditingController();
  final currentCtrl = TextEditingController();

  bool boot = true;
  bool loadingPortfolio = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await Provider.of<AuthProvider>(context, listen: false).refreshUsers();

      if (mounted) setState(() => boot = false);
    });
  }

  @override
  void dispose() {
    investedCtrl.dispose();
    currentCtrl.dispose();
    super.dispose();
  }

  Future<void> loadPortfolio() async {
    if (selectedEmail == null) return;

    setState(() => loadingPortfolio = true);

    final p = Provider.of<PortfolioProvider>(context, listen: false);
    await p.load(selectedEmail!);

    final list = p.getList(selectedEmail!);

    if (list.isNotEmpty) {
      investedCtrl.text = list.first.invested.toStringAsFixed(2);
      currentCtrl.text = list.first.currentValue.toStringAsFixed(2);
    } else {
      investedCtrl.clear();
      currentCtrl.clear();
    }

    if (!mounted) return;
    setState(() => loadingPortfolio = false);
  }

  @override
  Widget build(BuildContext context) {
    if (boot) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final auth = Provider.of<AuthProvider>(context);
    final clients =
        auth.allUsers.where((u) => u.role.toLowerCase() == "client").toList();

    final port = Provider.of<PortfolioProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Client Portfolios")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedEmail,
              decoration: const InputDecoration(
                labelText: "Select Client",
              ),
              items: clients.map((u) {
                return DropdownMenuItem(
                  value: u.email,
                  child: Text(u.name),
                );
              }).toList(),
              onChanged: (v) async {
                selectedEmail = v;
                await loadPortfolio();
              },
            ),
            const SizedBox(height: 22),
            if (loadingPortfolio)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  TextField(
                    controller: investedCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Invested",
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: currentCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Current Value",
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectedEmail == null
                        ? null
                        : () async {
                            final inv = double.tryParse(investedCtrl.text);
                            final cur = double.tryParse(currentCtrl.text);

                            if (inv == null || cur == null) return;

                            await port.addEntry(
                              email: selectedEmail!,
                              invested: inv,
                              currentValue: cur,
                            );

                            await loadPortfolio();
                          },
                    child: const Text("Save New Entry"),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            if (selectedEmail != null)
              Builder(
                builder: (_) {
                  final records = port.getList(selectedEmail!);

                  if (records.isEmpty) {
                    return const Text("No history");
                  }

                  final entry = records.first;

                  return Card(
                    child: ListTile(
                      title: Text(
                          "Invested ₹${entry.invested} → Current ₹${entry.currentValue}"),
                      subtitle: Text(entry.lastUpdated.toString()),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
