import 'package:flutter/material.dart';
import '../config/api.dart';
import '../services/laporan_service.dart';
import '../widgets/laporan_card.dart';
import '../pages/login_page.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final _service = LaporanService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getLaporanUser();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.getLaporanUser();
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
  p = Uri.encodeFull(p);

  return '${_hostUrl()}$p';
}

  String _normalizeStatus(String raw) {
    final s = raw.toLowerCase().trim();
    if (s == 'menunggu' || s == 'pending') return 'Menunggu';
    if (s == 'selesai' || s == 'done' || s == 'completed') return 'Selesai';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B4D8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Riwayat Laporan Saya',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final msg = snapshot.error.toString();
            final isAuth = msg.toLowerCase().contains('login') ||
                msg.toLowerCase().contains('sesi') ||
                msg.toLowerCase().contains('auth');

            if (isAuth) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              });
              return const Center(child: Text("Sesi habis, mengarahkan ke login..."));
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Gagal memuat riwayat.\n$msg", textAlign: TextAlign.center),
              ),
            );
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text("Belum ada laporan yang kamu buat.")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final l = list[index] as Map<String, dynamic>;

                final fotoRaw = (l['foto'] ?? '').toString();
                final fotoUrl = buildFotoUrl(fotoRaw);

                final deskripsi = (l['deskripsi'] ?? '-').toString();
                final tanggal = (l['tanggal'] ?? '-').toString();
                final status = _normalizeStatus((l['status'] ?? '-').toString());

              return LaporanCard(
                imagePath: fotoUrl.isEmpty ? "assets/images/placeholder.jpg" : fotoUrl,
                isNetwork: fotoUrl.isNotEmpty,
                deskripsi: deskripsi,
                tanggal: tanggal,
                status: status,
              );

              },
            ),
          );
        },
      ),
    );
  }
}
