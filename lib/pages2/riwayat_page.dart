import 'package:flutter/material.dart';
import '../widgets/laporan_card.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  final List<Map<String, dynamic>> laporanList = const [
    {
      'image': 'assets/Frame.png',
      'tanggal': '10 November 2025',
      'status': 'Menunggu',
      'deskripsi': 'Sampah plastik menumpuk di tepi pantai, perlu segera dibersihkan.',
    },
    {
      'image': 'assets/Frame.png',
      'tanggal': '11 November 2025',
      'status': 'Selesai',
      'deskripsi': 'Bangkai kapal mengganggu pemandangan',
    },
    {
      'image': 'assets/Frame.png',
      'tanggal': '12 November 2025',
      'status': 'Menunggu',
      'deskripsi': 'Pohon tumbang menutupi jalur pesisir barat.',
    },
  ];

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: laporanList.length,
        itemBuilder: (context, index) {
          final laporan = laporanList[index];
          return LaporanCard(
            imagePath: laporan['image'],
            deskripsi: laporan['deskripsi'],
            tanggal: laporan['tanggal'],
            status: laporan['status'],
          );
        },
      ),
    );
  }
}