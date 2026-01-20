class Berita {
  final int id;
  final String judul;
  final String isi;
  final String? gambarPath;
  final DateTime createdAt;

  const Berita({
    required this.id,
    required this.judul,
    required this.isi,
    required this.gambarPath,
    required this.createdAt,
  });

  factory Berita.fromJson(Map<String, dynamic> json) {
    return Berita(
      id: (json['id'] ?? 0) as int,
      judul: (json['judul'] ?? '').toString(),
      isi: (json['isi'] ?? '').toString(),
      gambarPath: json['gambar']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String get excerpt {
    final clean = isi.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= 120) return clean;
    return '${clean.substring(0, 120)}…';
  }
}
