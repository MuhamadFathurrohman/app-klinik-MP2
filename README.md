# klinik_app

Aplikasi Klinik — tugas Mobile Programming II (UBSI), Pertemuan 2 s/d 13.

Aplikasi Flutter dengan login dummy dan CRUD penuh untuk tiga entitas (Poli,
Pegawai, Pasien) yang tersimpan di REST API [mockapi.io](https://mockapi.io)
dan diakses memakai `dio`.

## Fitur

- Login admin (dummy, tanpa API) dengan token disimpan di `SharedPreferences`.
- Sidebar (Drawer): Beranda, Poli, Pegawai, Pasien, Keluar.
- CRUD Poli, Pegawai, dan Pasien: list, tambah, detail, ubah, hapus, dengan
  dialog konfirmasi sebelum menghapus.
- Status loading, pesan error yang bisa dibaca, dan tampilan "Data Kosong".

Login: **username `admin`, password `admin`**.

## Prasyarat

- Flutter 3.29.0 (Dart 3.7.0) channel stable.
- Android SDK 35 untuk build Android.
- JDK 17–23 untuk menjalankan Gradle. **Catatan:** Gradle 8.10.2 yang dipakai
  project ini belum mendukung Java 25, sedangkan Android Studio versi baru
  memakai JDK 25 bawaan (JBR). Kalau build gagal dengan pesan
  `Unsupported class file major version 69`, arahkan Flutter ke JDK yang
  didukung:

  ```bash
  flutter config --jdk-dir "C:\Program Files\Java\jdk-23.0.2"
  ```

  Untuk mengembalikan ke JDK bawaan Android Studio: `flutter config --jdk-dir=`.

## Setup

### 1. Dependency

```bash
flutter pub get
```

### 2. File .env

Alamat API tidak ditulis di dalam kode. Salin contohnya lalu isi dengan endpoint
sendiri:

```bash
cp .env.example .env
```

Isi `.env`:

```env
BASE_URL=https://xxxxxxxx.mockapi.io/api/v1/
BASE_URL_PEGAWAI=https://yyyyyyyy.mockapi.io/api/v1/
```

`.env` sengaja tidak di-commit (ada di `.gitignore`), sedangkan `.env.example`
di-commit sebagai contoh. File `.env` wajib ada karena didaftarkan sebagai asset
di `pubspec.yaml`; tanpa file itu build akan gagal. Kalau salah satu alamat masih
kosong atau masih berisi contoh, aplikasi tetap bisa dibuka dan halaman data
menampilkan pesan yang menyebut key mana yang belum diisi.

### 3. Setup mockapi.io (dua endpoint)

Akun mockapi.io gratis hanya menampung **2 resource per project**, sedangkan
aplikasi ini butuh tiga (`poli`, `pasien`, `pegawai`). Karena itu datanya dipecah
ke dua project/endpoint:

| Key di `.env` | Resource di dalamnya |
| --- | --- |
| `BASE_URL` | `poli`, `pasien` |
| `BASE_URL_PEGAWAI` | `pegawai` |

Langkahnya:

1. Buat akun di <https://mockapi.io/>.
2. Buat project pertama, misalnya `klinik`, lalu isi resource `poli` dan
   `pasien`. Salin **API endpoint**-nya ke `BASE_URL`.
3. Buat project kedua, misalnya `klinik2`, lalu isi resource `pegawai`. Salin
   **API endpoint**-nya ke `BASE_URL_PEGAWAI`.
4. Nama resource dan nama field harus **huruf kecil dan snake_case**, persis
   seperti tabel di bawah (`id` dibuat otomatis oleh mockapi).

Resource `poli` (di `BASE_URL`):

| Field | Tipe |
| --- | --- |
| `nama_poli` | String |

Resource `pegawai` (di `BASE_URL_PEGAWAI`, project kedua):

| Field | Tipe |
| --- | --- |
| `nip` | String |
| `nama` | String |
| `tanggal_lahir` | Date |
| `nomor_telepon` | String |
| `email` | String |
| `password` | String |

Resource `pasien` (di `BASE_URL`):

| Field | Tipe |
| --- | --- |
| `nomor_rm` | String |
| `nama` | String |
| `tanggal_lahir` | Date |
| `nomor_telepon` | String |
| `alamat` | String |

`tanggal_lahir` boleh dibuat bertipe `Date` maupun `String`: aplikasi menyimpan
dan mengirimnya sebagai teks `yyyy-MM-dd`, dan nilai `Date` dari mockapi
(contoh `1990-04-21T00:00:00.000Z`) otomatis dipotong ke format tersebut.

## Menjalankan

```bash
flutter run                   # jalankan di device/emulator
flutter analyze               # target: No issues found
flutter test                  # unit + widget test, tanpa jaringan
flutter build apk --debug     # build APK debug
```

## Struktur folder

```
lib/
├── main.dart                     # muat .env, cek token, Login atau Beranda
├── helpers/
│   ├── api_client.dart           # dio per endpoint (.env) + pemetaan error
│   └── user_info.dart            # token/userID/username di SharedPreferences
├── model/
│   ├── poli.dart
│   ├── pegawai.dart
│   └── pasien.dart
├── service/
│   ├── login_service.dart        # login dummy admin/admin
│   ├── poli_service.dart
│   ├── pegawai_service.dart
│   └── pasien_service.dart
├── widget/
│   └── sidebar.dart              # Drawer navigasi
└── ui/
    ├── login.dart
    ├── beranda.dart
    ├── poli_page.dart            # list Poli
    ├── poli_item.dart
    ├── poli_form.dart            # tambah Poli
    ├── poli_detail.dart          # detail + ubah/hapus
    ├── poli_update_form.dart     # ubah Poli
    ├── pegawai_page.dart         # list Pegawai
    ├── pegawai_item.dart
    ├── pegawai_form.dart
    ├── pegawai_detail.dart
    ├── pegawai_update_form.dart
    ├── pasien_page.dart          # list Pasien
    ├── pasien_item.dart
    ├── pasien_form.dart
    ├── pasien_detail.dart
    └── pasien_update_form.dart

test/
├── fake_dio.dart                 # adapter dio palsu + BASE_URL versi test
├── widget_test.dart              # login, list/detail Poli, navigasi drawer
├── poli_service_test.dart
├── pegawai_test.dart             # model + service + form Pegawai
├── pasien_test.dart              # model + service + form Pasien
└── user_info_test.dart
```

Seluruh test memakai adapter dio palsu, jadi tidak ada test yang memanggil
mockapi.io sungguhan.
