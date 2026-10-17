# 08 — Checklist Fase 3 (Project Setup)

Dikerjakan setelah Fase 2 berstatus DONE di `PROGRESS.md`.

- [x] Konfirmasi: migrasi Flutter (D-14), Android package `com.pufluv.app`
- [x] Buat proyek Flutter (Dart), minSdk 21+, targetSdk 34/36
- [x] Buat project Firebase di paket Spark (Rp0, D-02); tanpa Blaze
- [x] Aktifkan Authentication (Email/Password) dan Firestore (production mode)
- [x] Daftarkan app Android (package name `com.pufluv.app` + SHA-1 debug), taruh `google-services.json` di `android/app/` (tidak di-commit ke Git)
- [x] Tambah dependensi resmi & teruji: `firebase_core`, `firebase_auth`, `cloud_firestore`, `provider`, `intl`, `image_picker`, `flutter_image_compress`, `home_widget`, `google_fonts`
- [x] Susun arsitektur layer MVVM (`data/`, `ui/`, `model/`, `repository/`) sesuai `07-architecture-ui-flow.md`
- [x] Deploy & validasi `firebase/firestore.rules` ketat
- [x] Build APK sukses, 15 unit tests passed, commit kode & push ke GitHub remote
