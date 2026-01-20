import 'package:dio/dio.dart';

import '../config/api.dart';
import '../mod/berita.dart';

class BeritaService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<List<Berita>> getBerita({int? limit}) async {
    final res = await _dio.get('/api/berita');
    final data = res.data;

    if (data is! List) return [];

    final items = data
        .whereType<Map>()
        .map((m) => Berita.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    if (limit != null && limit > 0 && items.length > limit) {
      return items.take(limit).toList();
    }
    return items;
  }
}
