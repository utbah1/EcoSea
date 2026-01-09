import 'package:flutter/material.dart';
import 'login_page.dart';
import '../widgets/main_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/logo.png", width: 170),
                  const SizedBox(height: 22),

                  const Text(
                    "Selamat Datang!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Mulai perjalananmu sekarang.\nPantau, laporkan, dan ikut aksi menjaga ekosistem laut.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  MainButton(
                    text: "Get Started",
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}