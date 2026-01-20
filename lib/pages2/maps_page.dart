import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../mod/beach_zones_data.dart';
import '../mod/beach_zone.dart';
import '../pages2/camera_page.dart';
import '../widgets/ecosea_map_view.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();

  LatLng? userLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
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

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        userLocation = LatLng(pos.latitude, pos.longitude);
        isLoading = false;
      });

      _mapController.move(userLocation!, 15);
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // =========================
  // FIT FULL ZONE (POLYGON)
  // =========================
  LatLngBounds _boundsFromPoints(List<LatLng> pts) {
    double minLat = pts.first.latitude;
    double maxLat = pts.first.latitude;
    double minLng = pts.first.longitude;
    double maxLng = pts.first.longitude;

    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng), // southWest
      LatLng(maxLat, maxLng), // northEast
    );
  }

  void _goToZone(BeachZone zone) {
    final bounds = _boundsFromPoints(zone.area);

    // flutter_map v6+:
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60), // biar tidak mepet pinggir
      ),
    );

    // Kalau flutter_map kamu versi lama (fitCamera tidak ada), pakai ini:
    // _mapController.fitBounds(
    //   bounds,
    //   options: const FitBoundsOptions(padding: EdgeInsets.all(60)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final zones = BeachZonesData.zones;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Zona Kebersihan Pantai"),
        backgroundColor: const Color(0xFF00B4D8),
      ),
      body: Stack(
        children: [
          if (isLoading || userLocation == null)
            const Center(child: CircularProgressIndicator())
          else
            EcoSeaMapView(
              userLocation: userLocation!,
              zoom: 13,
              controller: _mapController,
              polygonBorderWidth: 3,
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.10,
            maxChildSize: 0.40,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Legenda Zona",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _legendItem(
                      color: Colors.green,
                      text: "Zona Hijau — Bersih",
                    ),
                    _legendItem(
                      color: Colors.orange,
                      text: "Zona Kuning — Perlu Perhatian",
                    ),
                    _legendItem(
                      color: Colors.red,
                      text: "Zona Merah — Kotor",
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0077B6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.report, color: Colors.white),
                      label: const Text(
                        "Laporkan Kondisi Pantai",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CameraPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Pindah ke Pantai",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ...zones.map(
                      (zone) => ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(zone.name),
                        onTap: () => _goToZone(zone),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
