import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages2/buat_laporan_page.dart';
import '../pages2/profil_page.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const BuatLaporanPage();
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
          IconButton(
            onPressed: () => _onItemTapped(context, 0),
            icon: Icon(
              Icons.home,
              size: 30,
              color: currentIndex == 0 ? activeColor : inactiveColor,
            ),
          ),
          IconButton(
            onPressed: () => _onItemTapped(context, 1),
            icon: Icon(
              Icons.camera_alt_outlined,
              size: 30,
              color: currentIndex == 1 ? activeColor : inactiveColor,
            ),
          ),
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