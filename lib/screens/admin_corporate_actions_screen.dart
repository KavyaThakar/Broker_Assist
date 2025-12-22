import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/corporate_action_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

import '../models/corporate_action_item.dart';
import '../models/user_model.dart';

class AdminCorporateActionsScreen extends StatefulWidget {
  const AdminCorporateActionsScreen({super.key});

  @override
  State<AdminCorporateActionsScreen> createState() =>
      _AdminCorporateActionsScreenState();
}

class _AdminCorporateActionsScreenState
    extends State<AdminCorporateActionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _symbolCtrl = TextEditingController();
  final TextEditingController _detailsCtrl = TextEditingController();

  String _type = "Dividend";
  DateTime? _recordDate;
  DateTime? _exDate;
  bool _notifyAll = true;
  bool _initLoad = false;

  /// NEW MULTI-CLIENT SELECTION LIST
  final List<UserModel> _selectedUsers = [];

  final List<String> actionTypes = [
    "Dividend",
    "Bonus",
    "Rights",
    "Split",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initLoad) return;
    _initLoad = true;

    Provider.of<CorporateActionProvider>(context, listen: false).load();
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _symbolCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool record) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() {
      if (record) {
        _recordDate = picked;
      } else {
        _exDate = picked;
      }
    });
  }

  Future<void> _submit(List<UserModel> allUsers) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_recordDate == null || _exDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select record & ex-date")),
      );
      return;
    }

    if (!_notifyAll && _selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one client")),
      );
      return;
    }

    final corporateProv =
        Provider.of<CorporateActionProvider>(context, listen: false);

    final notifProv = Provider.of<NotificationProvider>(context, listen: false);

    final CorporateActionItem model = CorporateActionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: _companyCtrl.text.trim(),
      symbol: _symbolCtrl.text.trim().toUpperCase(),
      type: _type,
      recordDate: _recordDate!,
      exDate: _exDate!,
      details: _detailsCtrl.text.trim(),
    );

    await corporateProv.addAction(model);

    if (_notifyAll) {
      for (final u in allUsers) {
        if (u.role.toLowerCase() != "broker") {
          await notifProv.addNotification(
            forEmail: u.email,
            title: "${model.companyName} Corporate Action",
            body:
                "${model.companyName} announced ${model.type}. Record date: ${_formatDate(model.recordDate)}",
          );
        }
      }
    } else {
      for (final target in _selectedUsers) {
        await notifProv.addNotification(
          forEmail: target.email,
          title: "${model.companyName} Corporate Action",
          body:
              "${model.companyName} announced ${model.type}. Record date: ${_formatDate(model.recordDate)}",
        );
      }
    }

    _companyCtrl.clear();
    _symbolCtrl.clear();
    _detailsCtrl.clear();

    setState(() {
      _type = "Dividend";
      _exDate = null;
      _recordDate = null;
      _notifyAll = true;
      _selectedUsers.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Corporate Action Added")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actionProv = Provider.of<CorporateActionProvider>(context);
    final actions = actionProv.allActions;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final allUsers = auth
        .getAllUsers()
        .where((u) => u.role.toLowerCase() == "client")
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Corporate Actions")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _input(_companyCtrl, "Company Name", true),
                  _input(_symbolCtrl, "Symbol", true),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _type,
                    items: actionTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v!),
                    decoration: const InputDecoration(
                      labelText: "Corporate Action",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _datePickers(),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: _notifyAll,
                    title: const Text("Notify all clients"),
                    onChanged: (v) {
                      setState(() {
                        _notifyAll = v ?? true;
                        if (_notifyAll) _selectedUsers.clear();
                      });
                    },
                  ),
                  if (!_notifyAll) _multiSelect(allUsers),
                  ElevatedButton(
                    onPressed: () => _submit(allUsers),
                    child: const Text("Add Action"),
                  ),
                ],
              ),
            ),
            const Divider(),
            actions.isEmpty
                ? const Text("No corporate actions yet")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actions.length,
                    itemBuilder: (_, i) {
                      final a = actions[i];
                      return ListTile(
                        title: Text("${a.companyName} (${a.symbol})"),
                        subtitle: Text(
                            "${a.type} | Record: ${_formatDate(a.recordDate)}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => actionProv.deleteAction(a.id),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _input(controller, label, validate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validate ? (v) => v!.isEmpty ? "Required" : null : null,
      ),
    );
  }

  Widget _datePickers() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _selectDate(true),
            child: Text(_recordDate == null
                ? "Record Date"
                : _formatDate(_recordDate!)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _selectDate(false),
            child: Text(_exDate == null ? "Ex-Date" : _formatDate(_exDate!)),
          ),
        ),
      ],
    );
  }

  Widget _multiSelect(List<UserModel> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Clients"),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: users.map((u) {
            final active = _selectedUsers.contains(u);

            return FilterChip(
              label: Text(u.name),
              selected: active,
              onSelected: (v) {
                setState(() {
                  if (active) {
                    _selectedUsers.remove(u);
                  } else {
                    _selectedUsers.add(u);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";
}
