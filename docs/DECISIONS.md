# DECISIONS (Decision Log)

Keputusan terbaru menang. Setiap perubahan requirement/teknis dicatat di sini.
Status: **Approved** (disetujui pemilik) · **Proposed** (menunggu persetujuan).

| ID | Keputusan | Alasan | Status |
|---|---|---|---|
| D-01 | Level prioritas P0–P3 (bagian 27.x master prompt) mengalahkan daftar MUST/SHOULD/COULD lama. Reminder, Mood, Reaction, Profile Photo di luar MVP. | Dokumen asal punya dua "Section 27" yang bertentangan; 27.x lebih baru dan rinci. | Approved |
| D-02 | **Tanpa Firebase Storage.** Foto disimpan sebagai Base64 JPEG terkompres di dokumen Firestore. Tanpa Blaze, tanpa kartu. | Cloud Storage for Firebase mensyaratkan Blaze (billing) sejak 3 Feb 2026; bentrok dengan budget Rp0. | Approved |
| D-03 | Kompresi: sisi terpanjang 720 px, JPEG, target ±250 KB, batas keras hasil 400 KB (Base64 +33% ≈ 530 KB < batas dokumen 1 MiB). | Dokumen Firestore maks 1 MiB. | Approved |
| D-04 | Replace moment = satu operasi `set` yang menimpa `moments/{uid}` (bukan hapus lalu tulis). | Atomik; gagal jaringan tidak menghilangkan moment lama. Memenuhi BR-06 secara struktural. | Approved |
| D-05 | Moment disimpan per uid: `couples/{cid}/moments/{uid}` (bukan `userA`/`userB`). | Rules dan query lebih sederhana. | Approved |
| D-06 | Koleksi `invites/{code} → {coupleId}`; rules: `get` boleh, `list` ditolak. Join memakai transaksi. | User B belum member sehingga tak boleh mencari di `couples`. | Approved |
| D-07 | Tanggal penting disimpan sebagai tanggal saja (tanpa jam/zona waktu). 29 Feb recurring dianggap 28 Feb di tahun non-kabisat. | Hindari bug geser tanggal WIB/UTC. | Approved |
| D-08 | Logika countdown (`nextOccurrence`, `daysUntil`) berada di model `ImportantDate`, dapat diuji unit. Hari-H = "0 hari / Hari ini". | Testabilitas. | Approved |
| D-09 | Tanpa Hilt/DI framework, satu modul Gradle (`app`). Factory manual / ServiceLocator kecil. | Kurangi risiko build di waktu 19 hari. | **Proposed** |
| D-10 | Tanpa bottom navigation; layar Moment Detail dihapus; Profile digabung ke Settings (nama, kode undangan, Logout). | Pemadatan; Home sudah menampilkan moment penuh. | **Proposed** |
| D-11 | Use case "Delete Moment" dikeluarkan dari P0; Create + Replace digabung (UC-07). | Secara teknis satu operasi; delete tidak ada di scope MVP. | Approved |
| D-12 | Field `reminder` pada `importantDates` ditambahkan nanti bersama fitur Reminder (P1). | Hindari field tak terpakai di MVP. | Approved |
| D-13 | Dependensi: Compose + Material3, Navigation Compose, Firebase BoM (Auth, Firestore), Coroutines/Flow. Tanpa Coil, Storage, Analytics. | Minimal dan gratis. | Superseded oleh D-14 |
| D-14 | **Migrasi Framework ke Flutter.** Menggantikan implementasi Android Native (Compose) dari D-13 dengan Flutter (Dart). Arsitektur tetap berpegang pada: UI (Widgets) → State / Notifier (ChangeNotifier / Provider) → Repository → Firebase (FlutterFire: firebase_core, firebase_auth, cloud_firestore). Tetap Rp0 tanpa Firebase Storage, foto terkompres Base64 di Firestore. | Kodebase dan inisiasi proyek disediakan di Flutter oleh pemilik proyek (`puvluf`). | Approved |
| D-15 | **Home Screen Widget (Android AppWidget via `home_widget`).** Menambahkan widget desktop/home screen Android agar pengguna dapat melihat moment partner (foto, caption) dan countdown terdekat langsung dari launcher tanpa membuka aplikasi. Data dikirim dari Flutter ke native widget via SharedPreferences/app group dan di-update saat background fetch atau saat data moment/dates berubah di aplikasi. | Diperlukan oleh pemilik proyek untuk melengkapi konsep NOW di luar aplikasi. Tetap mempertahankan batas Rp0 tanpa cloud storage berbayar. | Approved |
| D-16 | Tag balasan buatan sendiri disimpan di `couples/{cid}.reactionTags`; maks 6 tag, label <= 16 karakter; `reactions/{uid}` menyimpan `tag` (string). | Interaksi privat fleksibel bagi pasangan. Prioritas P1. | Proposed |
| D-17 | Satu sumber Security Rules: `firebase/firestore.rules`. File root dihapus. Inisialisasi slot kedua couple menggunakan `memberB: null` (bukan string kosong ''). | Menjamin penegakan privasi (DoD 5) dan kompatibilitas rules Firestore secara ketat. | Approved |
