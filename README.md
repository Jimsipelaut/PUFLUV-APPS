# Puvluf — Private Couple Moment App

Aplikasi Android privat untuk dua orang (saya dan pasangan) yang mengutamakan kedekatan tanpa distraksi media sosial dan beban pesan teks (*chatless*).

- **NOW** — *"Dia sedang apa sekarang?"* → setiap pengguna memiliki **1 active moment** (foto + caption + mood), foto baru otomatis menimpa foto lama tanpa jejak arsip/history.
- **US** — *"Berapa lama lagi menuju momen penting kita?"* → pencatatan tanggal penting (anniversary, ulang tahun, dll.) dengan hitung mundur (*countdown*) otomatis yang cerdas.
- **CONNECTED** — Balasan reaksi cepat (*quick reaction tags*), *live mood*, dan *Interactive Android Home Screen Widget (4×2 full-bleed)*.

---

## 🎯 Batasan Utama & Keputusan Arsitektur
- **Anggaran Rp0 (Spark Plan)**: Beroperasi 100% di atas tier gratis Firebase tanpa menggunakan Firebase Storage dan tanpa kartu kredit/Blaze (Keputusan `D-02`, `D-03`). Foto dikompresi adaptif bertahap menjadi Base64 berkualitas tinggi (< 400 KB) dan disimpan atomik di Firestore.
- **Zero Photo Accumulation**: Foto lama tidak pernah diarsipkan. Sistem selalu menimpa dokumen momen secara atomik (`set` tanpa merge `photoBase64`) untuk memastikan kapasitas Spark Firestore tetap bersih dan hemat kuota (Keputusan `D-04`).
- **Isolasi Data Ketat**: Akses data diproteksi penuh oleh Firebase Security Rules (`firebase/firestore.rules`). Hanya anggota resmi ruangan (`memberA` & `memberB`) yang dapat membaca atau menulis momen dan tanggal penting. Pihak ketiga tidak memiliki akses apapun (Keputusan `D-17`).

---

## 🛠️ Tech Stack & Library
- **Framework**: Flutter (Dart) — Multiplatform & native-speed rendering (Keputusan `D-14`).
- **State Management & Arsitektur**: MVVM sederhana berbantuan `Provider`.
- **Backend & Database**: Firebase Authentication (Email/Password + Reset Password) & Cloud Firestore (asia-southeast2).
- **Home Screen Widget**: `home_widget` (Kotlin `AppWidgetProvider` native RemoteViews 4×2 full-bleed layout dengan downsampling bitmap cerdas bebas OOM/IPC crash).
- **Pemrosesan Gambar**: `image_picker` + `flutter_image_compress` adaptif multi-stage.
- **Desain & Tipografi**: Desain mewah bernuansa gelap (*Luxury Dark Theme*) dengan palet warna `#0E1014`, `#181B22`, `#E6D3C3`, didukung font `DM Sans` dan `Fraunces` via `google_fonts`.

---

## 📱 Fitur-Fitur Utama (Sesuai Desain & Prioritas)

### 1. Autentikasi & Ruang Pasangan (Couple Space)
- Registrasi dan Login akun aman dengan penanganan status sesi persisten.
- Pengiriman email reset kata sandi (*Forgot Password*).
- Pembuatan Couple Space dengan 6 karakter kode unik undangan.
- Bergabung ke ruangan (*Join Couple*) dengan transaksi atomik Firestore untuk mencegah *race condition* dan penguncian maksimal 2 anggota.
- Status menunggu pasangan yang responsif (*realtime waiting state*).

### 2. Momen Aktif & Reaksi (NOW)
- Pengambilan foto lewat kamera atau galeri dengan kompresi adaptif (< 400 KB).
- Pemilihan 6 mood emosional (*Senang, Sayang, Lelah, Kesal, Sedih, Kurang enak badan*).
- Tampilan kartu Hero Partner 370px dengan dual gradient scrim overlay.
- Tag Balasan Cepat (*Quick Reactions*): Pasangan dapat mengirimkan balasan singkat (seperti *Peluk*, *Kangen*, *Semangat*) secara realtime.
- Kelola Tag Reaksi Kustom: Modal bottom sheet interaktif untuk membuat tag reaksi baru hingga 6 tag.

### 3. Tanggal Penting & Hitung Mundur (US)
- CRUD tanggal penting (Anniversary, Ulang Tahun, Hari Jadian).
- Dukungan tanggal berulang tahunan (*recurring*) dengan logika kabisat (29 Feb ke 28 Feb) yang akurat.
- Filter otomatis: hanya menghitung hari yang akan datang (`daysUntil >= 0`).
- Penghapusan tanggal dengan usapan (*swipe-to-delete*) dan dialog konfirmasi.

### 4. Android Home Screen Widget (4×2)
- Tampilan foto partner memenuhi layar widget (*full-bleed*) dengan sudut melengkung 28dp.
- Teks caption, status waktu pengiriman, dan mood pasangan.
- Tampilan nama agenda terdekat dan angka countdown hari penting.
- Pembersihan data otomatis saat pengguna melakukan logout (*Privacy & Data Safety*).

---

## 📂 Struktur Proyek
```text
PUFLUV-APPS/
├── android/                   # Native Android wrapper & AppWidget RemoteViews
│   └── app/src/main/
│       ├── kotlin/com/pufluv/app/PufluvWidgetProvider.kt
│       └── res/layout/pufluv_widget_layout.xml
├── firebase/
│   └── firestore.rules        # Security Rules resmi & teruji ketat
├── lib/
│   ├── data/
│   │   ├── model/             # UserModel, CoupleModel, MomentModel, ImportantDateModel, ReactionModel
│   │   ├── repository/        # AuthRepository, CoupleRepository, MomentRepository, DateRepository, ReactionRepository
│   │   └── utils/             # ImageProcessor, WidgetSyncManager
│   └── ui/
│       ├── auth/              # LoginScreen, RegisterScreen, AuthProvider
│       ├── couple/            # CoupleSetupScreen, JoinCoupleScreen, CoupleProvider
│       ├── dates/             # DateListScreen, DateFormScreen, DateProvider
│       ├── home/              # HomeScreen, HomeProvider, ReactionTagBottomSheet
│       ├── moment/            # MomentEditScreen, MomentProvider
│       └── splash/            # SplashScreen, SplashProvider
├── test/                      # 15 Unit Tests (Model & Date Calculation)
├── docs/                      # Dokumentasi teknis, use-case, ERD, dan keputusan arsitektur
├── PROGRESS.md                # Laporan tahapan pengerjaan fase demi fase
└── README.md                  # Dokumentasi proyek utama
```

---

## 🧪 Pengujian & Verifikasi
Proyek ini dilengkapi dengan 15 unit test yang memvalidasi integritas model, kalkulasi tanggal berulang, tahun kabisat, serta konversi Firestore:
```bash
flutter test
```
Hasil:
```text
00:01 +15: All tests passed!
```

Analisis statis kode:
```bash
flutter analyze
```
Hasil:
```text
No issues found!
```

---

## 🚀 Menjalankan Proyek
1. Pastikan Flutter SDK (versi 3.29+) telah terpasang.
2. Pasang dependensi:
   ```bash
   flutter pub get
   ```
3. Letakkan berkas kredensial `google-services.json` ke dalam direktori `android/app/`.
4. Jalankan aplikasi pada perangkat/emulator:
   ```bash
   flutter run
   ```
5. Untuk kompilasi berkas APK:
   ```bash
   flutter build apk --debug
   ```
   Berkas APK siap pakai akan tersedia di `build/app/outputs/flutter-apk/app-debug.apk`.
