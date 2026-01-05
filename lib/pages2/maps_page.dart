import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../mod/beach_zone.dart';
import '../pages2/camera_page.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();
  LatLng? userLocation;

  final List<BeachZone> zones = [
    BeachZone(
      name: "Pantai Alam Indah",
      status: ZoneStatus.kotor,
      area: [
        LatLng(-6.847115971015506, 109.14129347904104),
        LatLng(-6.85100323342273, 109.14180373941849),
        LatLng(-6.847881187129092, 109.15918368300838),
        LatLng(-6.844154653565663, 109.16055758117015),
      ],
    ),
    BeachZone(
      name: "Pantai Muarareja",
      status: ZoneStatus.perhatian,
      area: [
        LatLng(-6.844984012485936, 109.11513522142523),
        LatLng(-6.84117838426469, 109.10964434846134),
        LatLng(-6.843284367875628, 109.10787506453357),
        LatLng(-6.847002680260289, 109.11370897206906),
        LatLng(-6.850829086817479, 109.1220843937877),
        LatLng(-6.84787642939037, 109.12287338278406),
      ],
    ),
    BeachZone(
      name: "Pantai Pulau Purwahamba",
      status: ZoneStatus.bersih,
      area: [
        LatLng(-6.869735033924242, 109.24829630093383),
        LatLng(-6.872461963918536, 109.24786610164195),
        LatLng(-6.873546416031571, 109.26000475081135),
        LatLng(-6.8720476405200825, 109.26038041743229),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    final data = await location.getLocation();

    setState(() {
      userLocation = LatLng(data.latitude!, data.longitude!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zona Kebersihan Pantai"),
        backgroundColor: const Color(0xFF00B4D8),
      ),
      body: Stack(
        children: [
          /// ================= MAP =================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(-6.8665, 109.1395),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.ecosea',
              ),

              /// ZONA POLYGON
              PolygonLayer(
                polygons: zones
                    .map(
                      (z) => Polygon(
                        points: z.area,
                        color: z.fillColor,
                        borderColor: z.borderColor,
                        borderStrokeWidth: 3,
                      ),
                    )
                    .toList(),
              ),

              /// USER LOCATION
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          /// ================= PANEL =================
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.10,
            maxChildSize: 0.40,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 6)
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    /// HANDLE
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
                        color: Colors.green, text: "Zona Hijau — Bersih"),
                    _legendItem(
                        color: Colors.orange,
                        text: "Zona Kuning — Perlu Perhatian"),
                    _legendItem(
                        color: Colors.red, text: "Zona Merah — Kotor"),

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
                          MaterialPageRoute(
                              builder: (_) => const CameraPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Pindah ke Pantai",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                    /// BUTTON PINDAH ZONA
                    ...zones.map(
                      (zone) => ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(zone.name),
                        onTap: () {
                          _mapController.move(zone.area.first, 15);
                        },
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
