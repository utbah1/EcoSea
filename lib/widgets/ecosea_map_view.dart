import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../mod/beach_zones_data.dart';

class EcoSeaMapView extends StatelessWidget {
  final LatLng userLocation;
  final double zoom;
  final MapController? controller;
  final double polygonBorderWidth;

  const EcoSeaMapView({
    super.key,
    required this.userLocation,
    this.zoom = 15,
    this.controller,
    this.polygonBorderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final zones = BeachZonesData.zones;

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: userLocation,
        initialZoom: zoom,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.ecosea',
        ),

        PolygonLayer(
          polygons: zones
              .map(
                (z) => Polygon(
                  points: z.area,
                  color: z.fillColor,
                  isFilled: true,
                  borderColor: z.borderColor,
                  borderStrokeWidth: polygonBorderWidth,
                ),
              )
              .toList(),
        ),

        MarkerLayer(
          markers: [
            Marker(
              point: userLocation,
              width: 46,
              height: 46,
              child: const Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 46,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
