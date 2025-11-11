import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const EcoSeaApp());
}

class EcoSeaApp extends StatelessWidget {
  const EcoSeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSea',
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}