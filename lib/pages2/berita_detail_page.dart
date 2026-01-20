import 'package:flutter/material.dart';

import '../config/api.dart';
import '../mod/berita.dart';

class BeritaDetailPage extends StatelessWidget {
  final Berita berita;
  const BeritaDetailPage({super.key, required this.berita});

  String _imageUrl() {
    if (berita.gambarPath == null || berita.gambarPath!.isEmpty) return '';
    return '${ApiConfig.baseUrl}${berita.gambarPath}';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    return '${dt.day} $m ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final img = _imageUrl();

    return Scaffold(
      backgroundColor: const Color(0xFF00B4D8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B4D8),
        elevation: 0,
        title: const Text('Berita'),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (img.isNotEmpty)
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Gagal memuat gambar'),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(berita.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        berita.judul,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        berita.isi,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
