class UserProfile {
  final int id;
  final String name;
  final String email;

  /// Relative path from backend, e.g. "/uploads/profile/123_1700000000.jpg".
  /// Empty string means no profile photo.
  final String photoUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json["id"] ?? 0) as int,
      name: (json["name"] ?? "") as String,
      email: (json["email"] ?? "") as String,
      photoUrl: (json["photo_url"] ?? "") as String,
    );
  }
}
