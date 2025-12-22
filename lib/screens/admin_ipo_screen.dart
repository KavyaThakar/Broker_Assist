import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ipo_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

import '../models/ipo_item.dart';
import '../models/user_model.dart';

class AdminIpoScreen extends StatefulWidget {
  const AdminIpoScreen({super.key});

  @override
  State<AdminIpoScreen> createState() => _AdminIpoScreenState();
}

class _AdminIpoScreenState extends State<AdminIpoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _symbolCtrl = TextEditingController();
  final TextEditingController _priceBandCtrl = TextEditingController();
  final TextEditingController _lotSizeCtrl = TextEditingController();

  DateTime? _openDate;
  DateTime? _closeDate;
  bool _notifyAll = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _symbolCtrl.dispose();
    _priceBandCtrl.dispose();
    _lotSizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isOpen) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isOpen) {
        _openDate = picked;
      } else {
        _closeDate = picked;
      }
    });
  }

  Future<void> _submit(List<UserModel> users) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_openDate == null || _closeDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select open & close dates")),
      );
      return;
    }

    final ipoProv = Provider.of<IpoProvider>(context, listen: false);
    final notifProv = Provider.of<NotificationProvider>(context, listen: false);

    final ipo = IpoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      symbol: _symbolCtrl.text.trim(),
      openDate: _openDate!,
      closeDate: _closeDate!,
      priceBand: _priceBandCtrl.text.trim(),
      lotSize: int.tryParse(_lotSizeCtrl.text.trim()) ?? 0,
    );

    await ipoProv.addIpo(ipo);

    if (_notifyAll) {
      for (var u in users.where((x) => x.role == "client")) {
        await notifProv.addNotification(
          forEmail: u.email,
          title: "New IPO: ${ipo.name}",
          body: "${ipo.symbol} opens on ${_openDate!.day}/${_openDate!.month}",
        );
      }
    }

    _formKey.currentState?.reset();
    _openDate = null;
    _closeDate = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("IPO Added Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final ipoProv = Provider.of<IpoProvider>(context);

    final ipos = ipoProv.allIpos;
    final users = auth.getAllUsers();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage IPOs")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: "IPO Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _symbolCtrl,
                  decoration: const InputDecoration(labelText: "Symbol"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceBandCtrl,
                  decoration: const InputDecoration(labelText: "Price Band"),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _lotSizeCtrl,
                  decoration: const InputDecoration(labelText: "Lot Size"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(true),
                        child: Text(
                          _openDate == null
                              ? "Open Date"
                              : "${_openDate!.day}/${_openDate!.month}/${_openDate!.year}",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(false),
                        child: Text(
                          _closeDate == null
                              ? "Close Date"
                              : "${_closeDate!.day}/${_closeDate!.month}/${_closeDate!.year}",
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _notifyAll,
                      onChanged: (v) => setState(() => _notifyAll = v ?? true),
                    ),
                    const Text("Notify All Clients"),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _submit(users),
                  child: const Text("Add IPO"),
                ),
              ],
            ),
          ),
          const Divider(height: 40),
          ...ipos.map(
            (i) => Card(
              child: ListTile(
                title: Text("${i.name} (${i.symbol})"),
                subtitle: Text(
                  "Open: ${i.openDate.day}/${i.openDate.month} | "
                  "Close: ${i.closeDate.day}/${i.closeDate.month}",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
