# Dokumentasi API — Deera Server

## 1. Info Umum

| Item | Nilai |
|---|---|
| Base URL | `http://localhost:8080` (ganti lewat env `PORT`) |
| Format data | JSON (`Content-Type: application/json`) |
| Header autentikasi | `Authorization: Bearer <token>` |
| Token | Diperoleh dari `POST /api/login`, berlaku 24 jam |
| Koleksi DB | `users`, `quizzes`, `rooms`, `results`, `tokens` |

Semua endpoint wajib menyertakan header `Authorization` **kecuali** `POST /api/register` dan `POST /api/login`.

---

## 2. Indeks Endpoint

| Metode | Endpoint | Auth | Fungsi |
|---|---|---|---|
| POST | `/api/register` | ✗ | Mendaftarkan akun baru |
| POST | `/api/login` | ✗ | Login dan mendapatkan token |
| POST | `/api/logout` | ✓ | Mengakhiri sesi token |
| GET | `/api/session` | ✓ | Mengecek sesi login masih aktif |
| GET | `/api/my-quizzes` | ✓ | List kuis milik user (dikelompokkan by status room) |
| POST | `/api/create/quiz` | ✓ | Membuat kuis baru |
| GET | `/api/quizzes` | ✓ | List semua kuis (grup: waiting, open, in-Game, ended) |
| POST | `/api/create/room` | ✓ | Membuat room baru |
| PUT | `/api/room/{id}/status` | ✓ | Mengubah status room |
| POST | `/api/room/{kode}/result` | ✓ | Membuat result untuk room |
| GET | `/api/room/{kode}/result` | ✓ | Melihat result berdasarkan kode room |
| PUT | `/api/room/{kode}/result` | ✓ | Update/upsert scoreboard result |
| GET | `/api/results` | ✓ | List semua result |

---

## 3. Auth

### 3.1 POST /api/register

| Metode | Path | Auth |
|---|---|---|
| POST | `/api/register` | ✗ |

**Request body:**

| No | Field | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `nim` | string | ✅ | NIM user |
| 2 | `nama` | string | ✅ | Nama lengkap |
| 3 | `kelas` | string | ✅ | Nama kelas |
| 4 | `password` | string | ✅ | Password |
| 5 | `tanggal_lahir` | string | ✅ | Format `YYYY-MM-DD`, tidak boleh di masa depan |

**Contoh request:**

```http
POST /api/register HTTP/1.1
Host: localhost:8080
Content-Type: application/json

{
  "nim": "124240200",
  "nama": "Budi Santoso",
  "kelas": "Pemrograman Mobile SI-B",
  "password": "rahasia123",
  "tanggal_lahir": "2004-03-10"
}
```

**Response:**

| Status | Deskripsi |
|---|---|
| 201 | Berhasil |
| 400 | Wajib diisi / format salah |
| 400 | Tanggal lahir masa depan |
| 400 | Format tanggal salah |
| 409 | NIM sudah terdaftar |
| 500 | Error server |

**Contoh response — `201 Created`**

```json
{
  "message": "Akun berhasil dibuat",
  "user": {
    "nim": "124240200",
    "nama": "Budi Santoso",
    "kelas": "Pemrograman Mobile SI-B",
    "tanggal_lahir": "2004-03-10"
  }
}
```

**Contoh response — `400 Bad Request`**

```json
// Wajib diisi / format salah
{ "message": "NIM, nama, kelas, password, dan tanggal lahir wajib diisi" }

// Tanggal lahir masa depan
{ "message": "Tanggal lahir tidak boleh di masa depan" }

// Format tanggal salah
{ "message": "Format tanggal lahir harus YYYY-MM-DD" }
```

**Contoh response — `409 Conflict`**

```json
{ "message": "NIM sudah terdaftar" }
```

**Contoh response — `500 Internal Server Error`**

```json
{ "message": "Gagal membuat akun" }
```

### 3.2 POST /api/login

| Metode | Path | Auth |
|---|---|---|
| POST | `/api/login` | ✗ |

**Request body:**

| No | Field | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `nim` | string | ✅ | NIM user |
| 2 | `password` | string | ✅ | Password |

**Contoh request:**

