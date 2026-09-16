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
| GET | `/api/my-quizzes` | ✓ | List kuis milik user sendiri |
| POST | `/api/create/quiz` | ✓ | Membuat kuis baru |
| GET | `/api/quizzes` | ✓ | List semua kuis |
| GET | `/api/quiz/{id}` | ✓ | Detail kuis berdasarkan ID |
| POST | `/api/room` | ✓ | Membuat room baru |
| GET | `/api/rooms` | ✓ | List semua room |
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

| Status | Deskripsi | Contoh body |
|---|---|---|
| 201 | Berhasil | `{"message":"Akun berhasil dibuat","user":{"nim":"124240200","nama":"Budi Santoso","kelas":"Pemrograman Mobile SI-B","tanggal_lahir":"2004-03-10"}}` |
| 400 | Wajib diisi / format salah | `{"message":"NIM, nama, kelas, password, dan tanggal lahir wajib diisi"}` |
| 400 | Tanggal lahir masa depan | `{"message":"Tanggal lahir tidak boleh di masa depan"}` |
| 400 | Format tanggal salah | `{"message":"Format tanggal lahir harus YYYY-MM-DD"}` |
| 409 | NIM sudah terdaftar | `{"message":"NIM sudah terdaftar"}` |
| 500 | Error server | `{"message":"Gagal membuat akun"}` |

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

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | Berhasil, dapat token | `{"token":"<JWT>","user":{"nim":"124240200","nama":"Budi Santoso","kelas":"Pemrograman Mobile SI-B"}}` |
| 400 | Wajib diisi | `{"message":"NIM dan password wajib diisi"}` |
| 401 | NIM/password salah | `{"message":"NIM atau password salah"}` |
| 500 | Error server | `{"message":"Gagal membuat token"}` |

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

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | Berhasil logout | `{"message":"Logout berhasil, sesi berakhir"}` |
| 401 | Token tidak ditemukan | `{"message":"Token tidak ditemukan"}` |
| 401 | Token tidak valid | `{"message":"Token tidak valid"}` |
| 401 | Sesi sudah berakhir | `{"message":"Sesi telah berakhir, silakan login kembali"}` |
| 500 | Error server | `{"message":"Gagal menghapus sesi"}` |

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

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | Sesi valid | `{"valid":true,"user":{"nim":"124240200","nama":"Budi Santoso","kelas":"Pemrograman Mobile SI-B"}}` |
| 401 | Sesi tidak valid | `{"message":"Sesi tidak valid"}` |

---

## 4. Quiz

### 4.1 GET /api/my-quizzes

| Metode | Path | Auth |
|---|---|---|
| GET | `/api/my-quizzes` | ✓ |

Tidak ada request parameter. Response hanya kuis milik user yang login.

**Contoh request:**

```http
GET /api/my-quizzes HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | List kuis milik sendiri | `{"quizzes":[{"id":"<id>","user_id":"<user_id>","title":"Kuis Pemrograman Mobile","description":"Dasar Flutter & Dart","questions":[{"question":"Bahasa pemrograman utama Flutter?","options":["Kotlin","Dart","Swift","Java"],"duration":1.5}],"created_at":"2026-09-17T10:00:00Z"}]}` |
| 401 | Sesi tidak valid | `{"message":"Sesi tidak valid"}` |
| 401 | User tidak ditemukan | `{"message":"User tidak ditemukan"}` |

> Catatan: `correct_idx` tidak dikembalikan pada response untuk menjaga jawaban benar tetap rahasia.

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
      "duration": 1.5
    }
  ]
}
```

> Untuk submit berhasil butuh minimal **10 soal**; contoh di atas hanya ilustrasi 1 soal.

**Response:**

| Status | Deskripsi | Contoh body |
|---|---|---|
| 201 | Kuis dibuat | `{"message":"Kuis berhasil dibuat","quiz":{"id":"<id>","user_id":"<user_id>","title":"Kuis Pemrograman Mobile","description":"Dasar Flutter & Dart","questions":[{"question":"Bahasa pemrograman utama Flutter?","options":["Kotlin","Dart","Swift","Java"],"duration":1.5}],"created_at":"2026-09-17T10:00:00Z"}}` |
| 400 | Judul kosong | `{"message":"Judul kuis wajib diisi"}` |
| 400 | Soal < 10 | `{"message":"Kuis harus memiliki minimal 10 soal"}` |
| 400 | Soal ke-n tidak valid | `{"message":"Soal ke-1 wajib diisi"}` |
| 400 | Opsi != 4 | `{"message":"Soal ke-1 harus memiliki tepat 4 opsi jawaban"}` |
| 400 | correct_idx salah | `{"message":"correct_idx soal ke-1 tidak valid"}` |
| 400 | Durasi salah | `{"message":"durasi soal ke-1 harus salah satu dari: 1.5, 2, 3, atau 5 detik"}` |

