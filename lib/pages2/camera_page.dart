import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'buat_laporan_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Izin lokasi ditolak permanen");
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = pos.latitude;
      longitude = pos.longitude;
    });
  }

  Future<void> _takePhoto() async {
    if (latitude == null) await _getLocation();

    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      navigateToReport(File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    if (latitude == null) await _getLocation();

    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.gallery);

    if (photo != null) {
      navigateToReport(File(photo.path));
    }
  }

  void navigateToReport(File imageFile) {
    if (latitude == null || longitude == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuatPelaporanPage(
          imageFile: imageFile,
          latitude: latitude!,
          longitude: longitude!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Center(
            child: Text(
              "Camera Ready",
              style: TextStyle(color: Colors.white54),
            ),
          ),

          Positioned(
            left: 20,
            bottom: 40,
            child: IconButton(
              icon: const Icon(Icons.photo_library,
                  color: Colors.white, size: 35),
              onPressed: _pickFromGallery,
            ),
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}