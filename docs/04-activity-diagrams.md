# 04 — Activity Diagram

## AD-01 Couple Setup (UC-01..05)
```mermaid
flowchart TD
    A([Mulai]) --> B{Sudah login?}
    B -- Belum --> C[Register atau Login]
    C --> D{Berhasil?}
    D -- Tidak --> C
    D -- Ya --> E
    B -- Ya --> E{Profil punya coupleId?}
    E -- Ya --> H([HOME])
    E -- Tidak --> F[Layar Couple Setup]
    F --> G{Pilih}
    G -- Create --> G1[Buat dokumen couple + invite code 6 karakter]
    G1 --> G2[Simpan coupleId di profil]
    G2 --> G3[Tampilkan kode untuk dibagikan]
    G3 --> H
    G -- Join --> J1[Input kode]
    J1 --> J2{Kode ditemukan?}
    J2 -- Tidak --> J1
    J2 -- Ya --> J3{memberB masih kosong?}
    J3 -- Tidak, penuh --> J1
    J3 -- Ya --> J4[Isi memberB dan simpan coupleId di profil]
    J4 --> H
```
Catatan: setelah Create, user A langsung masuk Home; Home menampilkan "menunggu pasangan". Kode undangan tetap bisa dilihat di Settings.

## AD-02 Create/Replace Moment (UC-07)
```mermaid
flowchart TD
    A([Tekan tombol Moment di Home]) --> B{Sumber foto}
    B -- Kamera --> C{Izin kamera diberikan?}
    C -- Tidak --> D[Arahkan ke Galeri]
    C -- Ya --> E[Ambil foto]
    B -- Galeri --> F[Pilih foto]
    D --> F
    E --> G[Preview]
    F --> G
    G --> H[Isi caption bebas]
    H --> I{Tekan Post?}
    I -- Batal --> Z([Kembali ke Home])
    I -- Post --> J[Resize sisi terpanjang 720 px + kompres JPEG]
    J --> K{Hasil kurang dari 400 KB?}
    K -- Tidak --> L[Turunkan kualitas, ulangi]
    L --> K
    K -- Ya --> M[Encode Base64]
    M --> N[Tulis ke moments/uid dalam satu operasi set, menimpa dokumen lama]
    N --> O{Berhasil?}
    O -- Gagal --> P[Tampilkan error, moment lama tetap utuh]
    P --> G
    O -- Ya --> Q[Moment baru aktif, foto lama tertimpa]
    Q --> Z
```

## AD-03 Countdown (UC-10)
```mermaid
flowchart TD
    A([Home dibuka]) --> B[Ambil semua importantDates]
    B --> C{Ada data?}
    C -- Tidak --> D[Empty state: tambah tanggal penting]
    C -- Ya --> E[Untuk tiap tanggal, hitung tanggal kejadian berikutnya]
    E --> F{recurring?}
    F -- Ya --> G{Bulan-hari tahun ini sudah lewat?}
    G -- Ya --> H[Pakai tahun depan]
    G -- Tidak --> I[Pakai tahun ini]
    F -- Tidak --> J{Tanggal sudah lewat?}
    J -- Ya --> K[Abaikan]
    J -- Tidak --> L[Pakai tanggal aslinya]
    H --> M[Pilih yang paling dekat]
    I --> M
    L --> M
    K --> M
    M --> N[Selisih hari dari hari ini]
    N --> O([Tampilkan judul, jumlah hari, tanggal])
```
Edge case wajib diuji: hari ini = tanggal event → "0 hari / Hari ini"; 29 Februari recurring → 28 Februari di tahun non-kabisat.
