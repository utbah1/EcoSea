import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecosea/main.dart';

/// Integration Test EcoSea
///
/// Skenario uji (end-to-end):
/// 1) WelcomePage -> LoginPage
/// 2) Login (API call ke /api/login) -> token tersimpan di SharedPreferences
/// 3) Navigate Home -> Riwayat -> memuat data dari /api/laporan/user
///
/// Catatan:
/// - Test ini menyalakan HttpServer lokal pada http://localhost:5000
///   karena default ApiConfig.baseUrl adalah http://localhost:5000.
/// - Jika port 5000 sedang dipakai, hentikan proses lain yang memakai port tsb.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late HttpServer server;

  // PNG 1x1 (untuk endpoint gambar pada laporan)
  final Uint8List tinyPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/w8AAusB9Yk2cZ0AAAAASUVORK5CYII=',
  );

  Future<void> sendJson(HttpResponse res, Object obj, {int status = 200}) async {
    res.statusCode = status;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(obj));
    await res.close();
  }

  setUpAll(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 5000);
    server.listen((HttpRequest req) async {
      final path = req.uri.path;
      final method = req.method.toUpperCase();

      // ---- AUTH ----
      if (method == 'POST' && path == '/api/login') {
        // Baca body (opsional)
        await utf8.decoder.bind(req).join();
        return sendJson(req.response, {
          'access_token': 'token123',
          'role': 'user',
        });
      }

      // ---- BERITA (dipanggil oleh HomePage) ----
      if (method == 'GET' && path == '/api/berita') {
        return sendJson(req.response, [
          {
            'id': 1,
            'judul': 'Berita Mock',
            'isi': 'Isi berita mock untuk kebutuhan integration test',
            'gambar': '',
            'created_at': '2026-01-27T00:00:00Z',
          }
        ]);
      }

      // ---- RIWAYAT LAPORAN USER ----
      if (method == 'GET' && path == '/api/laporan/user') {
        final auth = req.headers.value(HttpHeaders.authorizationHeader) ?? '';
        if (auth != 'Bearer token123') {
          return sendJson(req.response, {'message': 'unauthorized'}, status: 401);
        }

        return sendJson(req.response, [
          {
            'deskripsi': 'Sampah plastik menumpuk di muara',
            'tanggal': '2026-01-27',
            'status': 'menunggu',
            'foto': '/uploads/laporan/1.png',
          }
        ]);
      }

      // ---- MOCK FILE UPLOADS ----
      if (method == 'GET' && path == '/uploads/laporan/1.png') {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType('image', 'png');
        req.response.add(tinyPng);
        await req.response.close();
        return;
      }

      // fallback
      return sendJson(req.response, {'message': 'not found: $method $path'}, status: 404);
    });

    // Bersihkan SharedPreferences supaya test deterministik.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  tearDownAll(() async {
    await server.close(force: true);
  });

  testWidgets('E2E: login -> token tersimpan -> buka riwayat', (tester) async {
    await tester.pumpWidget(const EcoSeaApp());
    await tester.pumpAndSettle();

    // Welcome -> Login
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Isi form login
    final emailField = find.byType(TextFormField).at(0);
    final passField = find.byType(TextFormField).at(1);
    await tester.enterText(emailField, 'user@email.com');
    await tester.enterText(passField, '123456');

    // Tap Login (akan memanggil API lokal /api/login)
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Setelah login sukses, harus masuk HomePage
    expect(find.text('Berita Terbaru'), findsOneWidget);

    // Verifikasi token tersimpan (local storage)
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), 'token123');
    expect(prefs.getString('role'), 'user');

    // Navigate ke Riwayat (HomeMenuItem label)
    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Data laporan berasal dari endpoint /api/laporan/user
    expect(find.text('Riwayat Laporan Saya'), findsOneWidget);
    expect(find.text('Sampah plastik menumpuk di muara'), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
  });
}
