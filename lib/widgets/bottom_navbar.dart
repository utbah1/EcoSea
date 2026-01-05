import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../pages/home_page.dart';
import '../pages2/profil_page.dart';
import '../pages2/buat_laporan_page.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  Future<void> _takePhoto(BuildContext context) async {
    final picker = ImagePicker();

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
          ),
        ),
      );
    }
  }

  // NAVIGASI TAB

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
    const inactiveColor = Color(0xFF9E9E9E);

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
              color: currentIndex == 0 ? activeColor : inactiveColor,
            ),
          ),

          /// CAMERA 
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0077B6),
            ),
            child: IconButton(
              onPressed: () => _takePhoto(context),
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 28,
              ),
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