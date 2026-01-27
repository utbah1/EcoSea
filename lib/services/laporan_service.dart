import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import 'auth_expired_exception.dart';

class KirimLaporanResult {
  final bool ok;
  final String? message;
  final String? aiLabel;
  /// Confidence dari model. Biasanya 0..1 (akan dikonversi ke persen di UI).
  final double? aiConfidence;

  const KirimLaporanResult({
    required this.ok,
    this.message,
    this.aiLabel,
    this.aiConfidence,
  });
}

class LaporanService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String> _requireToken() async {
    final token = (await _getToken())?.trim();
    if (token == null || token.isEmpty) {
      throw AuthExpiredException();
    }
    return token;
  }

  Future<KirimLaporanResult> kirimLaporan({
    required String judul,
    required String deskripsi,
    required String lokasi,
    required double latitude,
    required double longitude,
    required XFile foto,
  }) async {
    try {
      final token = await _requireToken();

      final MultipartFile fotoPart;
      if (kIsWeb) {
        final bytes = await foto.readAsBytes();
        fotoPart = MultipartFile.fromBytes(bytes, filename: foto.name);
      } else {
        fotoPart = await MultipartFile.fromFile(
          foto.path,
          filename: foto.name,
        );
      }

      final data = FormData.fromMap({
        'judul': judul,
        'deskripsi': deskripsi,
        'lokasi': lokasi,
        'latitude': latitude,
        'longitude': longitude,
        'foto': fotoPart,
      });

      final res = await _dio.post(
        '/api/laporan',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (res.statusCode == 201) {
        final body = res.data;

        String? aiLabel;
        double? aiConfidence;
        String? message;

        if (body is Map) {
          message = body['message']?.toString();
          aiLabel = body['ai_label']?.toString();
          final rawConf = body['ai_confidence'];
          if (rawConf is num) {
            aiConfidence = rawConf.toDouble();
          } else if (rawConf is String) {
            aiConfidence = double.tryParse(rawConf);
          }
        }

        return KirimLaporanResult(
          ok: true,
          message: message,
          aiLabel: aiLabel,
          aiConfidence: aiConfidence,
        );
      }

      return const KirimLaporanResult(
        ok: false,
        message: 'Gagal mengirim laporan. Coba lagi.',
      );
    } 
      on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 422 || status == 404) {
        final msg = (e.response?.data is Map)
            ? (e.response?.data['msg'] ?? e.response?.data['message'])
            : null;
        throw AuthExpiredException(msg?.toString() ?? 'Sesi login habis. Silakan login ulang.');
      }
      final msg = (e.response?.data is Map)
          ? (e.response?.data['message'] ?? e.response?.data['msg'])
          : null;
      return KirimLaporanResult(
        ok: false,
        message: msg?.toString() ?? 'Gagal mengirim laporan. Coba lagi.',
      );
    } catch (e) {
      return KirimLaporanResult(
        ok: false,
        message: e.toString(),
      );
    }
  }

  Future<List<dynamic>> getLaporanTerbaru({int limit = 5}) async {
    try {
      final token = await _requireToken();

      final res = await _dio.get(
        "/api/laporan/terbaru",
        queryParameters: {"limit": limit},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return res.data;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 422 || status == 404) {
        throw const AuthExpiredException();
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getLaporanUser() async {
    try {
      final token = await _requireToken();

      final res = await _dio.get(
        '/api/laporan/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return res.data;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 422 || status == 404) {
        throw AuthExpiredException();
      }
      return [];
    }
  }

  Future<List<dynamic>> getLaporanAdmin() async {
    try {
      final token = await _requireToken();

      final res = await _dio.get(
        '/api/laporan',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return res.data;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 422 || status == 404) {
        throw AuthExpiredException();
      }
      return [];
    }
  }

  Future<bool> tanggapiLaporan({
    required int laporanId,
    required String status,
    required String tanggapan,
  }) async {
    try {
      final token = await _requireToken();

      final res = await _dio.put(
        '/api/laporan/$laporanId/tanggapi',
        data: {
          'status': status,
          'tanggapan': tanggapan,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );


      return res.statusCode == 200;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 422 || status == 404) {
        throw AuthExpiredException();
      }
      return false;
    }
  }
}