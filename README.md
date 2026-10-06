# OurSpace — Private Couple Moment App

Aplikasi Android privat untuk dua orang (saya dan pasangan). Bukan media sosial, bukan chat.

- **NOW** — "Dia sedang apa sekarang?" → setiap user punya 1 *active moment* (foto + caption bebas).
- **US** — "Berapa lama lagi menuju momen penting kita?" → tanggal penting + countdown otomatis.

**Deadline: 25 Oktober 2026 (anniversary).** Anggaran: **Rp0** (tanpa Blaze, tanpa kartu).

## Stack
Kotlin · Jetpack Compose · MVVM sederhana · Firebase Auth + Firestore (tanpa Firebase Storage).

## Cara membaca repo ini (urutan)
1. `AGENTS.md` — aturan kerja untuk AI/kolaborator (wajib dibaca sebelum menyentuh apa pun)
2. `PROGRESS.md` — status fase saat ini
3. `docs/DECISIONS.md` — keputusan teknis & alasannya
4. `docs/01-requirements.md` → `docs/07-architecture-ui-flow.md` — desain
5. `docs/02-mvp-and-priorities.md` — definisi MVP & Definition of Done
6. `firebase/firestore.rules` — draf Security Rules

## Prinsip
Satu fase pada satu waktu. Tidak ada kode sebelum desain disetujui. Fitur baru harus lolos
aturan perubahan scope di `docs/02-mvp-and-priorities.md`. Bug MVP > fitur baru.
