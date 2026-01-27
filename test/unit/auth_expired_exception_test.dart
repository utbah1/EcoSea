import 'package:flutter_test/flutter_test.dart';

import 'package:ecosea/services/auth_expired_exception.dart';

void main() {
  group('Unit Test - AuthExpiredException', () {
    test('toString() mengembalikan message default', () {
      const e = AuthExpiredException();
      expect(e.toString(), contains('Sesi login habis'));
    });

    test('toString() mengembalikan message custom', () {
      const e = AuthExpiredException('Token expired');
      expect(e.toString(), 'Token expired');
    });
  });
}
