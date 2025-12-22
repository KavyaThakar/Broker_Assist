import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'otp_verify_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController phoneCtrl = TextEditingController();
  bool loading = false;

  Future<void> sendOTP() async {
    if (phoneCtrl.text.trim().isEmpty) return;

    setState(() => loading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.sendOtp(phoneCtrl.text.trim());

    setState(() => loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerifyScreen(
          phone: phoneCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number (+91...)",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : sendOTP,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
