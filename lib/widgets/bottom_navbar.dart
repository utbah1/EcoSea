import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../pages/home_page.dart';
import '../pages2/profil_page.dart';
import '../pages2/buat_laporan_page.dart'; // halaman laporan

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location service tidak aktif';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Izin lokasi ditolak';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak permanen';
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    final picker = ImagePicker();

    Position position = await _getLocation();

    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (photo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuatPelaporanPage(
            imageFile: File(photo.path),
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        ),
      );
    }
  }

  // ===============================
  // NAVIGASI TAB
  // ===============================
  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 2:
        page = const ProfilPage();
        break;
      default:
        page = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF0077B6);
    const inactiveColor = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          /// HOME
          IconButton(
            onPressed: () => _onItemTapped(context, 0),
            icon: Icon(
              Icons.home,
              size: 30,
              color: currentIndex == 0 ? activeColor : const Color(0xFF9E9E9E),
            ),
          ),

          /// CAMERA (LANGSUNG BUKA KAMERA)
          IconButton(
            onPressed: () => _takePhoto(context),
            icon: const Icon(
              Icons.camera_alt_outlined,
              size: 34,
              color: Color(0xFF9E9E9E),
            ),
          ),

          /// PROFIL
          IconButton(
            onPressed: () => _onItemTapped(context, 2),
            icon: Icon(
              Icons.person_outline,
              size: 30,
              color: currentIndex == 2 ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