```http
POST /api/login HTTP/1.1
Host: localhost:8080
Content-Type: application/json

{
  "nim": "124240200",
  "password": "rahasia123"
}
```

**Response:**

| Status | Deskripsi |
|---|---|
| 200 | Berhasil, dapat token |
| 400 | Wajib diisi |
| 401 | NIM/password salah |
| 500 | Error server |

**Contoh response — `200 OK`**

```json
{
  "token": "<JWT>",
  "user": {
    "nim": "124240200",
    "nama": "Budi Santoso",
    "kelas": "Pemrograman Mobile SI-B"
  }
}
```

**Contoh response — `400 Bad Request`**

```json
{ "message": "NIM dan password wajib diisi" }
```

**Contoh response — `401 Unauthorized`**

```json
{ "message": "NIM atau password salah" }
```

**Contoh response — `500 Internal Server Error`**

```json
{ "message": "Gagal membuat token" }
```

### 3.3 POST /api/logout

| Metode | Path | Auth |
|---|---|---|
| POST | `/api/logout` | ✓ |

Tidak ada request body.

**Contoh request:**

```http
POST /api/logout HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi |
|---|---|
| 200 | Berhasil logout |
| 401 | Token tidak ditemukan |
| 401 | Token tidak valid |
| 401 | Sesi sudah berakhir |
| 500 | Error server |

**Contoh response — `200 OK`**

```json
{ "message": "Logout berhasil, sesi berakhir" }
```

**Contoh response — `401 Unauthorized`**

```json
// Token tidak ditemukan
{ "message": "Token tidak ditemukan" }

// Token tidak valid
{ "message": "Token tidak valid" }

// Sesi sudah berakhir
{ "message": "Sesi telah berakhir, silakan login kembali" }
```

**Contoh response — `500 Internal Server Error`**

```json
{ "message": "Gagal menghapus sesi" }
```

### 3.4 GET /api/session

| Metode | Path | Auth |
|---|---|---|
| GET | `/api/session` | ✓ |

Tidak ada request parameter maupun body.

**Contoh request:**

```http
GET /api/session HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi |
|---|---|
| 200 | Sesi valid |
| 401 | Sesi tidak valid |

**Contoh response — `200 OK`**

```json
{
  "valid": true,
  "user": {
    "nim": "124240200",
    "nama": "Budi Santoso",
    "kelas": "Pemrograman Mobile SI-B"
  }
}
```

**Contoh response — `401 Unauthorized`**

```json
{ "message": "Sesi tidak valid" }
```

---

## 4. Quiz

### 4.1 GET /api/my-quizzes

| Metode | Path | Auth |
|---|---|---|
| GET | `/api/my-quizzes` | ✓ |

Tidak ada request parameter. Response hanya kuis milik user yang login (identitas diambil otomatis dari token, sehingga tidak bisa dilihat oleh user lain).

Response dikelompokkan ke **4 grup** berdasarkan status room paling terakhir dibuat:
`waiting`, `open`, `in-Game`, dan `ended`. Kuis yang belum punya room sama sekali juga masuk grup `waiting`.
Setiap kuis muncul hanya di **satu** grup; room di dalam kuis diurutkan ascending (kecil → besar) by `created_at`, dan urutan kuis di tiap grup berdasarkan `created_at` kuis (terbaru di atas).

**Contoh request:**