### 4.3 GET /api/quizzes

| Metode | Path | Auth |
|---|---|---|
| GET | `/api/quizzes` | ✓ |

Tidak ada request parameter.

**Contoh request:**

```http
GET /api/quizzes HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | Semua kuis | `{"quizzes":[{"id":"<id>","user_id":"<user_id>","title":"Kuis Basis Data MongoDB","description":"Konsep dasar MongoDB","questions":[{"question":"MongoDB termasuk database jenis apa?","options":["SQL","Redis","NoSQL","GraphQL"],"duration":2}],"created_at":"2026-09-17T10:00:00Z"}]}` |
| 401 | Sesi tidak valid | `{"message":"Token tidak valid"}` |

### 4.4 GET /api/quiz/{id}

| Metode | Path | Auth |
|---|---|---|
| GET | `/api/quiz/{id}` | ✓ |

**Path parameter:**

| No | Parameter | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `id` | string (ObjectId hex) | ✅ | ID kuis, contoh `6651a0ab...` |

**Contoh request:**

```http
GET /api/quiz/6651a0ab0000000000000000 HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | Detail kuis | `{"quiz":{"id":"<id>","user_id":"<user_id>","title":"Kuis REST API","description":"Dasar REST API Go","questions":[{"question":"Kode status untuk data berhasil dibuat?","options":["200","201","202","204"],"duration":1.5}],"created_at":"2026-09-17T10:00:00Z"}}` |
| 400 | ID tidak valid | `{"message":"ID kuis tidak valid"}` |
| 404 | Kuis tidak ada | `{"message":"Kuis tidak ditemukan"}` |

---

## 5. Room

### 5.1 POST /api/room

| Metode | Path | Auth |
|---|---|---|
| POST | `/api/room` | ✓ |

**Request body:**

| No | Field | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `quiz_id` | string (ObjectId) | ✅ | ID kuis yang dimainkan di room |
| 2 | `status` | string | ✗ | `waiting` (default), `open`, `in-Game`, `ended` |

**Contoh request:**

```http
POST /api/room HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "quiz_id": "6651a0ab0000000000000000"
}
```

**Response:**

| Status | Deskripsi | Contoh body |
|---|---|---|
| 201 | Room dibuat | `{"message":"Room berhasil dibuat","room":{"id":"<id>","quiz_id":"6651a0ab...","quiz":{"id":"6651a0ab...","title":"Kuis Pemrograman Mobile","description":"Dasar Flutter & Dart","total_questions":10},"kode":"482913","status":"waiting","created_at":"2026-09-17T10:00:00Z"}}` |
| 400 | quiz_id kosong | `{"message":"quiz_id wajib diisi"}` |
| 400 | quiz_id tidak valid | `{"message":"quiz_id tidak valid"}` |
| 400 | status tidak valid | `{"message":"Status room harus salah satu dari: waiting, open, in-Game, ended"}` |
| 404 | Kuis tidak ada | `{"message":"Kuis tidak ditemukan"}` |

### 5.2 GET /api/rooms

| Metode | Path | Auth |
|---|---|---|
| GET | `/api/rooms` | ✓ |

**Query parameter (opsional):**

| No | Parameter | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `quiz_id` | string (ObjectId) | ✗ | Filter room berdasarkan kuis |

**Contoh request:**

```http
GET /api/rooms?quiz_id=6651a0ab0000000000000000 HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
```

**Response:**

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | List room | `{"rooms":[{"id":"<id>","quiz_id":"6651a0ab...","quiz":{"id":"6651a0ab...","title":"Kuis Pemrograman Mobile","description":"Dasar Flutter & Dart","total_questions":10},"kode":"482913","status":"waiting","created_at":"2026-09-17T10:00:00Z"}]}` |
| 400 | quiz_id tidak valid | `{"message":"quiz_id tidak valid"}` |

### 5.3 PUT /api/room/{id}/status

