# 08 — Checklist Fase 3 (Project Setup)

Dikerjakan setelah Fase 2 berstatus DONE di `PROGRESS.md`.

- [ ] Konfirmasi: versi Android Studio dan OS laptop
- [ ] Buat proyek Android (Empty Activity, Compose), minSdk ditentukan bersama
- [ ] Buat project Firebase **di paket Spark**; jangan upgrade ke Blaze
- [ ] Aktifkan Authentication (Email/Password) dan Firestore (mode production, bukan test)
- [ ] Daftarkan app Android (package name + SHA-1 debug), taruh `google-services.json` di `app/` (JANGAN di-commit)
- [ ] Tambah dependensi sesuai D-13 saja
- [ ] Susun paket sesuai `07-architecture-ui-flow.md`
- [ ] Deploy `firebase/firestore.rules` draf (diuji di Fase 5)
- [ ] Build kosong berhasil di emulator/HP; commit pertama kode
