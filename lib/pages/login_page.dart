import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/google_button.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                  child: Column(
                    children: [
                      const Text("Welcome Back",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff023E8A))),
                      const SizedBox(height: 20),

                      const InputField(hint: "Email"),
                      const SizedBox(height: 16),
                      const InputField(hint: "Password", obscure: true),
                      const SizedBox(height: 20),

                      MainButton(
                        text: "Login",
                        onPressed: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const HomePage()));
                        },
                      ),
                      const SizedBox(height: 10),

                      GoogleButton(onPressed: () {}),
                      const SizedBox(height: 15),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()));
                        },
                        child: const Text(
                          "Don't have an account? Register",
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