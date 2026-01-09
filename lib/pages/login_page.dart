import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/google_button.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0077B6), Color(0xff0096C7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/logo.png", width: 140),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(24),
                  width: 330,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 1,
                        color: Colors.black.withOpacity(.1),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff023E8A),
                          ),
                        ),
                        const SizedBox(height: 20),

                        InputField(
                          hint: "Email",
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return "Email tidak boleh kosong";
                            if (!_isValidEmail(value)) return "Format email tidak valid";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        InputField(
                          hint: "Password",
                          obscure: true,
                          controller: passCtrl,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return "Password tidak boleh kosong";
                            if (value.length < 6) return "Password minimal 6 karakter";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        MainButton(
                          text: "Login",
                          onPressed: () async {
                            // validasi form
                            if (!(_formKey.currentState?.validate() ?? false)) return;

                            final success = await auth.login(
                              emailCtrl.text.trim(),
                              passCtrl.text.trim(),
                            );

                            if (!mounted) return;

                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HomePage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.redAccent,
                                  content: const Text("Email atau password salah"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 10),
                        GoogleButton(onPressed: () {}),
                        const SizedBox(height: 15),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(color: Color(0xff023E8A)),
                          ),
                        ),
                      ],
                    ),
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
