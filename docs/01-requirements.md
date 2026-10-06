# 01 — Requirements

## Problem Statement
Pasangan yang berjauhan atau sibuk tidak punya ruang privat yang ringan untuk melihat
"dia sedang apa sekarang" dan menghitung mundur momen penting, tanpa beban chat atau media sosial.

## Objectives
1. Dua orang saling melihat 1 moment aktif terbaru.
2. Moment lama tidak menumpuk (tanpa history).
3. Countdown tanggal penting otomatis.
4. Data privat, biaya Rp0, stabil sebelum 25 Okt 2026.

## Scope
- **P0 (in MVP):** Auth, Couple create/join, Home, Active Moment + replacement, Important Dates CRUD, Countdown, Security Rules.
- **P1:** Mood, Reaction, Profile dasar, Settings, empty/loading/error state.
- **P2:** animasi, personalisasi.
- **P3 (out of scope):** chat, DM, feed, followers, explore, search user, group, public profile, marketplace, iklan, video, photo/story archive, comment/reply, fitur sosial lain.

## Aktor
- **User** — pengguna terautentikasi; dua User dalam satu Couple Space saling menjadi **Partner**.
- **Firebase** — sistem eksternal (Auth, Firestore, Security Rules).

## Functional Requirements (P0)
| ID | Requirement |
|---|---|
| FR-01 | Register, login, logout; sesi login tersimpan |
| FR-02 | Buat Couple Space dan dapatkan kode undangan |
| FR-03 | Join dengan kode; ditolak jika couple penuh (2 member) atau user sudah punya couple |
| FR-04 | Home menampilkan moment sendiri, moment partner, upcoming date + countdown |
| FR-05 | Ambil foto/pilih galeri, preview, caption bebas, Post |
| FR-06 | Foto di-resize dan dikompres sebelum disimpan (lihat D-03) |
| FR-07 | Post baru menggantikan moment lama; foto lama tidak tersisa |
| FR-08 | CRUD Important Date: title, date, recurring |
| FR-09 | Countdown otomatis; recurring dihitung ulang ke tahun berikutnya setelah lewat |
| FR-10 | Security Rules membatasi akses hanya untuk member couple |

## Non-Functional Requirements
| ID | Requirement |
|---|---|
| NFR-01 | Biaya Rp0, tanpa Blaze/kartu |
| NFR-02 | Keamanan ditegakkan di Security Rules, bukan UI |
| NFR-03 | Moment partner muncul realtime (snapshot listener), tanpa refresh manual |
| NFR-04 | Foto ≤ ±250 KB (batas keras 400 KB) |
| NFR-05 | Arsitektur Compose → ViewModel → Repository → Firebase |
| NFR-06 | Android saja, dua perangkat |

## Business Rules
| ID | Rule | Catatan |
|---|---|---|
| BR-01 | Satu user hanya dalam satu Couple Space | |
| BR-02 | Satu Couple Space maksimal dua member | |
| BR-03 | Moment hanya dilihat member Couple Space | |
| BR-04 | Satu user hanya punya satu active moment | |
| BR-05 | Upload baru menggantikan moment sebelumnya | |
| BR-06 | Foto lama tidak boleh tersisa | Terpenuhi lewat penimpaan dokumen (D-02, D-04) |
| BR-07 | Caption bebas | |
| BR-08 | Mood opsional | P1 |
| BR-09 | Moment lama tidak disimpan sebagai history | |
| BR-10 | Reaction hanya dari pasangan | P1 |
| BR-11 | Important Date dimiliki Couple Space | |
| BR-12 | Important Date bisa recurring | |
| BR-13 | Countdown dihitung dari tanggal saat ini | |
| BR-14 | Data couple privat | |
| BR-15 | Tidak ada room chat | |
