import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EcoSea", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff0077B6),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Welcome to EcoSea",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}