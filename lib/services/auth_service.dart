import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  Future<bool> login(String email, String password) async {
    try {
      final res = await _dio.post(
        "/api/login",
        data: {
          "email": email,
          "password": password,
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", res.data['access_token']);
      await prefs.setString("role", res.data['role']);

      return true;
    } catch (e) {
      return false;
    }
  }

  // REGISTER
  Future<bool> register(String nama, String email, String password) async {
    try {
      await _dio.post(
        "/api/register",
        data: {
          "nama": nama,
          "email": email,
          "password": password,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Login menggunakan Google Sign-In.
  ///
  /// Alur:
  /// 1) Google Sign-In di device
  /// 2) Ambil `idToken`
  /// 3) Kirim ke backend `/api/google-login` untuk diverifikasi
  /// 4) Backend mengembalikan JWT aplikasi (access_token)
  Future<bool> loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: const ["email"]);
      final account = await googleSignIn.signIn();

      // User menutup dialog / cancel
      if (account == null) return false;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) return false;

      final res = await _dio.post(
        "/api/google-login",
        data: {"id_token": idToken},
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", res.data['access_token']);
      await prefs.setString("role", res.data['role']);

      return true;
    } catch (e) {
      return false;
    }
  }
}