| Metode | Path | Auth |
|---|---|---|
| PUT | `/api/room/{id}/status` | ✓ |

**Path parameter:**

| No | Parameter | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `id` | string (ObjectId) | ✅ | ID room |

**Request body:**

| No | Field | Tipe | Wajib | Deskripsi |
|---|---|---|---|---|
| 1 | `status` | string | ✅ | `waiting`, `open`, `in-Game`, `ended` |

**Contoh request:**

```http
PUT /api/room/6651a0ab0000000000000001/status HTTP/1.1
Host: localhost:8080
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "status": "in-Game"
}
```

**Response:**

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | Status berubah | `{"message":"Status room berhasil diubah","room":{"id":"<id>","quiz_id":"6651a0ab...","quiz":{"id":"6651a0ab...","title":"Kuis Pemrograman Mobile","description":"Dasar Flutter & Dart","total_questions":10},"kode":"482913","status":"in-Game","created_at":"2026-09-17T10:00:00Z"}}` |
| 400 | ID tidak valid | `{"message":"ID room tidak valid"}` |
| 400 | Status tidak valid | `{"message":"Status room harus salah satu dari: waiting, open, in-Game, ended"}` |
| 404 | Room tidak ada | `{"message":"Room tidak ditemukan"}` |

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

| Status | Deskripsi | Contoh body |
|---|---|---|
| 201 | Result dibuat | `{"message":"Result berhasil dibuat","result":{"id":"<id>","room_id":"<room_id>","kode":"482913","quiz_id":"6651a0ab...","entries":[{"nama":"Budi","skor":80},{"nama":"Ani","skor":70}],"created_at":"2026-09-17T10:00:00Z"}}` |
| 400 | Kode kosong | `{"message":"Kode room wajib diisi"}` |
| 400 | Nama peserta kosong | `{"message":"nama peserta ke-1 wajib diisi"}` |
| 404 | Room tidak ditemukan | `{"message":"Room tidak ditemukan"}` |
| 409 | Room sudah punya result | `{"message":"Room sudah memiliki result"}` |

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

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | Result ditemukan | `{"result":{"id":"<id>","room_id":"<room_id>","kode":"482913","quiz_id":"6651a0ab...","quiz":{"id":"6651a0ab...","title":"Kuis Pemrograman Mobile","description":"Dasar Flutter & Dart","total_questions":10},"entries":[{"nama":"Budi","skor":80},{"nama":"Ani","skor":70}],"created_at":"2026-09-17T10:00:00Z"}}` |
| 400 | Kode kosong | `{"message":"Kode room wajib diisi"}` |
| 404 | Result tidak ada | `{"message":"Result tidak ditemukan"}` |

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

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | Result diperbarui/baru | `{"result":{"id":"<id>","room_id":"<room_id>","kode":"482913","quiz_id":"6651a0ab...","entries":[{"nama":"Budi","skor":90},{"nama":"Ani","skor":75},{"nama":"Cici","skor":60}],"created_at":"2026-09-17T10:00:00Z"}}` |
| 400 | Kode kosong / nama kosong | `{"message":"Kode room wajib diisi"}` |
| 404 | Room tidak ditemukan | `{"message":"Room tidak ditemukan"}` |

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

| Status | Deskripsi | Contoh body |
|---|---|---|
| 200 | Semua result | `{"results":[{"id":"<id>","room_id":"<room_id>","kode":"482913","quiz_id":"6651a0ab...","entries":[{"nama":"Budi","skor":90},{"nama":"Ani","skor":75},{"nama":"Cici","skor":60}],"created_at":"2026-09-17T10:00:00Z"}]}` |
| 401 | Sesi tidak valid | `{"message":"Token tidak valid"}` |

---

## 7. Kode Error Umum

| Kode | Arti | Contoh pesan |
|---|---|---|
| 400 | Request/atribut tidak valid | `Request tidak valid` / `Status room harus salah satu dari: waiting, open, in-Game, ended` |
| 401 | Autentikasi gagal atau sesi berakhir | `Token tidak valid` / `Sesi telah berakhir, silakan login kembali` |
| 404 | Data tidak ditemukan | `Kuis tidak ditemukan` / `Room tidak ditemukan` / `Result tidak ditemukan` |
| 409 | Konflik data (duplikat) | `NIM sudah terdaftar` / `Room sudah memiliki result` |
| 500 | Error server | `Gagal membuat akun` / `Gagal membuat room` |