class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '105019584105-gf8h2tamsi2eqmel1ucdjblrqib8s2gs.apps.googleusercontent.com',
  );
}
