# Simple E-Learning Platform (Student App)

Aplikasi mobile E-Learning berbasis **Flutter** yang dibangun untuk memenuhi **Technical Assessment - Flutter Developer (Track B)**. Aplikasi ini memungkinkan siswa (*Student*) untuk menjelajahi katalog kursus, melihat rincian materi, memilih video pelajaran, serta memutar streaming video dengan kontrol lengkap dan manajemen memori yang aman.

---

## 📱 Fitur Utama (Sesuai Kriteria Assessment)

| Fitur | Status | Deskripsi Implementasi |
|---|---|---|
| **Course List** | ✅ Selesai | Menampilkan daftar kursus dengan cover thumbnail, judul, kategori, rating, instruktur, jumlah materi, filter kategori interaktif, dan pencarian. |
| **Course Detail** | ✅ Selesai | Menampilkan header kursus, instruktur, deskripsi lengkap, serta daftar urutan materi (*lessons*) dengan durasi. |
| **Lesson Selection** | ✅ Selesai | Siswa dapat memilih materi kursus untuk ditonton, baik dari halaman detail maupun dari modal playlist materi di halaman pemutar video. |
| **Video Streaming** | ✅ Selesai | Pemutaran video materi beresolusi tinggi menggunakan Google Cloud Video Storage publik yang stabil dan cepat. |
| **Player Controls** | ✅ Selesai | Mendukung Play, Pause, Scrubbing/Seek bar, Mundur/Maju 10 detik, Fullscreen, indikator Buffering, dan tombol Coba Lagi (*Retry*) jika terjadi error. |
| **Navigation & Lifecycle** | ✅ Selesai | Pengguna dapat kembali ke daftar kursus atau memilih materi lain. **Controller video di-pause dan di-dispose secara aman** saat keluar halaman atau berganti materi untuk mencegah kebocoran memori (*memory leak*). |
| **State Handling** | ✅ Selesai | Menangani 4 kondisi antarmuka secara elegan: **Loading** (Shimmer/Spinner), **Empty State** (Tampilan kosong informatif), **Error State** (Pesan kesalahan + tombol Retry), dan **Data State**. |

---

## 🏗️ Arsitektur & Struktur Proyek

Aplikasi menerapkan **Feature-First Clean Architecture** dengan memisahkan kode menjadi lapisan **Domain**, **Data**, dan **Presentation**:

```text
lib/
├── core/
│   ├── theme/                  # Desain Material 3, Token Warna (AppColors), Tipografi
│   └── utils/                  # Formatters & helper utilities
├── features/
│   ├── course/                 # Fitur Katalog & Detail Kursus
│   │   ├── data/
│   │   │   ├── datasources/    # Pembaca data mock JSON lokal
│   │   │   ├── models/         # Model DTO & JSON Serialization (fromJson / toJson)
│   │   │   └── repositories/   # Implementasi konkret CourseRepository
│   │   ├── domain/
│   │   │   ├── entities/       # Pure Dart Entities (Course, Lesson, Instructor)
│   │   │   └── repositories/   # Kontrak abstrak CourseRepository
│   │   └── presentation/
│   │       ├── controllers/    # Riverpod Notifier & AsyncNotifier (State Management)
│   │       ├── screens/        # CourseListScreen, CourseDetailScreen
│   │       └── widgets/        # CourseCard, CourseHeader, LessonListTile, Error/Empty Views
│   └── video_player/           # Fitur Pemutar Video Streaming
│       ├── domain/
│       │   └── entities/       # LessonPlayerState & PlayerStatus
│       ├── presentation/
│       │   ├── controllers/    # LessonPlayerNotifier
│       │   ├── screens/        # LessonPlayerScreen
│       │   └── widgets/        # CustomPlayerControls, LessonPlaylistSheet
└── routing/
    └── app_router.dart         # Declarative Routing dengan GoRouter
```

---

