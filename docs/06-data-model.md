# 06 — Data Model

## Struktur Firestore (final)
```text
users/{uid}
    name, email, coupleId, createdAt

invites/{code}
    coupleId

couples/{coupleId}
    memberA, memberB, inviteCode, createdAt
    ├── moments/{uid}
    │       photoBase64, caption, mood?, updatedAt
    ├── importantDates/{dateId}
    │       title, date, recurring, createdAt
    └── reactions/{uid}            (P1)
            emoji, updatedAt
```
- `mood` opsional (P1). `reactions` P1. Field `reminder` ditambah bersama fitur Reminder (D-12).
- `date` disimpan sebagai tanggal saja (mis. string `2026-10-25`), bukan Timestamp (D-07).
- Foto: Base64 JPEG, sisi terpanjang 720 px, target ±250 KB, batas keras 400 KB (D-03).
- Moment/Reaction dipisah dokumen agar perubahan reaksi tidak mengunduh ulang foto.

## Class Diagram — domain
```mermaid
classDiagram
    class User {
        +String uid
        +String name
        +String email
        +String coupleId
        +Timestamp createdAt
    }
    class Couple {
        +String coupleId
        +String memberA
        +String memberB
        +String inviteCode
        +Timestamp createdAt
        +isFull() Boolean
    }
    class Moment {
        +String uid
        +String photoBase64
        +String caption
        +String mood
        +Timestamp updatedAt
    }
    class ImportantDate {
        +String dateId
        +String title
        +LocalDate date
        +Boolean recurring
        +Timestamp createdAt
        +nextOccurrence(today) LocalDate
        +daysUntil(today) Int
    }
    class Reaction {
        +String uid
        +String emoji
        +Timestamp updatedAt
    }
    Couple "1" o-- "1..2" User : members
    Couple "1" *-- "0..2" Moment : moments
    Couple "1" *-- "0..*" ImportantDate : dates
    Couple "1" *-- "0..2" Reaction : P1
    User "1" --> "0..1" Moment : owns
```

## Class Diagram — arsitektur
```mermaid
classDiagram
    class AuthViewModel
    class CoupleViewModel
    class HomeViewModel
    class MomentViewModel
    class DateViewModel
    class AuthRepository {
        +signUp()
        +signIn()
        +signOut()
        +currentUser()
    }
    class CoupleRepository {
        +createCouple()
        +joinCouple()
        +observeCouple()
    }
    class MomentRepository {
        +saveMoment()
        +observeMoments()
    }
    class DateRepository {
        +observeDates()
        +addDate()
        +updateDate()
        +deleteDate()
    }
    class ImageProcessor {
        +compress(uri) String
    }
    AuthViewModel --> AuthRepository
    CoupleViewModel --> CoupleRepository
    HomeViewModel --> MomentRepository
    HomeViewModel --> DateRepository
    MomentViewModel --> MomentRepository
    MomentViewModel --> ImageProcessor
    DateViewModel --> DateRepository
```

## ERD konseptual
```mermaid
erDiagram
    USERS ||--o| COUPLES : "belongs to (coupleId)"
    COUPLES ||--|| INVITES : "has code"
    COUPLES ||--o{ MOMENTS : has
    COUPLES ||--o{ IMPORTANT_DATES : has
    COUPLES ||--o{ REACTIONS : "has (P1)"
    USERS {
        string uid PK
        string name
        string email
        string coupleId FK
        timestamp createdAt
    }
    COUPLES {
        string coupleId PK
        string memberA FK
        string memberB FK
        string inviteCode
        timestamp createdAt
    }
    INVITES {
        string code PK
        string coupleId FK
    }
    MOMENTS {
        string uid PK
        string photoBase64
        string caption
        string mood
        timestamp updatedAt
    }
    IMPORTANT_DATES {
        string dateId PK
        string title
        date date
        boolean recurring
        timestamp createdAt
    }
    REACTIONS {
        string uid PK
        string emoji
        timestamp updatedAt
    }
```

## Matriks akses (dasar Security Rules)
| Path | Read | Write |
|---|---|---|
| `users/{uid}` | pemilik | pemilik |
| `invites/{code}` | `get` user login; `list` ditolak | create saat membuat couple |
| `couples/{cid}` | member (atau `get` bila slot `memberB` masih kosong, untuk Join) | create oleh `memberA`; update hanya untuk mengisi `memberB` |
| `couples/{cid}/moments/{uid}` | member | hanya pemilik uid, dengan batas ukuran |
| `couples/{cid}/importantDates/{id}` | member | member |
| `couples/{cid}/reactions/{uid}` (P1) | member | hanya pemilik uid |

Batasan yang diketahui: aturan "satu user hanya satu couple" tidak bisa ditegakkan penuh oleh Rules
(lintas dokumen); ditegakkan di transaksi client. Untuk dua pengguna, risiko ini diterima.
