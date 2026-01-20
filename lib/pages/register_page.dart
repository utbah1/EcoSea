import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/main_button.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final namaCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final auth = AuthService();

  @override
  void dispose() {
    namaCtrl.dispose();
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
                    color: Colors.white.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff023E8A),
                          ),
                        ),
                        const SizedBox(height: 20),

                        InputField(
                          hint: "Full Name",
                          controller: namaCtrl,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return "Nama tidak boleh kosong";
                            if (value.length < 3) return "Nama minimal 3 karakter";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

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
                          text: "Register",
                          onPressed: () async {
                            if (!(_formKey.currentState?.validate() ?? false)) return;

                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final success = await auth.register(
                              namaCtrl.text.trim(),
                              emailCtrl.text.trim(),
                              passCtrl.text.trim(),
                            );

                            if (!mounted) return;

                            if (success) {
                              messenger.showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xff0077B6),
                                  content: const Text("Register berhasil, silakan login"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );

                              navigator.pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.redAccent,
                                  content: const Text("Register gagal"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                        ),


                        const SizedBox(height: 15),

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Already have an account? Login",
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
