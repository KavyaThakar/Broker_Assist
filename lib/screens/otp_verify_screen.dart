import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  const OtpVerifyScreen({super.key, required this.phone});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController otpCtrl = TextEditingController();
  bool loading = false;

  Future<void> _verify() async {
    if (otpCtrl.text.trim().isEmpty) return;

    setState(() => loading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.verifyOtp(otpCtrl.text.trim());

    setState(() => loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("OTP sent to: ${widget.phone}"),
            const SizedBox(height: 20),
            TextField(
              controller: otpCtrl,
              decoration: const InputDecoration(labelText: "OTP"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _verify,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
