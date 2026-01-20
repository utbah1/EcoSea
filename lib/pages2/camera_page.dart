import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'buat_laporan_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (!mounted) return;
    if (photo != null) _goToReport(photo);
  }

  Future<void> _pickFromGallery() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (!mounted) return;
    if (photo != null) _goToReport(photo);
  }

  void _goToReport(XFile imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BuatPelaporanPage(foto: imageFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B4D8),
      appBar: AppBar(
        title: const Text("Ambil Foto Laporan"),
        backgroundColor: const Color(0xFF00B4D8),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 64,
                color: Color(0xff0077B6),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Laporkan Kondisi Pantai",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Ambil foto atau pilih dari galeri",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const Spacer(),

            Row(
              children: [
                _ActionButton(
                  icon: Icons.photo_camera,
                  label: "Kamera",
                  onTap: _takePhoto,
                ),
                const SizedBox(width: 14),
                _ActionButton(
                  icon: Icons.photo_library,
                  label: "Galeri",
                  onTap: _pickFromGallery,
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// ACTION BUTTON
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xff0077B6),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