## 🛠️ Tech Stack & Alasan Pemilihan

* **Framework:** Flutter (versi 3.50.0+) / Dart (versi 3.14.0+)
* **State Management:** `flutter_riverpod` (v3.5.0) — *Compile-time safe*, tidak membutuhkan `BuildContext` di luar UI, mudah diuji dan di-mock.
* **Video Playback:** `video_player` & `chewie` — Plugin resmi Flutter untuk streaming video dengan hardware acceleration, dilengkapi kontrol antarmuka Material lengkap.
* **Routing:** `go_router` (v18.1.4) — Navigasi deklaratif dengan dukungan URL parameter dinamis (`/courses/:courseId/lessons/:lessonId`) dan manajemen *back stack* yang rapi.
* **Testing:** `flutter_test` & `mocktail` — Pengujian unit model, repository, controller, serta widget test tanpa perlu generator *build_runner*.

---

## 🚀 Prasyarat & Cara Menjalankan

### 1. Prasyarat Sistem
* Flutter SDK versi `^3.14.0` atau yang lebih baru.
* Emulator Android, Simulator iOS, atau perangkat fisik yang terhubung.

### 2. Langkah Instalasi & Menjalankan Aplikasi
```bash
# 1. Masuk ke direktori aplikasi
cd course_app

# 2. Unduh seluruh dependensi paket
flutter pub get

# 3. Jalankan aplikasi pada perangkat/simulator aktif
flutter run
```

### 3. Menjalankan Pengujian (Automated Tests)
Seluruh pengujian unit model, repository, notifier, dan widget telah disiapkan dengan tingkat kelulusan 100%:
```bash
# Menjalankan seluruh test suite
flutter test

# Menjalankan analisis kode (linter)
flutter analyze
```

---

## 📑 Dokumentasi Desain Sistem & Diagram

Dokumentasi lengkap mengenai rancangan sistem telah disediakan pada berkas terpisah:
👉 **[Lihat Dokumentasi Desain Sistem (docs/system_design.md)](docs/system_design.md)**

Di dalamnya mencakup:
1. **Diagram Arsitektur Sistem** (*Component & Layering Diagram*)
2. **Entity-Relationship Diagram (ERD)** / Model Data
3. **Flowchart Alur Pengguna** (*Navigation & Video Streaming Flow*)
4. **Sequence Diagram Siklus Hidup Pemutar Video** (*Lifecycle & Disposal Flow*)
5. **Kontrak Skema JSON** serta Petunjuk Migrasi dari Mock ke Real REST API.

---

## 🔍 Penanganan Kasus Tepi (Edge Cases)

1. **Jaringan Terputus / Kegagalan API:** Ditangani oleh `ErrorStateView` dengan pesan error yang ramah pengguna serta tombol **Coba Lagi (Retry)**.
2. **Koleksi Kosong (Empty State):** Ditampilkan `EmptyStateView` saat tidak ada kursus yang sesuai dengan kata kunci pencarian atau filter kategori.
3. **Pencegahan Memory Leak:** Setiap perpindahan materi (*switching lesson*) atau penutupan halaman (*pop/back*), `VideoPlayerController` dan `ChewieController` di-pause dan di-dispose untuk mencegah tumpang tindih audio dan kebocoran memori.
4. **Thumbnail Error / Offline:** Dilengkapi fallback placeholder icon bergradien agar tampilan antarmuka tetap konsisten dan tidak rusak.

---

## 📌 Asumsi & Keterbatasan

* **Asumsi:** Fokus aplikasi adalah pada pengalaman belajar siswa (*Student*). Tidak memerlukan fitur autentikasi akun maupun panel admin (sesuai instruksi brief).
* **Keterbatasan:** Penyimpanan video offline terenkripsi (*download and offline view with local DRM*) belum diimplementasikan; saat ini pemutaran dilakukan melalui alur streaming jaringan langsung (*progressive streaming*).
