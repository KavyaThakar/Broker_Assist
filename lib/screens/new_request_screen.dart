import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_request.dart';
import '../providers/request_provider.dart';
import '../providers/auth_provider.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = 'Open Demat Account';
  final List<String> types = [
    'Open Demat Account',
    'Forgot Password',
    'Portfolio Report',
    'KYC Update',
    'Change Nominee',
    'Other'
  ];
  final TextEditingController descCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final reqProv = Provider.of<RequestProvider>(context, listen: false);
    final email = auth.currentUser?.email ?? 'unknown';

    setState(() => _loading = true);

    final req = ServiceRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: descCtrl.text.trim(),
      status: 'pending',
      createdByEmail: email,
      createdAt: DateTime.now(),
    );

    await reqProv.createRequest(
        req, email, (auth.currentUser?.role ?? '').toLowerCase() == 'broker');

    setState(() => _loading = false);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Request created')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Service Request')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: title,
                  decoration: const InputDecoration(
                      labelText: 'Request Type', border: OutlineInputBorder()),
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => title = v);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter description'
                      : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Submit Request'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
