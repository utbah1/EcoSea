import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BuatPelaporanPage extends StatefulWidget {
  final File? imageFile;
  final Uint8List? webImage;

  const BuatPelaporanPage({
    super.key,
    this.imageFile,
    this.webImage,
  });

  @override
  State<BuatPelaporanPage> createState() => _BuatPelaporanPageState();
}

class _BuatPelaporanPageState extends State<BuatPelaporanPage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  String lokasiNama = "Mengambil lokasi...";
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _getLocationAndAddress();
  }

  
  // GET GPS + NAMA LOKASI
  
  Future<void> _getLocationAndAddress() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          lokasiNama = "Izin lokasi ditolak";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //FOTO
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imagePreview,
            ),

            const SizedBox(height: 24),

            // LOKASI
            const Text(
              "Lokasi Otomatis",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lokasiNama,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // JUDUL
            TextField(
              controller: judulController,
              decoration: InputDecoration(
                labelText: "Judul Laporan",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DESKRIPSI
            TextField(
              controller: deskripsiController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Deskripsi Laporan",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // KIRIM 
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final laporanData = {
                    "lokasi": lokasiNama,
                    "latitude": latitude,
                    "longitude": longitude,
                    "judul": judulController.text,
                    "deskripsi": deskripsiController.text,
                  };

                  debugPrint(laporanData.toString());

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Laporan berhasil dikirim"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0077B6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Kirim Laporan",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}