class AuthExpiredException implements Exception {
  final String message;
  const AuthExpiredException([
    this.message = 'Sesi login habis atau belum login. Silakan login ulang.',
  ]);

  @override
  String toString() => message;
}