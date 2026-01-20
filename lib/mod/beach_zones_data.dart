import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'beach_zone.dart';

enum ZoneAutoShape { raw, hull, block }

class BeachZonesData {
  static const ZoneAutoShape autoShape = ZoneAutoShape.hull;

  static final List<BeachZone> zones = [
    BeachZone(
      name: "Pantai Alam Indah",
      status: ZoneStatus.kotor,
      area: _apply([
        LatLng(-6.8471454, 109.1402300),
        LatLng(-6.8479230, 109.1400798),
        LatLng(-6.8482000, 109.1412064),
        LatLng(-6.8510015, 109.1418286),
        LatLng(-6.8504157, 109.1437598),
        LatLng(-6.8509470, 109.1461389),
        LatLng(-6.8495954, 109.1463991),
        LatLng(-6.8495848, 109.1482767),
        LatLng(-6.8497255, 109.1509452),
        LatLng(-6.8498750, 109.1530775),
        LatLng(-6.8501676, 109.1567287),
        LatLng(-6.8502676, 109.1586772),
        LatLng(-6.8499495, 109.1595264),
        LatLng(-6.8484699, 109.1599128),
        LatLng(-6.8479175, 109.1603555),
        LatLng(-6.8450995, 109.1609678),
        LatLng(-6.8444371, 109.1608768),
        LatLng(-6.8440292, 109.1606120),
        LatLng(-6.8437456, 109.1599410),
        LatLng(-6.8439375, 109.1588977),
        LatLng(-6.8443053, 109.1571101),
        LatLng(-6.8457711, 109.1506142),
        LatLng(-6.8474596, 109.1413378),
        LatLng(-6.8477460, 109.1410103),
        LatLng(-6.8475310, 109.1406790),
        LatLng(-6.8474596, 109.1405094),
        LatLng(-6.8471454, 109.1402300),
      ]),
    ),

    BeachZone(
      name: "Pantai Pulau Purwahamba",
      status: ZoneStatus.bersih,
      area: _apply([
        LatLng(-6.8733813, 109.2577104),
        LatLng(-6.8721510, 109.2578392),
        LatLng(-6.8725824, 109.2623399),
        LatLng(-6.8720978, 109.2623614),
        LatLng(-6.8715226, 109.2578606),
        LatLng(-6.8711391, 109.2578928),
        LatLng(-6.8710219, 109.2565624),
        LatLng(-6.8713042, 109.2564927),
        LatLng(-6.8732721, 109.2556746),
        LatLng(-6.8733813, 109.2577104),
      ]),
    ),

    BeachZone(
      name: "Pantai Muarareja",
      status: ZoneStatus.perhatian,
      area: _apply([
        LatLng(-6.8421170, 109.1083408),
        LatLng(-6.8415857, 109.1089135),
        LatLng(-6.8428730, 109.1107660),
        LatLng(-6.8442395, 109.1124125),
        LatLng(-6.8451200, 109.1140646),
        LatLng(-6.8465617, 109.1169401),
        LatLng(-6.8464900, 109.1182094),
        LatLng(-6.8480423, 109.1203679),
        LatLng(-6.8484525, 109.1219182),
        LatLng(-6.8492355, 109.1246112),
        LatLng(-6.8482075, 109.1249652),
        LatLng(-6.8472434, 109.1210170),
        LatLng(-6.8421170, 109.1083408),
      ]),
    ),

    BeachZone(
      name: "Pantai Larangan",
      status: ZoneStatus.perhatian,
      area: _apply([
        LatLng(-6.8557406, 109.1807816),
        LatLng(-6.8567526, 109.1801218),
        LatLng(-6.8577425, 109.1860505),
        LatLng(-6.8583584, 109.1867012),
        LatLng(-6.8589396, 109.1891775),
        LatLng(-6.8602678, 109.1929266),
        LatLng(-6.8621319, 109.1922293),
        LatLng(-6.8591860, 109.1900265),
        LatLng(-6.8580965, 109.1898692),
        LatLng(-6.8580509, 109.1894330),
        LatLng(-6.8557406, 109.1807816),
      ]),
    ),
  ];

