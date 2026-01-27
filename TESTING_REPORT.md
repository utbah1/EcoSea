# Laporan Mobile Testing – EcoSea (Flutter)

Target rubrik: **Skor 30**

Dokumen ini merangkum implementasi **Unit Testing**, **Widget Testing**, dan **Integration Testing** untuk aplikasi EcoSea.

> Catatan: Project pada arsip ini berisi source `lib/` dan test. Untuk menjalankan integration test di perangkat/emulator, biasanya dibutuhkan project Flutter lengkap (folder `android/`, `ios/`, dll).

---

## Cara menjalankan test

1) Install dependency:

```bash
flutter pub get
```

2) Jalankan Unit + Widget test:

```bash
flutter test
```

Atau spesifik:

```bash
flutter test test/unit
flutter test test/widget
```

3) Jalankan Integration test:

```bash
flutter test integration_test/app_flow_test.dart
```

---

## Unit Testing

**Tujuan:** menguji fungsi logis aplikasi pada level class/model/service tanpa UI.

### 1) Berita model

File: `test/unit/berita_test.dart`

Testcase yang diuji:

1. `fromJson()` memetakan field dengan benar saat input lengkap.
2. `fromJson()` aman saat field null/kosong (fallback default untuk id/judul/isi, tanggal fallback jika parsing gagal).
3. Getter `excerpt`:
   - merapikan whitespace (`\n` dan spasi ganda)
   - memotong teks > 120 karakter dan menambahkan ellipsis `…`

**Hasil uji yang diharapkan:** seluruh assertion `expect(...)` terpenuhi (PASS). Indikator utama: parsing stabil dan `excerpt` konsisten untuk kebutuhan UI card berita.

### 2) BeachZone warna berdasarkan status

File: `test/unit/beach_zone_test.dart`

Testcase yang diuji:

1. `ZoneStatus.bersih` → `borderColor` hijau, `fillColor` hijau dengan opacity ~0.30
2. `ZoneStatus.perhatian` → oranye
3. `ZoneStatus.kotor` → merah

**Hasil uji yang diharapkan:** PASS untuk seluruh mapping warna sehingga visualisasi zona pada peta konsisten.

### 3) AuthExpiredException

File: `test/unit/auth_expired_exception_test.dart`

Testcase yang diuji:

1. `toString()` mengembalikan pesan default.
2. `toString()` mengembalikan pesan custom.

**Hasil uji yang diharapkan:** PASS.

### 4) LaporanService (token & local storage)

File: `test/unit/laporan_service_test.dart`

Testcase yang diuji:

1. `getLaporanTerbaru()` **melempar** `AuthExpiredException` saat token belum tersimpan di `SharedPreferences`.
2. `getLaporanUser()` **melempar** `AuthExpiredException` saat token ada tetapi kosong/whitespace.

Teknik penting:

- `SharedPreferences.setMockInitialValues({})` dipakai untuk memastikan test tidak mengganggu storage asli.

**Hasil uji yang diharapkan:** PASS. Indikator utama: validasi token bekerja sebelum melakukan API call.

---

## Widget Testing

**Tujuan:** menguji komponen UI (widget) seperti button, input field, validasi form, dan navigasi.

### Catatan teknis (asset pada test)

Widget test sering gagal jika asset image (logo, icon) tidak tersedia di environment test. Karena itu disediakan helper:

- `test/helpers/test_utils.dart` → `FakeAssetBundle` (PNG 1x1 transparan) dan `buildTestableWidget()`

### 1) WelcomePage

File: `test/widget/welcome_page_test.dart`

Testcase yang diuji:

1. Menampilkan teks "Selamat Datang!" dan tombol "Get Started".
2. Tap "Get Started" melakukan navigasi ke `LoginPage`.

**Hasil uji yang diharapkan:** PASS. Indikator utama: event onPressed + Navigator berjalan.

### 2) LoginPage

File: `test/widget/login_page_test.dart`

Testcase yang diuji:

1. Tap "Login" saat field kosong → muncul pesan:
   - "Email tidak boleh kosong"
   - "Password tidak boleh kosong"
2. Input email tidak valid → muncul "Format email tidak valid".
3. Password < 6 karakter → muncul "Password minimal 6 karakter".
4. Password field menggunakan `obscureText` (keamanan input).
5. Tap teks "Don't have an account? Register" → navigasi ke `RegisterPage`.

**Hasil uji yang diharapkan:** PASS. Indikator utama: validator aktif, error text tampil, dan navigasi bekerja.

### 3) RegisterPage

File: `test/widget/register_page_test.dart`

Testcase yang diuji:

1. Tap "Register" saat field kosong → muncul error untuk nama/email/password.
2. Nama < 3 karakter → muncul "Nama minimal 3 karakter".
3. Alur pop (Register → Login): dari `LoginPage` push ke `RegisterPage` lalu tap "Already have an account? Login" kembali ke `LoginPage`.

**Hasil uji yang diharapkan:** PASS.

---

## Integration Testing

**Tujuan:** menguji alur kerja pengguna secara end-to-end, termasuk interaksi antar widget, panggilan API, dan penyimpanan data lokal.

File: `integration_test/app_flow_test.dart`

### Skenario uji

1. **WelcomePage → LoginPage**
   - Tap "Get Started".
2. **Login via API**
   - Isi email + password.
   - Tap "Login".
   - Aplikasi memanggil endpoint **POST** `/api/login`.
3. **Verifikasi Local Storage**
   - Token dan role tersimpan di `SharedPreferences` dengan key `token` dan `role`.
4. **Home → Riwayat**
   - Tap menu "Riwayat".
   - Aplikasi memanggil endpoint **GET** `/api/laporan/user` dengan header Authorization `Bearer token123`.
   - UI menampilkan data laporan dan status "Menunggu".

### Mock backend (HttpServer lokal)

Untuk membuat test deterministik tanpa backend eksternal, integration test menyalakan `HttpServer` lokal di `http://localhost:5000` dan menyediakan respons mock untuk:

- `/api/login`
- `/api/berita` (dibutuhkan saat HomePage build)
- `/api/laporan/user`
- `/uploads/laporan/1.png` (gambar laporan via `Image.network`)

**Hasil uji yang diharapkan:** PASS. Indikator utama:

- Navigasi antar halaman berjalan
- API call sukses (tanpa timeout)
- Data dari API muncul di halaman riwayat
- Token tersimpan di local storage

---

## Ringkasan pemetaan ke rubrik

- **Unit Testing** ✅ mencakup fungsi logis (parsing, mapping status warna, exception, validasi token + SharedPreferences)
- **Widget Testing** ✅ mencakup button, input field, validasi form, dan navigasi antar halaman
- **Integration Testing** ✅ mencakup alur pengguna, API call (mock server), dan local storage (SharedPreferences)