import 'dart:convert';
import 'package:http/http.dart' as http;

import '../mod/beach_cleaning_knowledge.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyB3zJ7Us91xrih5XdvBV4-wyUK561kgZYI";
  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey";

  static Future<String> sendMessage(String userMessage) async {
    final body = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "${BeachCleaningKnowledge.systemPrompt}\n\nPertanyaan:\n$userMessage"
            }
          ]
        }
      ]
    };

    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      throw Exception("Gagal mengambil jawaban AI");
    }
  }
}
