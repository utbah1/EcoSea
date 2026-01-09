import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api.dart';
import '../mod/beach_cleaning_knowledge.dart';

class GeminiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<String> sendMessage(
    String userMessage, {
    List<Map<String, String>> history = const [],
  }) async {
    final token = await _getToken();

    final res = await _dio.post(
      "/api/chat",
      data: {
        "message": userMessage,
        "system_prompt": BeachCleaningKnowledge.systemPrompt,
        "history": history,
      },
      options: Options(
        headers: {
          if (token != null) "Authorization": "Bearer $token",
        },
      ),
    );

    if (res.statusCode == 200 && res.data != null) {
      final reply = res.data["reply"];
      return (reply ?? "").toString();
    }

    throw Exception("Gagal mengambil jawaban AI");
  }
}