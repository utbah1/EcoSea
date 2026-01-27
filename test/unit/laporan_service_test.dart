import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecosea/services/auth_expired_exception.dart';
import 'package:ecosea/services/laporan_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Unit Test - LaporanService (token & local storage)', () {
    setUp(() async {
      // Membuat SharedPreferences dalam mode mock agar tidak menyentuh storage asli.
      SharedPreferences.setMockInitialValues({});
    });

    test('getLaporanTerbaru() melempar AuthExpiredException jika token belum ada', () async {
      final service = LaporanService();
      expect(
        () => service.getLaporanTerbaru(limit: 3),
        throwsA(isA<AuthExpiredException>()),
      );
    });

    test('getLaporanUser() melempar AuthExpiredException jika token kosong', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', '   ');

      final service = LaporanService();
      expect(
        () => service.getLaporanUser(),
        throwsA(isA<AuthExpiredException>()),
      );
    });
  });
}
