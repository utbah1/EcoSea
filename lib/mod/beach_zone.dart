import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum ZoneStatus { bersih, perhatian, kotor }

class BeachZone {
  final String name;
  final ZoneStatus status;
  final List<LatLng> area;

  BeachZone({
    required this.name,
    required this.status,
    required this.area,
  });

  Color get fillColor {
    switch (status) {
      case ZoneStatus.bersih:
        return Colors.green.withOpacity(0.35);
      case ZoneStatus.perhatian:
        return Colors.orange.withOpacity(0.35);
      case ZoneStatus.kotor:
        return Colors.red.withOpacity(0.35);
    }
  }

  Color get borderColor {
    switch (status) {
      case ZoneStatus.bersih:
        return Colors.green;
      case ZoneStatus.perhatian:
        return Colors.orange;
      case ZoneStatus.kotor:
        return Colors.red;
    }
  }
}
