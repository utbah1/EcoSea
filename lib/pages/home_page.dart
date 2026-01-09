import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/home_menu_item.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/ecosea_map_view.dart';
import '../pages2/pelaporan_page.dart';
import '../pages2/riwayat_page.dart';
import '../pages2/maps_page.dart';
import '../pages2/chatbot_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? userLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => isLoading = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() => isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B4D8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              const Text(
                "EcoSea",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// MAP MINI (sama persis: polygon + marker user)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: (isLoading || userLocation == null)
                        ? const Center(child: CircularProgressIndicator())
                        : EcoSeaMapView(
                            userLocation: userLocation!,
                            zoom: 15,
                            polygonBorderWidth: 2,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// MENU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
                      icon: Icons.history,
                      label: 'Riwayat',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RiwayatPage()),
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
              ),

              const SizedBox(height: 20),

              /// BERITA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Berita Terbaru",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Text("Konten Berita")),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      /// CHATBOT
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 96, 192),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotPage()),
        ),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }
}