```http
GET /api/my-quizzes HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi |
|---|---|
| 200 | List kuis milik sendiri (dikelompokkan by status room) |
| 401 | Sesi tidak valid |
| 401 | User tidak ditemukan |

**Contoh response — `200 OK`**

```json
{
  "waiting": [
    {
      "id": "<id>",
      "user_id": "<user_id>",
      "title": "Kuis Pemrograman Mobile",
      "description": "Dasar Flutter & Dart",
      "questions": [
        {
          "question": "Bahasa pemrograman utama Flutter?",
          "options": ["Kotlin", "Dart", "Swift", "Java"],
          "duration": 1.5,
          "skor": 20
        }
      ],
      "created_at": "2026-09-17T10:00:00Z",
      "status": "waiting",
      "rooms": [
        {
          "id": "<room_id>",
          "kode": "482913",
          "status": "waiting",
          "created_at": "2026-09-17T10:00:00Z"
        }
      ]
    },
    {
      "id": "<id>",
      "user_id": "<user_id>",
      "title": "Kuis Basis Data MongoDB",
      "description": "Konsep dasar MongoDB",
      "questions": [
        {
          "question": "MongoDB termasuk database jenis apa?",
          "options": ["SQL", "Redis", "NoSQL", "GraphQL"],
          "duration": 2,
          "skor": 20
        }
      ],
      "created_at": "2026-09-16T08:00:00Z",
      "status": "waiting",
      "rooms": []
    }
  ],
  "open": [],
  "in-Game": [],
  "ended": []
}
```

> `status` pada kuis = status room yang paling terakhir dibuat; untuk kuis yang belum punya room sama sekali, `status` di-set ke `waiting` (masuk grup `waiting`). `correct_idx` tidak dikembalikan pada response untuk menjaga jawaban benar tetap rahasia.

**Contoh response — `401 Unauthorized`**

```json
// Sesi tidak valid
{ "message": "Sesi tidak valid" }

// User tidak ditemukan
{ "message": "User tidak ditemukan" }
```

### 4.2 POST /api/create/quiz

| Metode | Path | Auth |
|---|---|---|
| POST | `/api/create/quiz` | ✓ |

**Request body:**

| No | Field | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `title` | string | ✅ | Judul kuis |
| 2 | `description` | string | ✗ | Deskripsi kuis |
| 3 | `questions` | array | ✅ | Minimal 10 soal |
| 4 | `questions[].question` | string | ✅ | Pertanyaan |
| 5 | `questions[].options` | array\[4\] | ✅ | Tepat 4 opsi jawaban |
| 6 | `questions[].correct_idx` | int | ✅ | Index jawaban benar (0–3) |
| 7 | `questions[].duration` | float | ✅ | Salah satu dari: `1.5`, `2`, `3`, `5` detik |
| 8 | `questions[].skor` | int | ✅ | Skor soal, antara 1–50 |

**Contoh request:**

```http
POST /api/create/quiz HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "title": "Kuis Pemrograman Mobile",
  "description": "Dasar Flutter & Dart",
  "questions": [
    {
      "question": "Bahasa pemrograman utama Flutter?",
      "options": ["Kotlin", "Dart", "Swift", "Java"],
      "correct_idx": 1,
      "duration": 1.5,
      "skor": 20
    }
  ]
}
```

> Untuk submit berhasil butuh minimal **10 soal**; contoh di atas hanya ilustrasi 1 soal.

**Response:**

| Status | Deskripsi |
|---|---|
| 201 | Kuis dibuat |
| 400 | Judul kosong |
| 400 | Soal < 10 |
| 400 | Soal ke-n tidak valid |
| 400 | Opsi != 4 |
| 400 | correct_idx salah |
| 400 | Durasi salah |
| 400 | Skor tidak valid |

**Contoh response — `201 Created`**

```json
{
  "message": "Kuis berhasil dibuat",
  "quiz": {
    "id": "<id>",
    "user_id": "<user_id>",
    "title": "Kuis Pemrograman Mobile",
    "description": "Dasar Flutter & Dart",
    "questions": [
      {
        "question": "Bahasa pemrograman utama Flutter?",
        "options": ["Kotlin", "Dart", "Swift", "Java"],
        "duration": 1.5,
        "skor": 20
      }
    ],
    "created_at": "2026-09-17T10:00:00Z"
  }
}
```

**Contoh response — `400 Bad Request`**

```json
// Judul kosong
{ "message": "Judul kuis wajib diisi" }

// Soal < 10
{ "message": "Kuis harus memiliki minimal 10 soal" }

// Soal ke-n tidak valid
{ "message": "Soal ke-1 wajib diisi" }

// Opsi != 4
{ "message": "Soal ke-1 harus memiliki tepat 4 opsi jawaban" }

// correct_idx salah
{ "message": "correct_idx soal ke-1 tidak valid" }

// Durasi salah
{ "message": "durasi soal ke-1 harus salah satu dari: 1.5, 2, 3, atau 5 detik" }

