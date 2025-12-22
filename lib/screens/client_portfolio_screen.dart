import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/portfolio_provider.dart';
import '../models/portfolio_model.dart';

class ClientPortfolioScreen extends StatelessWidget {
  const ClientPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final portProv = Provider.of<PortfolioProvider>(context);

    final email = auth.currentUser?.email ?? "";

    if (email.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    // cache empty = load portfolio
    final data = portProv.getList(email);
    if (data.isEmpty) {
      Future.microtask(() => portProv.load(email));

      return Scaffold(
        appBar: AppBar(title: const Text("Portfolio Snapshot")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final model = data.first;

    final pl = model.profitLoss;
    final plPct = model.profitLossPercent;

    return Scaffold(
      appBar: AppBar(title: const Text("Portfolio Snapshot")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Invested: ₹ ${model.invested}"),
            Text("Current: ₹ ${model.currentValue}"),
            Text("P&L: ₹${pl.toStringAsFixed(2)} ($plPct%)"),
          ],
        ),
      ),
    );
  }
}
