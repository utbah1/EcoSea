import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// AssetBundle palsu agar widget test tidak gagal hanya karena asset (image/icon)
/// tidak tersedia di environment test.
///
/// Kenapa perlu ekstra hati-hati?
/// - Flutter memuat AssetManifest.bin via `loadStructuredBinaryData`.
/// - AssetManifest.bin harus berupa bytes hasil `StandardMessageCodec.encodeMessage`.
///   Kalau tidak valid akan muncul error `FormatException: Message corrupted`.
class FakeAssetBundle extends CachingAssetBundle {
  static final Uint8List _transparentPng = base64Decode(
    // PNG 1x1 transparan.
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/w8AAusB9Yk2cZ0AAAAASUVORK5CYII=',
  );

  static final ByteData _emptyAssetManifestBin = () {
    // encodeMessage mengembalikan ByteData dengan buffer yang kadang lebih besar
    // dari lengthInBytes. Ambil slice yang tepat + copy supaya tidak ada trailing bytes.
    final bd = const StandardMessageCodec().encodeMessage(<String, dynamic>{})!;
    final u8 = bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
    final copied = Uint8List.fromList(u8);
    return ByteData.view(copied.buffer);
  }();

  bool _isAssetManifestBin(String key) =>
      key == 'AssetManifest.bin' || key.endsWith('/AssetManifest.bin');

  bool _isAssetManifestJson(String key) =>
      key == 'AssetManifest.json' || key.endsWith('/AssetManifest.json');

  bool _isFontManifestJson(String key) =>
      key == 'FontManifest.json' || key.endsWith('/FontManifest.json');

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    final ByteData data = _isAssetManifestBin(key)
        ? _emptyAssetManifestBin
        : await load(key);

    final result = parser(data);
    if (result is Future<T>) return await result;
    return result;
  }

  @override
  Future<ByteData> load(String key) async {
    // Manifest files (harus valid format)
    if (_isAssetManifestBin(key)) return _emptyAssetManifestBin;

    if (_isAssetManifestJson(key)) {
      final bytes = Uint8List.fromList(utf8.encode('{}'));
      return ByteData.view(bytes.buffer);
    }

    if (_isFontManifestJson(key)) {
      final bytes = Uint8List.fromList(utf8.encode('[]'));
      return ByteData.view(bytes.buffer);
    }

    // Untuk semua asset binary lain (umumnya image), kembalikan PNG transparan 1x1.
    final bytes = Uint8List.fromList(_transparentPng);
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_isAssetManifestJson(key)) return '{}';
    if (_isFontManifestJson(key)) return '[]';

    // Jika project memakai SVG (mis. flutter_svg), minimal svg valid.
    if (key.toLowerCase().endsWith('.svg')) {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"></svg>';
    }

    return '';
  }
}

/// Mengatur ukuran "layar" di widget test agar layout tidak overflow karena
/// default test surface sempit.
void setTestSurfaceSize(
  WidgetTester tester, {
  Size size = const Size(800, 1200),
}) {
  final binding = tester.binding;
  binding.window.physicalSizeTestValue = size;
  binding.window.devicePixelRatioTestValue = 1.0;
}

/// Harus dipanggil di tearDown agar tidak bocor ke test lain.
void clearTestSurfaceSize(WidgetTester tester) {
  final binding = tester.binding;
  binding.window.clearPhysicalSizeTestValue();
  binding.window.clearDevicePixelRatioTestValue();
}

/// Membungkus widget dengan MaterialApp + DefaultAssetBundle (FakeAssetBundle)
/// supaya navigator, theme, dan asset berjalan aman untuk test.
Widget buildTestableWidget(Widget child) {
  return DefaultAssetBundle(
    bundle: FakeAssetBundle(),
    child: MaterialApp(home: child),
  );
}
