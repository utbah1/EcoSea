import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../services/laporan_service.dart';

class BuatPelaporanPage extends StatefulWidget {
  final XFile? foto;

  const BuatPelaporanPage({
    super.key,
    this.foto,
  });

  @override
  State<BuatPelaporanPage> createState() => _BuatPelaporanPageState();
}

class _BuatPelaporanPageState extends State<BuatPelaporanPage> {
  final _laporanService = LaporanService();

  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  String lokasiNama = "Mengambil lokasi...";
  double? latitude;
  double? longitude;

  Uint8List? _imageBytes;
  bool _isLoadingImage = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
    _getLocationAndAddress();
  }

  @override
  void dispose() {
    judulController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _loadImageBytes() async {
    if (widget.foto == null) return;
    setState(() => _isLoadingImage = true);
    try {
      final bytes = await widget.foto!.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (_) {

    } finally {
      if (mounted) setState(() => _isLoadingImage = false);
    }
  }

  Future<void> _getLocationAndAddress() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          lokasiNama = "Layanan lokasi nonaktif";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          lokasiNama = "Izin lokasi ditolak";
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          lokasiNama = "Izin lokasi ditolak permanen";
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      final placemarks = await placemarkFromCoordinates(latitude!, longitude!);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final parts = <String?>[
          place.name,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.trim().isNotEmpty).map((e) => e!.trim());

        setState(() {
          lokasiNama = parts.isEmpty ? "Lokasi tidak diketahui" : parts.join(", ");
        });
      } else {
        setState(() {
          lokasiNama = "Lokasi tidak diketahui";
        });
      }
    } catch (_) {
      setState(() {
        lokasiNama = "Lokasi tidak diketahui";
      });
    }
  }

  Future<void> _kirim() async {
    if (_isSending) return;

    final judul = judulController.text.trim();
    final deskripsi = deskripsiController.text.trim();

    if (widget.foto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto laporan belum ada")),
      );
      return;
    }
    if (judul.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul laporan wajib diisi")),
      );
      return;
    }
    if (deskripsi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deskripsi laporan wajib diisi")),
      );
      return;
    }
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi belum didapat. Coba lagi.")),
      );
      await _getLocationAndAddress();
      return;
    }

    setState(() => _isSending = true);

    bool ok = false;
    try {
      ok = await _laporanService.kirimLaporan(
        judul: judul,
        deskripsi: deskripsi,
        lokasi: lokasiNama,
        latitude: latitude!,
        longitude: longitude!,
        foto: widget.foto!,
      );
    } on AuthExpiredException catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }

    if (!mounted) return;

    setState(() => _isSending = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          content: const Text("Terima kasih! Laporan kamu berhasil dikirim."),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengirim laporan. Coba lagi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreview;
    if (_isLoadingImage) {
      imagePreview = Container(
        height: 230,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (_imageBytes != null) {
      imagePreview = Image.memory(
        _imageBytes!,
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
        actions: [
          IconButton(
            tooltip: "Refresh lokasi",
            onPressed: _getLocationAndAddress,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO
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
                onPressed: _isSending ? null : _kirim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0077B6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSending) ...[
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      _isSending ? "Mengirim..." : "Kirim Laporan",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (kIsWeb) ...[
              const SizedBox(height: 12),
              const Text(
                "Catatan: Pastikan permission lokasi & upload sudah diaktifkan di browser.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
