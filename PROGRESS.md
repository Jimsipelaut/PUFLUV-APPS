# PROGRESS

Status: `[ ]` TODO · `[~]` IN PROGRESS · `[x]` DONE · `[!]` BLOCKED
Deadline: **25 Oktober 2026**. Terakhir diperbarui: 2026-10-06.

| Fase | Isi | Status |
|---|---|---|
| 1 | Analisis: requirement, scope, BR, use case | [x] DONE |
| 2 | Desain: activity, sequence, class/ERD, arsitektur, UI flow | [x] DONE |
| 3 | Project setup: Android Studio, Firebase (Spark), Git | [x] DONE |
| 4 | Authentication: register, login, logout, session | [x] DONE (termasuk reset password via email M1) |
| 5 | Couple: create/join, invite code, Security Rules | [x] DONE (transaksi atomik H2, rules ketat D-17/C1, status tunggu M3/M4) |
| 6 | Moment: kamera/galeri, kompres, caption, replace | [x] DONE (kompresi bertahap adaptif M5, D-04 timpa bersih, preview M7) |
| 7 | Partner moment realtime (+ P1: mood, reaction) | [x] DONE (HomeProvider stream cache H4, mood picker terintegrasi, widget sync H5/H6) |
| 8 | Important Dates CRUD + countdown | [x] DONE (leap year & masa depan H1, swipe-to-delete M10, 15 unit test passed) |
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
- 2026-10-17: Eksekusi rangkaian audit H1–H6 & M1–M10: implementasi transaksi atomik room (H2), filter hari negatif countdown & leap-year (H1), arsitektur HomeProvider dengan cache gambar memori bebas flicker (H4), single sync widget dan pembersihan data saat logout (H5, H6), penanganan error jaringan splash retry (H3), kompresi adaptif multi-tahap (M5), indikator loading kompresi (M7), mood picker 6 opsi di form moment, swipe-to-delete tanggal dengan konfirmasi (M10), dan fitur Lupa Password via email (M1). Seluruh 15 unit tests lulus. Fase 4-8 dinyatakan DONE.
