import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/main_button.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                  ),
                  child: Column(
                    children: [
                      const Text("Create Account",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff023E8A))),
                      const SizedBox(height: 20),
                      const InputField(hint: "Full Name"),
                      const SizedBox(height: 16),
                      const InputField(hint: "Email"),
                      const SizedBox(height: 16),
                      const InputField(hint: "Password", obscure: true),
                      const SizedBox(height: 20),

                      MainButton(
                        text: "Register",
                        onPressed: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LoginPage()));
                        },
                      ),

                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Color(0xff023E8A)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}