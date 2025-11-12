import 'package:flutter/material.dart';
import '../widgets/home_menu_item.dart';
import '../widgets/bottom_navbar.dart';
import '../pages2/berita_page.dart';
import '../pages2/maps_page.dart';
import '../pages2/pelaporan_page.dart';
import '../pages2/riwayat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B4D8),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 120,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'EcoSea',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // Menu utama 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        HomeMenuItem(
                          icon: Icons.campaign,
                          label: 'Pelaporan',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PelaporanPage()),
                          ),
                        ),
                        HomeMenuItem(
                          icon: Icons.article,
                          label: 'Berita',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BeritaPage()),
                          ),
                        ),
                        HomeMenuItem(
                          icon: Icons.map,
                          label: 'Maps',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapsPage()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: HomeMenuItem(
                        icon: Icons.history,
                        label: 'Riwayat',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RiwayatPage()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }
}