// Skor tidak valid
{ "message": "skor soal ke-1 harus antara 1 sampai 50" }
```

### 4.3 GET /api/quizzes

| Metode | Path | Auth |
|---|---|---|
| GET | `/api/quizzes` | ✓ |

Tidak ada request parameter.

Response dikelompokkan ke **4 grup** berdasarkan status room paling terakhir dibuat:
`waiting`, `open`, `in-Game`, dan `ended`. Kuis yang belum punya room sama sekali juga masuk grup `waiting`.
Setiap kuis muncul hanya di satu grup; room di dalam kuis diurutkan ascending by `created_at`, dan urutan
kuis di tiap grup berdasarkan `created_at` kuis (terbaru di atas).

**Contoh request:**

```http
GET /api/quizzes HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi |
|---|---|
| 200 | Semua kuis (dikelompokkan by status room) |
| 401 | Sesi tidak valid |

**Contoh response — `200 OK`**

```json
{
  "waiting": [
    {
      "id": "<id>",
      "user_id": "<user_id>",
      "title": "Kuis Basis Data MongoDB",
      "description": "Konsep dasar MongoDB",
      "questions": [
        {
          "question": "MongoDB termasuk database jenis apa?",
          "options": ["SQL", "Redis", "NoSQL", "GraphQL"],
          "duration": 2,
          "skor": 30
        }
      ],
      "created_at": "2026-09-16T08:00:00Z",
      "rooms": []
    }
  ],
  "open": [
    {
      "id": "<id>",
      "user_id": "<user_id>",
      "title": "Kuis Pemrograman Mobile",
      "description": "Dasar Flutter & Dart",
      "questions": [
        {
          "question": "Bahasa pemrograman utama Flutter?",
          "options": ["Kotlin", "Dart", "Swift", "Java"],
          "duration": 1.5,
          "skor": 20
        }
      ],
      "created_at": "2026-09-17T10:00:00Z",
      "rooms": [
        {
          "id": "<room_id>",
          "kode": "482913",
          "status": "open",
          "created_at": "2026-09-17T10:30:00Z"
        }
      ]
    }
  ],
  "in-Game": [],
  "ended": []
}
```

> `correct_idx` tidak dikembalikan pada response untuk menjaga jawaban benar tetap rahasia. `status` di level kuis tidak dikembalikan pada endpoint ini (status room terbaru sudah direpresentasikan oleh nama grup).

**Contoh response — `401 Unauthorized`**

```json
{ "message": "Token tidak valid" }
```

---

## 5. Room

### 5.1 POST /api/create/room

| Metode | Path | Auth |
|---|---|---|
| POST | `/api/create/room` | ✓ |

**Request body:**

| No | Field | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `quiz_id` | string (ObjectId) | ✅ | ID kuis yang dimainkan di room |
| 2 | `status` | string | ✗ | `waiting` (default), `open`, `in-Game`, `ended` |

**Contoh request:**

```http
POST /api/create/room HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "quiz_id": "6651a0ab0000000000000000"
}
```

**Response:**

| Status | Deskripsi |
|---|---|
| 201 | Room dibuat |
| 400 | quiz_id kosong |
| 400 | quiz_id tidak valid |
| 400 | status tidak valid |
| 404 | Kuis tidak ada |

**Contoh response — `201 Created`**

```json
{
  "message": "Room berhasil dibuat",
  "room": {
    "id": "<id>",
    "quiz_id": "6651a0ab...",
    "quiz": {
      "id": "6651a0ab...",
      "title": "Kuis Pemrograman Mobile",
      "description": "Dasar Flutter & Dart",
      "total_questions": 10
    },
    "kode": "482913",
    "status": "waiting",
    "created_at": "2026-09-17T10:00:00Z"
  }
}
```

**Contoh response — `400 Bad Request`**

```json
// quiz_id kosong
{ "message": "quiz_id wajib diisi" }

// quiz_id tidak valid
{ "message": "quiz_id tidak valid" }

// status tidak valid
{ "message": "Status room harus salah satu dari: waiting, open, in-Game, ended" }
```

**Contoh response — `404 Not Found`**

```json
{ "message": "Kuis tidak ditemukan" }
```

### 5.2 PUT /api/room/{id}/status

