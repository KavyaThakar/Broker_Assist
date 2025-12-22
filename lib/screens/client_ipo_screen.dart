import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ipo_provider.dart';

class ClientIpoScreen extends StatefulWidget {
  const ClientIpoScreen({super.key});

  @override
  State<ClientIpoScreen> createState() => _ClientIpoScreenState();
}

class _ClientIpoScreenState extends State<ClientIpoScreen> {
  bool called = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (called) return;
    called = true;

    final p = Provider.of<IpoProvider>(context, listen: false);
    p.load();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<IpoProvider>(context);

    if (!p.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ipos = p.allIpos;

    return Scaffold(
      appBar: AppBar(title: const Text("IPO Calendar")),
      body: ipos.isEmpty
          ? const Center(child: Text("No IPO entries"))
          : ListView.builder(
              itemCount: ipos.length,
              itemBuilder: (_, i) => ListTile(
                title: Text("${ipos[i].name} (${ipos[i].symbol})"),
              ),
            ),
    );
  }
}
