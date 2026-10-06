# 02 — MVP dan Prioritas

## 1. Definisi MVP
Versi terkecil yang sudah dapat dipakai dua orang untuk tujuan utama. MVP membuktikan dua konsep:
- **NOW** — saya dapat melihat moment terbaru pasangan.
- **US** — saya dapat melihat dan menghitung waktu menuju tanggal penting.

## 2. Level prioritas (menentukan urutan kerja)
**P0 — Core MVP (tidak boleh dilewati)**
1 Setup Firebase+Android · 2 Register · 3 Login · 4 Session · 5 Create Couple · 6 Join Couple ·
7 Couple security · 8 Home · 9 Select/Take photo · 10 Caption · 11 Upload active moment ·
12 View own moment · 13 View partner moment · 14 Replace moment · 15 Foto lama tertimpa ·
16 Important Dates CRUD · 17 Countdown

**P1 — Enhancement:** Mood, Reaction, Basic Profile, Basic Settings, Empty/Loading/Error state, polish dasar.
**P2 — Optional:** animasi, visual customization, personalisasi ekstra. Tidak boleh mengganggu deadline.
**P3 — Out of scope:** lihat `01-requirements.md`.

Reminder/notification: P1 (di luar MVP).

## 3. Urutan strategi
P0 → MVP stabil → Testing → P1 → Polish → P2.
Jika waktu mepet: STOP P2 → STOP fitur tambahan → selesaikan P0 → testing → bug fixing → release MVP.

## 4. Aturan perubahan scope
Fitur baru: apakah diperlukan agar NOW + US berjalan? Ya → evaluasi sebagai P0. Tidak → P1/P2/P3.
Fitur yang menambah kompleksitas database, biaya, waktu, risiko security, atau risiko deadline
**wajib dievaluasi** dan dicatat di `DECISIONS.md` sebelum dikerjakan.

Saat bentrok: bug MVP > fitur baru · security + konsistensi data > UI cantik ·
moment replacement yang benar > notifikasi.

## 5. Definition of MVP Done (uji di dua perangkat)
1. **Couple Setup:** A register → create couple → dapat kode → B register → join dengan kode → couple terbentuk.
2. **Moment:** A upload foto + caption → moment aktif → B melihatnya.
3. **Replacement:** A upload foto baru → moment lama hilang → data foto lama tidak tersisa di Firestore (cek via Console) → moment baru tampil.
4. **Important Date:** A buat Anniversary → tersimpan → Home menampilkan upcoming date → countdown benar.
5. **Privacy:** A+B bisa akses Couple Space; user C **tidak** bisa membaca moment atau tanggal mereka.

Semua lolos di dua perangkat ⇒ **MVP = DONE**. Mood, Reaction, Notification, Animasi tidak ditunggu.