| Metode | Path | Auth |
|---|---|---|
| PUT | `/api/room/{id}/status` | ✓ |

**Path parameter:**

| No | Parameter | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `id` | string (ObjectId) | ✅ | ID room (dipakai jika `room_id` di body kosong) |

**Request body:**

| No | Field | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `room_id` | string (ObjectId) | ✗ | ID room target; lebih diprioritaskan daripada `id` di path |
| 2 | `status` | string | ✅ | `waiting`, `open`, `in-Game`, `ended` |

**Contoh request:**

```http
PUT /api/room/6651a0ab0000000000000001/status HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "room_id": "6651a0ab0000000000000001",
  "status": "in-Game"
}
```

**Response:**

| Status | Deskripsi |
|---|---|
| 200 | Status berubah |
| 400 | ID tidak valid |
| 400 | Status tidak valid |
| 404 | Room tidak ada |

> Jika `room_id` diisi di body, update memakai `room_id` tersebut; jika kosong maka memakai `id` dari path.

**Contoh response — `200 OK`**

```json
{
  "message": "Status room berhasil diubah",
  "room": {
    "id": "<id>",
    "quiz_id": "6651a0ab...",
    "quiz": {
      "id": "6651a0ab...",
      "title": "Kuis Pemrograman Mobile",
      "description": "Dasar Flutter & Dart",
      "total_questions": 10
    },
    "kode": "482913",
    "status": "in-Game",
    "created_at": "2026-09-17T10:00:00Z"
  }
}
```

**Contoh response — `400 Bad Request`**

```json
// ID tidak valid
{ "message": "ID room tidak valid" }

// Status tidak valid
{ "message": "Status room harus salah satu dari: waiting, open, in-Game, ended" }
```

**Contoh response — `404 Not Found`**

```json
{ "message": "Room tidak ditemukan" }
```

---

## 6. Result

> Aturan: **1 kode room unik = maksimal 1 result** (dijamin unique index `results.kode`).

### 6.1 POST /api/room/{kode}/result

| Metode | Path | Auth |
|---|---|---|
| POST | `/api/room/{kode}/result` | ✓ |

**Path parameter:**

| No | Parameter | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `kode` | string (6 digit) | ✅ | Kode unik room, contoh `482913` |

**Request body:**

| No | Field | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `entries` | array | ✗ | Daftar skor peserta (boleh kosong saat dibuat) |
| 2 | `entries[].nama` | string | ✅ | Nama peserta |
| 3 | `entries[].skor` | int | ✗ | Skor peserta |

**Contoh request:**

```http
POST /api/room/482913/result HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "entries": [
    { "nama": "Budi", "skor": 80 },
    { "nama": "Ani", "skor": 70 }
  ]
}
```

**Response:**

| Status | Deskripsi |
|---|---|
| 201 | Result dibuat |
| 400 | Kode kosong |
| 400 | Nama peserta kosong |
| 404 | Room tidak ditemukan |
| 409 | Room sudah punya result |

**Contoh response — `201 Created`**

```json
{
  "message": "Result berhasil dibuat",
  "result": {
    "id": "<id>",
    "room_id": "<room_id>",
    "kode": "482913",
    "quiz_id": "6651a0ab...",
    "entries": [
      { "nama": "Budi", "skor": 80 },
      { "nama": "Ani", "skor": 70 }
    ],
    "created_at": "2026-09-17T10:00:00Z"
  }
}
```

**Contoh response — `400 Bad Request`**

```json
// Kode kosong
{ "message": "Kode room wajib diisi" }

// Nama peserta kosong
{ "message": "nama peserta ke-1 wajib diisi" }
```

**Contoh response — `404 Not Found`**

```json
{ "message": "Room tidak ditemukan" }
```

**Contoh response — `409 Conflict`**

```json
{ "message": "Room sudah memiliki result" }
```

### 6.2 GET /api/room/{kode}/result

| Metode | Path | Auth |
|---|---|---|
| GET | `/api/room/{kode}/result` | ✓ |

**Path parameter:**

| No | Parameter | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `kode` | string (6 digit) | ✅ | Kode unik room |

**Contoh request:**

