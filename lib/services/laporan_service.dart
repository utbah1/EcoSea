import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AuthExpiredException implements Exception {
  final String message;
  AuthExpiredException([
    this.message = 'Sesi login habis atau belum login. Silakan login ulang.',
  ]);

  @override
  String toString() => message;
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

  Future<bool> kirimLaporan({
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


      return res.statusCode == 201;
    } 
      on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        final msg = (e.response?.data is Map)
            ? (e.response?.data['msg'] ?? e.response?.data['message'])
            : null;
        throw AuthExpiredException(msg?.toString() ?? 'Sesi login habis. Silakan login ulang.');
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getLaporanTerbaru({int limit = 5}) async {
    try {
      final token = await _getToken();

      final res = await _dio.get(
        "/api/laporan/terbaru",
        queryParameters: {"limit": limit},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return res.data;
    } catch (e) {
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
      if (e.response?.statusCode == 401) {
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
      if (e.response?.statusCode == 401) {
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
      if (e.response?.statusCode == 401) {
        throw AuthExpiredException();
      }
      return false;
    }
  }
}