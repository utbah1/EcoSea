import 'package:ecosea/pages2/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import '../services/laporan_service.dart';
import '../services/auth_expired_exception.dart';
import '../pages/login_page.dart';
import '../widgets/bottom_navbar.dart';

class PelaporanPage extends StatefulWidget {
  const PelaporanPage({super.key});

  @override
  State<PelaporanPage> createState() => _PelaporanPageState();
}

class _PelaporanPageState extends State<PelaporanPage> {
  final _service = LaporanService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getLaporanTerbaru(limit: 5);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.getLaporanTerbaru(limit: 5);
    });
    await _future;
  }

  String _hostUrl() {
    return ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
  }

  String buildFotoUrl(String raw) {
    var p = raw.trim();
    if (p.isEmpty) return "";

    if (p.startsWith('http://') || p.startsWith('https://')) return p;

    p = p.replaceAll('\\', '/');
    if (!p.startsWith('/')) p = '/$p';
    p = p.replaceAll('/uploads/laporan/uploads/laporan/', '/uploads/laporan/');

    return '${_hostUrl()}${Uri.encodeFull(p)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B4D8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B4D8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pelaporan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Card Buat Laporan
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Icon(Icons.campaign, size: 60, color: Colors.black87),
                  const SizedBox(height: 10),
                  const Text(
                    "Lihat Sampah Di Pantai?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text("Buat Laporan, Yuk!"),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077B6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CameraPage()),
                        );
                      },
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        "Buat Laporan Baru",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Eksplor laporan warga",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (snap.hasError) {
                  final err = snap.error;
                  final msg = err?.toString() ?? "";
                  final lower = msg.toLowerCase();
                  final isAuth = err is AuthExpiredException ||
                      lower.contains("sesi") ||
                      lower.contains("login") ||
                      lower.contains("token") ||
                      lower.contains("unauthorized") ||
                      lower.contains("forbidden");

                  if (isAuth) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove("token");

                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    });
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("Sesi habis, mengarahkan ke login..."),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Gagal memuat laporan terbaru.\n$msg"),
                  );
                }

                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text("Belum ada laporan terkini")),
                  );
                }

                return Column(
                  children: list.map((item) {
                    final l = item as Map<String, dynamic>;
                    final fotoUrl = buildFotoUrl((l['foto'] ?? '').toString());

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (fotoUrl.isEmpty)
                              ? Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                )
                              : Image.network(
                                  fotoUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.grey[300],
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                        ),
                        title: Text(
                          (l['judul'] ?? 'Laporan').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "${(l['nama'] ?? '').toString()} • ${(l['tanggal'] ?? '').toString()}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          (l['status'] ?? '').toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    );
  }
}