  // =========================
  // APPLY MODE
  // =========================
  static List<LatLng> _apply(List<LatLng> raw) {
    final cleaned = _dedupe(raw);
    if (cleaned.length < 3) return cleaned;

    switch (autoShape) {
      case ZoneAutoShape.raw:
        return _ensureClosed(cleaned);

      case ZoneAutoShape.hull:
        return _ensureClosed(_convexHull(cleaned));

      case ZoneAutoShape.block:
        return _ensureClosed(_makeBeachBlock(cleaned, thicknessFactor: 0.12));
    }
  }

  static List<LatLng> _dedupe(List<LatLng> pts) {
    // dedupe by rounding (biar stabil)
    final seen = <String>{};
    final out = <LatLng>[];
    for (final p in pts) {
      final k =
          "${p.latitude.toStringAsFixed(7)},${p.longitude.toStringAsFixed(7)}";
      if (seen.add(k)) out.add(p);
    }
    return out;
  }

  static List<LatLng> _ensureClosed(List<LatLng> pts) {
    if (pts.isEmpty) return pts;
    final first = pts.first;
    final last = pts.last;
    if (first.latitude == last.latitude && first.longitude == last.longitude) {
      return pts;
    }
    return [...pts, first];
  }

  // =========================
  // CONVEX HULL (Monotonic Chain)
  // hasil: bukan kotak, tapi 1 polygon rapi mengikuti "kulit terluar"
  // =========================
  static List<LatLng> _convexHull(List<LatLng> pts) {
    if (pts.length <= 3) return pts;

    // sort by lon then lat
    final p = [...pts];
    p.sort((a, b) {
      final c = a.longitude.compareTo(b.longitude);
      return c != 0 ? c : a.latitude.compareTo(b.latitude);
    });

    double cross(LatLng o, LatLng a, LatLng b) {
      final ox = o.longitude, oy = o.latitude;
      final ax = a.longitude, ay = a.latitude;
      final bx = b.longitude, by = b.latitude;
      return (ax - ox) * (by - oy) - (ay - oy) * (bx - ox);
    }

    final lower = <LatLng>[];
    for (final pt in p) {
      while (lower.length >= 2 &&
          cross(lower[lower.length - 2], lower.last, pt) <= 0) {
        lower.removeLast();
      }
      lower.add(pt);
    }

    final upper = <LatLng>[];
    for (final pt in p.reversed) {
      while (upper.length >= 2 &&
          cross(upper[upper.length - 2], upper.last, pt) <= 0) {
        upper.removeLast();
      }
      upper.add(pt);
    }

    // remove last because it repeats start point
    lower.removeLast();
    upper.removeLast();
    return [...lower, ...upper];
  }

  // =========================
  // BLOCK (kotak miring) - kalau kamu mau mode ini lagi
  // =========================
  static List<LatLng> _makeBeachBlock(
    List<LatLng> points, {
    double thicknessFactor = 0.12,
  }) {
    if (points.length < 3) return points;

    // mean
    double mx = 0, my = 0;
    for (final p in points) {
      mx += p.longitude;
      my += p.latitude;
    }
    mx /= points.length;
    my /= points.length;

    // covariance
    double a = 0, b = 0, c = 0;
    for (final p in points) {
      final dx = p.longitude - mx;
      final dy = p.latitude - my;
      a += dx * dx;
      b += dx * dy;
      c += dy * dy;
    }
    a /= points.length;
    b /= points.length;
    c /= points.length;

    final theta = 0.5 * math.atan2(2 * b, a - c);
    final ux = math.cos(theta), uy = math.sin(theta);
    final vx = -math.sin(theta), vy = math.cos(theta);

    double minU = double.infinity, maxU = -double.infinity;
    double minV = double.infinity, maxV = -double.infinity;

    for (final p in points) {
      final dx = p.longitude - mx;
      final dy = p.latitude - my;
      final U = dx * ux + dy * uy;
      final V = dx * vx + dy * vy;
      if (U < minU) minU = U;
      if (U > maxU) maxU = U;
      if (V < minV) minV = V;
      if (V > maxV) maxV = V;
    }

    final centerV = (minV + maxV) / 2;
    final halfV = ((maxV - minV) / 2) * thicknessFactor;
    final v1 = centerV - halfV;
    final v2 = centerV + halfV;

    LatLng corner(double U, double V) {
      final x = mx + ux * U + vx * V;
      final y = my + uy * U + vy * V;
      return LatLng(y, x);
    }

    return [
      corner(minU, v1),
      corner(maxU, v1),
      corner(maxU, v2),
      corner(minU, v2),
    ];
  }
}
