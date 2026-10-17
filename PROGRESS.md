# PROGRESS

Status: `[ ]` TODO · `[~]` IN PROGRESS · `[x]` DONE · `[!]` BLOCKED
Deadline: **25 Oktober 2026**. Terakhir diperbarui: 2026-10-06.

| Fase | Isi | Status |
|---|---|---|
| 1 | Analisis: requirement, scope, BR, use case | [x] DONE |
| 2 | Desain: activity, sequence, class/ERD, arsitektur, UI flow | [x] DONE |
| 3 | Project setup: Android Studio, Firebase (Spark), Git | [x] DONE |
| 4 | Authentication: register, login, logout, session | [x] DONE |
| 5 | Couple: create/join, invite code, Security Rules | [~] Rules & model disesuaikan (C1), join transaksi (H2) |
| 6 | Moment: kamera/galeri, kompres, caption, replace | [~] Kode ada, verifikasi kompres batas keras (M5) |
| 7 | Partner moment realtime (+ P1: mood, reaction) | [~] Kode ada, HomeProvider & UI reaksi direncanakan |
| 8 | Important Dates CRUD + countdown | [~] Tanggal lampau diperbaiki (H1) |
| 9 | (P1) Reminder / notifikasi | [ ] TODO |
| 10 | UI polish minimal (empty/loading/error) | [ ] TODO |
| 11 | Testing dua perangkat | [ ] TODO |
| 12 | Build APK, pasang di dua HP | [ ] TODO |

## Jadwal target
| Tanggal | Target |
|---|---|
| 6–7 Okt | Desain final, setup Android Studio + Firebase |
| 8–9 Okt | Register, Login, Session, Couple, Security Rules |
| 10–13 Okt | Home, Create Moment, Replacement, Partner Moment |
| 14–16 Okt | Important Dates + Countdown |
| 17–19 Okt | Testing dua perangkat, bug fixing |
| 20–23 Okt | P1 secukupnya |
| 24 Okt | APK final di kedua HP |

Jika jadwal meleset: korbankan P1/P2, bukan P0.

## Definition of Done MVP
Lihat `docs/02-mvp-and-priorities.md` bagian 5 (5 skenario dua perangkat).

## Log
- 2026-10-06: Fase 1 selesai. Fase 2 dokumen ditulis. Keputusan Rp0: tanpa Firebase Storage (D-02).
- 2026-10-06: Fase 2 DONE; 3.1 selesai (repo ter-push).
- 2026-10-16: Keputusan D-14 approved (migrasi implementasi ke Flutter). Setup Flutter diinisialisasi: package name `com.pufluv.app`, konfigurasi Firebase plugin & google-services.json, dependensi `firebase_core`, `firebase_auth`, `cloud_firestore`, `provider`, `intl`. Proyek dan status di-push ke GitHub untuk diteruskan via Claude. Fase 3 [~] in progress menuju Fase 4.
- 2026-10-17: Audit repo menyeluruh (09-audit-dan-rencana-perbaikan.md). Eksekusi perbaikan C1 & C2: unifikasi Security Rules ke `firebase/firestore.rules`, hapus rules root yang longgar, ubah `memberB` menjadi `null` pada model & repository untuk menjamin isolasi data user C (DoD 5), update DECISIONS.md (D-16, D-17).
