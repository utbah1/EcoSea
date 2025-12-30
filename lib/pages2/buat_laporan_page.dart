import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class BuatPelaporanPage extends StatefulWidget {
  final File? imageFile;
  final Uint8List? webImage;
  final double latitude;
  final double longitude;

  const BuatPelaporanPage({
    super.key,
    this.imageFile,
    this.webImage,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<BuatPelaporanPage> createState() => _BuatPelaporanPageState();
}

class _BuatPelaporanPageState extends State<BuatPelaporanPage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  String lokasiNama = "Mengambil lokasi...";

  @override
  void initState() {
    super.initState();
    _getNamaLokasi();
  }

  Future<void> _getNamaLokasi() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          lokasiNama =
              "${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      setState(() {
        lokasiNama = "Lokasi tidak diketahui";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreview;

    if (kIsWeb && widget.webImage != null) {
      imagePreview = Image.memory(
        widget.webImage!,
        width: double.infinity,
        height: 230,
        fit: BoxFit.cover,
      );
    } else if (widget.imageFile != null) {
      imagePreview = Image.file(
        widget.imageFile!,
        width: double.infinity,
        height: 230,
        fit: BoxFit.cover,
      );
    } else {
      imagePreview = Container(
        height: 230,
        color: Colors.grey[300],
        child: const Center(child: Text("Tidak ada gambar")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Laporan"),
        backgroundColor: const Color(0xFF00B4D8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imagePreview,
            ),

            const SizedBox(height: 20),

            const Text(
              "Lokasi Otomatis",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 6),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    lokasiNama,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: judulController,
              decoration: const InputDecoration(
                labelText: "Judul Laporan",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: deskripsiController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Deskripsi Laporan",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Backend tetap kirim latitude & longitude
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Laporan berhasil dibuat")),
                  );
                },
                child: const Text("Kirim Laporan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}