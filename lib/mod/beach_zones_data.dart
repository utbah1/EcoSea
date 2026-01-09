import 'package:latlong2/latlong.dart';
import 'beach_zone.dart';

class BeachZonesData {
  static final List<BeachZone> zones = [
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
}
