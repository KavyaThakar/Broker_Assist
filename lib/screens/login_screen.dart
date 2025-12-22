import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/request_provider.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'phone_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool loading = false;
  bool hidePass = true;

  Future<void> _tryLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => loading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final reqProv = Provider.of<RequestProvider>(context, listen: false);

    final err = await auth.login(
      email: emailCtrl.text.trim(),
      password: passCtrl.text,
    );

    setState(() => loading = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }

    final user = auth.currentUser!;
    final isBroker = user.role.toLowerCase() == "broker";

    await reqProv.load(user.email, isBroker);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter email";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passCtrl,
                  obscureText: hidePass,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePass ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => hidePass = !hidePass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return "Invalid password";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text("Forgot password?"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: loading ? null : _tryLogin,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                  ),
                ),

                const SizedBox(height: 20),

                // PHONE OTP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PhoneLoginScreen(),
                        ),
                      );
                    },
                    child: const Text("Login using Phone OTP"),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text("Register"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
