import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/corporate_action_provider.dart';

class ClientCorporateActionsScreen extends StatefulWidget {
  const ClientCorporateActionsScreen({super.key});

  @override
  State<ClientCorporateActionsScreen> createState() =>
      _ClientCorporateActionsScreenState();
}

class _ClientCorporateActionsScreenState
    extends State<ClientCorporateActionsScreen> {
  bool _initCalled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initCalled) {
      _initCalled = true;
      final actionProv =
          Provider.of<CorporateActionProvider>(context, listen: false);
      Future.microtask(() => actionProv.load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionProv = Provider.of<CorporateActionProvider>(context);

    if (!actionProv.loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Corporate Actions')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final actions = actionProv.allActions;

    return Scaffold(
      appBar: AppBar(title: const Text('Corporate Actions')),
      body: SafeArea(
        child: actions.isEmpty
            ? const Center(child: Text('No corporate actions yet'))
            : ListView.builder(
                itemCount: actions.length,
                itemBuilder: (_, i) {
                  final a = actions[i];
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final record = DateTime(
                      a.recordDate.year, a.recordDate.month, a.recordDate.day);
                  final status = record.isAfter(today) ? 'UPCOMING' : 'PAST';

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text('${a.companyName} (${a.symbol})'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${a.type}'),
                          Text(
                              'Record: ${_formatDate(a.recordDate)} | Ex: ${_formatDate(a.exDate)}'),
                          if (a.details.isNotEmpty) Text(a.details),
                          Text('Status: $status'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
