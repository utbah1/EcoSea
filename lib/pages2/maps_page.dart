import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/main_button.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();

  final LatLng pantaiMuarareja = LatLng(-6.844831671563333, 109.11483751724678);
  final LatLng pantaiAlamIndah = LatLng(-6.848164135696889, 109.14265837853888);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps"),
        backgroundColor: const Color(0xFF00B4D8),
      ),
      body: Column(
        children: [
          // ================= MAP =================
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: pantaiMuarareja,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ecosea',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: pantaiMuarareja,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: pantaiAlamIndah,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MainButton(
                  text: "Pantai Muarareja",
                  onPressed: () {
                    _mapController.move(pantaiMuarareja, 16);
                  },
                ),
                const SizedBox(height: 12),
                MainButton(
                  text: "Pantai Alam Indah",
                  onPressed: () {
                    _mapController.move(pantaiAlamIndah, 16);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}