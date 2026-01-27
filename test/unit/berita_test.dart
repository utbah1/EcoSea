import 'package:flutter_test/flutter_test.dart';

import 'package:ecosea/mod/berita.dart';

void main() {
  group('Unit Test - Berita model', () {
    test('fromJson() memetakan field dengan benar (data lengkap)', () {
      final berita = Berita.fromJson({
        'id': 7,
        'judul': 'Pantai Bersih',
        'isi': 'Konten berita',
        'gambar': '/uploads/berita/7.png',
        'created_at': '2026-01-20T12:00:00Z',
      });

      expect(berita.id, 7);
      expect(berita.judul, 'Pantai Bersih');
      expect(berita.isi, 'Konten berita');
      expect(berita.gambarPath, '/uploads/berita/7.png');
      expect(berita.createdAt.year, 2026);
    });

    test('fromJson() aman untuk field null/kosong (fallback default)', () {
      final berita = Berita.fromJson({
        'judul': null,
        'isi': null,
        'created_at': 'bukan_tanggal',
      });

      expect(berita.id, 0);
      expect(berita.judul, '');
      expect(berita.isi, '');
      expect(berita.gambarPath, isNull);
      // createdAt fallback ke DateTime.now() jika parsing gagal.
      expect(berita.createdAt, isA<DateTime>());
    });

    test('excerpt merapikan whitespace dan memotong >120 karakter', () {
      const seed = 'Ini    teks    panjang\n\n'
          'yang   memiliki   banyak spasi. ';
      final longText = List.filled(10, seed).join();

      final berita = Berita(
        id: 1,
        judul: 'J',
        isi: longText,
        gambarPath: null,
        createdAt: DateTime(2026, 1, 1),
      );

      final ex = berita.excerpt;
      expect(ex.length, lessThanOrEqualTo(121));
      expect(ex.endsWith('…'), isTrue);
      expect(ex.contains('\n'), isFalse);
      expect(ex.contains('  '), isFalse);
    });
  });
}
