import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecosea/mod/beach_zone.dart';

void main() {
  group('Unit Test - BeachZone warna berdasarkan status', () {
    test('ZoneStatus.bersih -> hijau', () {
      final z = BeachZone(name: 'Z', status: ZoneStatus.bersih, area: const []);

      expect(z.borderColor, Colors.green);
      expect(z.fillColor.red, Colors.green.red);
      expect(z.fillColor.green, Colors.green.green);
      expect(z.fillColor.blue, Colors.green.blue);
      expect(z.fillColor.opacity, closeTo(0.30, 0.02));
    });

    test('ZoneStatus.perhatian -> oranye', () {
      final z = BeachZone(name: 'Z', status: ZoneStatus.perhatian, area: const []);

      expect(z.borderColor, Colors.orange);
      expect(z.fillColor.red, Colors.orange.red);
      expect(z.fillColor.green, Colors.orange.green);
      expect(z.fillColor.blue, Colors.orange.blue);
      expect(z.fillColor.opacity, closeTo(0.30, 0.02));
    });

    test('ZoneStatus.kotor -> merah', () {
      final z = BeachZone(name: 'Z', status: ZoneStatus.kotor, area: const []);

      expect(z.borderColor, Colors.red);
      expect(z.fillColor.red, Colors.red.red);
      expect(z.fillColor.green, Colors.red.green);
      expect(z.fillColor.blue, Colors.red.blue);
      expect(z.fillColor.opacity, closeTo(0.30, 0.02));
    });
  });
}
