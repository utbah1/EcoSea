import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../config/api.dart';
import '../widgets/bottom_navbar.dart';
import '../services/user_service.dart';
import '../services/review_service.dart';
import '../services/auth_expired_exception.dart';
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
  int _photoBuster = DateTime.now().millisecondsSinceEpoch;

  void _openUlasanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const _UlasanBottomSheet(),
    );
  }

  @override
  void initState() {
    super.initState();
    _futureProfile = UserService.getMe();
  }

  void _refreshProfile() {
    setState(() {
      _futureProfile = UserService.getMe();
      // Biar NetworkImage selalu ambil versi terbaru (hindari cache lama setelah ganti foto)
      _photoBuster = DateTime.now().millisecondsSinceEpoch;
    });
  }

  Future<void> _pullToRefresh() async {
    _refreshProfile();
    try {
      await _futureProfile;
    } catch (_) {
      // biarkan UI FutureBuilder yang handle error
    }
  }

  Future<void> _editName(UserProfile profile) async {
    final ctrl = TextEditingController(text: profile.name);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Nama"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: "Masukkan nama baru"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text("Simpan")),
        ],
      ),
    );

    final newName = (result ?? "").trim();
    if (newName.isEmpty || newName == profile.name) return;

    try {
      await UserService.updateName(name: newName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          content: const Text("Nama berhasil diperbarui"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _refreshProfile();
    } catch (e) {
      if (!mounted) return;
      _handleAuthOrShowError(e);
    }
  }

  Future<void> _changePassword() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + bottomInset),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Ganti Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: oldCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password lama"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password baru (min 6 karakter)"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Konfirmasi password baru"),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    if (newCtrl.text != confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                          content: const Text("Konfirmasi password tidak sama"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Simpan"),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );

    if (ok != true) return;

    try {
      await UserService.changePassword(oldPassword: oldCtrl.text, newPassword: newCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          content: const Text("Password berhasil diganti"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _handleAuthOrShowError(e);
    }
  }

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Ambil dari Galeri"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Ambil dari Kamera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    try {
      await UserService.uploadProfilePhoto(file: File(picked.path));
      if (!mounted) return;

      // pastikan foto yang ditampilkan bukan cache lama
      imageCache.clear();
      imageCache.clearLiveImages();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          content: const Text("Foto profil berhasil diperbarui"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _refreshProfile();
    } catch (e) {
      if (!mounted) return;
      _handleAuthOrShowError(e);
    }
  }

  void _handleAuthOrShowError(Object e) {
    final msg = e.toString();
    final lower = msg.toLowerCase();
    final isAuth = e is AuthExpiredException ||
        lower.contains("sesi") ||
        lower.contains("login") ||
        lower.contains("token") ||
        lower.contains("unauthorized") ||
        lower.contains("forbidden");

    if (isAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("token");

        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text("Gagal: $e"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final err = snapshot.error;
            final msg = err?.toString() ?? "";
            final lower = msg.toLowerCase();
            final isAuth = err is AuthExpiredException ||
                lower.contains("sesi") ||
                lower.contains("login") ||
                lower.contains("token") ||
                lower.contains("unauthorized") ||
                lower.contains("forbidden");

            if (isAuth) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("token");

                if (!context.mounted) return;
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
                child: Text(
                  "Gagal memuat profil.\n$msg",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _pullToRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    CircleAvatar(
                      radius: 34,
                      backgroundImage: (profile.photoUrl.isNotEmpty)
                          ? NetworkImage("${ApiConfig.baseUrl}${profile.photoUrl}?v=$_photoBuster")
                          : const AssetImage('assets/logo.png') as ImageProvider,
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
                icon: Icons.edit,
                title: "Edit Nama",
                onTap: () => _editName(profile),
              ),

              _actionTile(
                icon: Icons.lock,
                title: "Ganti Password",
                onTap: _changePassword,
              ),

              _actionTile(
                icon: Icons.photo_camera,
                title: "Ubah Foto Profil",
                onTap: _changePhoto,
              ),

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

              _actionTile(
                icon: Icons.rate_review,
                title: "Beri Ulasan & Saran",
                onTap: _openUlasanSheet,
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
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 2),
    );
  }
}

class _UlasanBottomSheet extends StatefulWidget {
  const _UlasanBottomSheet();

  @override
  State<_UlasanBottomSheet> createState() => _UlasanBottomSheetState();
}

class _UlasanBottomSheetState extends State<_UlasanBottomSheet> {
  int _rating = 5;
  final _kritikCtrl = TextEditingController();
  final _saranCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _kritikCtrl.dispose();
    _saranCtrl.dispose();
    super.dispose();
  }

  Widget _stars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isActive = starIndex <= _rating;
        return IconButton(
          tooltip: "$starIndex bintang",
          onPressed: () => setState(() => _rating = starIndex),
          icon: Icon(
            isActive ? Icons.star : Icons.star_border,
            color: const Color(0xFFFFB703),
            size: 34,
          ),
        );
      }),
    );
  }

  Future<void> _submit() async {
    final kritik = _kritikCtrl.text.trim();
    final saran = _saranCtrl.text.trim();

    if (kritik.isEmpty && saran.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: const Text("Isi minimal kritik atau saran ya."),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ReviewService.submitReview(rating: _rating, kritik: kritik, saran: saran);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          content: const Text("Terima kasih! Ulasan kamu berhasil dikirim."),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().toLowerCase();
      final isAuth = e is AuthExpiredException ||
          msg.contains("sesi") ||
          msg.contains("login") ||
          msg.contains("token") ||
          msg.contains("unauthorized") ||
          msg.contains("forbidden");

      if (isAuth) {
        // Pakai rootNavigator supaya bisa mengganti seluruh stack (meski sedang di modal bottom sheet)
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove("token");

          if (!context.mounted) return;
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          content: Text("Gagal mengirim ulasan: $e"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Ulasan untuk EcoSea",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Beri rating bintang dan tulis kritik/saran agar aplikasi makin bagus.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            _stars(),
            const SizedBox(height: 10),
            TextField(
              controller: _kritikCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Kritik",
                hintText: "Apa yang kurang/bug/hal yang mengganggu?",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _saranCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Saran",
                hintText: "Fitur apa yang kamu pengen ada?",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      "Kirim Ulasan",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _submitting ? null : () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
          ],
        ),
      ),
    );
  }
}
