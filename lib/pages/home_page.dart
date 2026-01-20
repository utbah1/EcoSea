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
import '../pages2/berita_detail_page.dart';
import '../mod/berita.dart';
import '../services/berita_service.dart';
import '../widgets/berita_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? userLocation;
  bool isLoading = true;

  final BeritaService _beritaService = BeritaService();
  late Future<List<Berita>> _beritaFuture;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _beritaFuture = _beritaService.getBerita(limit: 10);
  }

  Future<void> _reloadBerita() async {
    setState(() {
      _beritaFuture = _beritaService.getBerita(limit: 10);
    });
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
        child: RefreshIndicator(
          onRefresh: _reloadBerita,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCAF0F8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      child: Image.asset(
                        "assets/logo.png",
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EcoSea',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pantau, laporkan, dan jaga laut bersama.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF00B4D8),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// MAP MINI
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Berita Terbaru",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _reloadBerita,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Muat ulang'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 170,
                      child: FutureBuilder<List<Berita>>(
                        future: _beritaFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              itemBuilder: (_, __) => Container(
                                width: 260,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.wifi_off_rounded),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Gagal memuat berita. Tarik ke bawah untuk refresh.',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _reloadBerita,
                                    icon: const Icon(Icons.refresh),
                                  )
                                ],
                              ),
                            );
                          }

                          final beritaList = snapshot.data ?? [];
                          if (beritaList.isEmpty) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(16),
                              child: const Text(
                                'Belum ada berita. Admin bisa menambahkan berita dari panel web.',
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: beritaList.length,
                            itemBuilder: (context, index) {
                              final b = beritaList[index];
                              return BeritaCard(
                                berita: b,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BeritaDetailPage(berita: b),
                                  ),
                                ),
                              );
                            },
                          );
                        },
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
