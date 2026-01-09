import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../services/user_service.dart';
import '../pages/login_page.dart';
import 'riwayat_page.dart';

import '../mod/user_profile.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late Future<UserProfile> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = UserService.getMe();
  }

  Widget _infoTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0077B6)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _actionTile({required IconData icon, required String title, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0077B6)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B4D8),
        title: const Text("Profil Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<UserProfile>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Gagal memuat profil.\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundImage: AssetImage('assets/logo.png'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name.isNotEmpty ? profile.name : "Pengguna EcoSea",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0077B6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.email.isNotEmpty ? profile.email : "-",
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "EcoSea • Jaga Pantai Bareng-bareng",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _infoTile(icon: Icons.person, title: "Nama", subtitle: profile.name),
              _infoTile(icon: Icons.email, title: "Email", subtitle: profile.email),

              const SizedBox(height: 6),

              _actionTile(
                icon: Icons.history,
                title: "Riwayat Laporan Saya",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RiwayatPage()),
                  );
                },
              ),

              const SizedBox(height: 6),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove("token");

                    if (!context.mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),
              const Center(
                child: Text(
                  "EcoSea v1.0",
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }
}