```http
GET /api/room/482913/result HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi |
|---|---|
| 200 | Result ditemukan |
| 400 | Kode kosong |
| 404 | Result tidak ada |

**Contoh response — `200 OK`**

```json
{
  "result": {
    "id": "<id>",
    "room_id": "<room_id>",
    "kode": "482913",
    "quiz_id": "6651a0ab...",
    "quiz": {
      "id": "6651a0ab...",
      "title": "Kuis Pemrograman Mobile",
      "description": "Dasar Flutter & Dart",
      "total_questions": 10
    },
    "entries": [
      { "nama": "Budi", "skor": 80 },
      { "nama": "Ani", "skor": 70 }
    ],
    "created_at": "2026-09-17T10:00:00Z"
  }
}
```

**Contoh response — `400 Bad Request`**

```json
{ "message": "Kode room wajib diisi" }
```

**Contoh response — `404 Not Found`**

```json
{ "message": "Result tidak ditemukan" }
```

### 6.3 PUT /api/room/{kode}/result

| Metode | Path | Auth |
|---|---|---|
| PUT | `/api/room/{kode}/result` | ✓ |

Upsert: jika result belum ada akan dibuat, jika sudah ada maka `entries` diganti.

**Path parameter:**

| No | Parameter | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `kode` | string (6 digit) | ✅ | Kode unik room |

**Request body:**

| No | Field | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `entries` | array | ✅ (setidaknya 1 valid) | Daftar skor peserta |
| 2 | `entries[].nama` | string | ✅ | Nama peserta |
| 3 | `entries[].skor` | int | ✗ | Skor peserta |

**Contoh request:**

```http
PUT /api/room/482913/result HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "entries": [
    { "nama": "Budi", "skor": 90 },
    { "nama": "Ani", "skor": 75 },
    { "nama": "Cici", "skor": 60 }
  ]
}
```

**Response:**

| Status | Deskripsi |
|---|---|
| 200 | Result diperbarui/baru |
| 400 | Kode kosong / nama kosong |
| 404 | Room tidak ditemukan |

**Contoh response — `200 OK`**

```json
{
  "result": {
    "id": "<id>",
    "room_id": "<room_id>",
    "kode": "482913",
    "quiz_id": "6651a0ab...",
    "entries": [
      { "nama": "Budi", "skor": 90 },
      { "nama": "Ani", "skor": 75 },
      { "nama": "Cici", "skor": 60 }
    ],
    "created_at": "2026-09-17T10:00:00Z"
  }
}
```

**Contoh response — `400 Bad Request`**

```json
{ "message": "Kode room wajib diisi" }
```

**Contoh response — `404 Not Found`**

```json
{ "message": "Room tidak ditemukan" }
```

### 6.4 GET /api/results

| Metode | Path | Auth |
|---|---|---|
| GET | `/api/results` | ✓ |

Tidak ada request parameter.

**Contoh request:**

```http
GET /api/results HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi |
|---|---|
| 200 | Semua result |
| 401 | Sesi tidak valid |

**Contoh response — `200 OK`**

```json
{
  "results": [
    {
      "id": "<id>",
      "room_id": "<room_id>",
      "kode": "482913",
      "quiz_id": "6651a0ab...",
      "entries": [
        { "nama": "Budi", "skor": 90 },
        { "nama": "Ani", "skor": 75 },
        { "nama": "Cici", "skor": 60 }
      ],
      "created_at": "2026-09-17T10:00:00Z"
    }
  ]
}
```

**Contoh response — `401 Unauthorized`**

```json
{ "message": "Token tidak valid" }
```

---

## 7. Kode Error Umum

| Kode | Arti | Contoh pesan |
|---|---|---|
| 400 | Request/atribut tidak valid | `Request tidak valid` / `Status room harus salah satu dari: waiting, open, in-Game, ended` |
| 401 | Autentikasi gagal atau sesi berakhir | `Token tidak valid` / `Sesi telah berakhir, silakan login kembali` |
| 404 | Data tidak ditemukan | `Kuis tidak ditemukan` / `Room tidak ditemukan` / `Result tidak ditemukan` |
| 409 | Konflik data (duplikat) | `NIM sudah terdaftar` / `Room sudah memiliki result` |
| 500 | Error server | `Gagal membuat akun` / `Gagal membuat room` |
