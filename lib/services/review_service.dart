import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';

class ReviewService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {"Content-Type": "application/json"},
    ),
  );

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> submitReview({
    required int rating,
    String? kritik,
    String? saran,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    final res = await _dio.post(
      "/api/ulasan",
      data: {
        "rating": rating,
        "kritik": (kritik ?? "").trim(),
        "saran": (saran ?? "").trim(),
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    if (res.statusCode != 201) {
      throw Exception("Gagal mengirim ulasan.");
    }
  }
}
