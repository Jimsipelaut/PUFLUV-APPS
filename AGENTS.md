# AGENTS.md — Aturan untuk AI / Kolaborator

Berlaku untuk Claude, ChatGPT, Copilot, atau siapa pun yang mengerjakan repo ini.

## Sumber kebenaran (urutan prioritas)
1. `docs/DECISIONS.md` (keputusan terbaru menang)
2. `docs/02-mvp-and-priorities.md` dan `docs/01-requirements.md`
3. Dokumen desain `docs/03`–`docs/07`
4. Percakapan chat (hanya sementara; harus dicatat ke repo agar sah)

Jika ada konflik antar dokumen: **tunjukkan konfliknya, jangan pilih diam-diam.**

## Aturan kerja
- Kerjakan **satu fase pada satu waktu** (lihat `PROGRESS.md`). Jangan melompat.
- Tiap fase: jelaskan → kerjakan → verifikasi → tandai DONE di `PROGRESS.md` → baru lanjut.
- **Jangan coding** sebelum fase desain berstatus DONE.
- Jangan mengubah requirement tanpa persetujuan eksplisit pemilik proyek. Catat perubahan di `docs/DECISIONS.md`.
- Fitur baru: kategorikan dulu P0/P1/P2/P3 memakai aturan di `docs/02-mvp-and-priorities.md`. Tidak otomatis masuk MVP.
- Prioritas saat bentrok: bug MVP > fitur baru; security + konsistensi data > UI cantik; moment replacement yang benar > notifikasi.

## Larangan keras
- **Dilarang** memakai Firebase Storage, paket Blaze, atau layanan berbayar apa pun (D-02).
- **Dilarang** menambah: chat, feed, history/archive foto, comment, follower, public profile, video, iklan (P3).
- **Dilarang** menambah dependensi/library baru tanpa mencatatnya di `docs/DECISIONS.md`.
- **Dilarang** over-engineering: tanpa Hilt, tanpa multi-module, tanpa abstraksi "best practice" yang tidak dibutuhkan dua pengguna.
- Jangan menaruh logika bisnis di Activity/Composable/Widget. Alur: UI → ViewModel/Notifier (ChangeNotifier) → Repository → Firebase (D-14: implementasi memakai Flutter).
- Jangan mengandalkan UI untuk keamanan; semua akses data dijaga Security Rules.
- Jangan mengarang fakta (API, versi library, kuota). Jika tidak yakin, katakan dan verifikasi.

## Aturan kode
- File baru: berikan **kode lengkap** dan sebutkan path-nya. Dilarang potongan tanpa lokasi.
- Sebutkan file yang dibuat/diubah. Jangan merusak fitur yang sudah DONE.
- Konsisten dengan `docs/07-architecture-ui-flow.md` (struktur paket) dan `docs/06-data-model.md` (field Firestore).
- Jangan commit `google-services.json`, `local.properties`, keystore.

## Quality gate sebelum menyatakan fase selesai
Requirement sesuai? Layer benar? User lain tidak bisa baca data privat? Foto lama benar-benar tertimpa?
Flow UX sederhana? Masih Rp0? Ada cara menguji?
