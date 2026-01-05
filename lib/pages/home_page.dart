import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/home_menu_item.dart';
import '../widgets/bottom_navbar.dart';
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
  LatLng? currentLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      isLoading = false;
    });
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

              /// HEADER
              const Text(
                "EcoSea",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// MAP
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
                    child: isLoading || currentLocation == null
                        ? const Center(child: CircularProgressIndicator())
                        : FlutterMap(
                            options: MapOptions(
                              initialCenter: currentLocation!,
                              initialZoom: 16,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                userAgentPackageName: 'com.example.ecosea',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: currentLocation!,
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                        MaterialPageRoute(
                          builder: (_) => const PelaporanPage(),
                        ),
                      ),
                    ),
                    HomeMenuItem(
                      icon: Icons.history,
                      label: 'Riwayat',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RiwayatPage(),
                        ),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text("Konten Berita"),
                      ),
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
        backgroundColor: const Color(0xFF1E40FF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatbotPage(),
            ),
          );
        },
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      /// NAVBAR
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }
}
