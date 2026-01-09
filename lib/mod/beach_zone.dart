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
        return Colors.green.withValues(alpha: 0.30);
      case ZoneStatus.perhatian:
        return Colors.orange.withValues(alpha: 0.30);
      case ZoneStatus.kotor:
        return Colors.red.withValues(alpha: 0.30);
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
