import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Alamat API diambil dari file .env, bukan ditulis di kode, supaya endpoint
// pribadi tidak ikut ter-commit ke repo.
//
// Akun mockapi.io gratis hanya menampung 2 resource per project, jadi datanya
// dipecah ke dua endpoint:
//   BASE_URL          -> resource "poli" dan "pasien"
//   BASE_URL_PEGAWAI  -> resource "pegawai"
//
// Cara menyiapkannya (sesuai Pertemuan 9 modul):
// 1. Buat akun di https://mockapi.io/
// 2. Buat project pertama (mis. "klinik") berisi resource "poli" dan "pasien",
//    lalu project kedua (mis. "klinik2") berisi resource "pegawai"
// 3. Salin .env.example menjadi .env, lalu isi BASE_URL dengan "API endpoint"
//    project pertama dan BASE_URL_PEGAWAI dengan endpoint project kedua
//    (contoh: https://xxxxxxxx.mockapi.io/api/v1/)
// Schema tiap resource ada di README.md.

/// Endpoint untuk resource `poli` dan `pasien`.
String get kBaseUrl => dotenv.env['BASE_URL']?.trim() ?? '';

/// Endpoint kedua, khusus resource `pegawai`.
String get kBaseUrlPegawai => dotenv.env['BASE_URL_PEGAWAI']?.trim() ?? '';

const String _kPlaceholderUtama = 'REPLACE_WITH_YOUR_MOCKAPI_ID';
const String _kPlaceholderKedua = 'REPLACE_WITH_YOUR_SECOND_MOCKAPI_ID';

bool _belumDiatur(String baseUrl) =>
    baseUrl.isEmpty ||
    baseUrl.contains(_kPlaceholderUtama) ||
    baseUrl.contains(_kPlaceholderKedua);

/// true kalau BASE_URL belum ada, masih kosong, atau masih contoh dari modul.
bool get isBaseUrlBelumDiatur => _belumDiatur(kBaseUrl);

/// true kalau BASE_URL_PEGAWAI belum ada, masih kosong, atau masih contoh.
bool get isBaseUrlPegawaiBelumDiatur => _belumDiatur(kBaseUrlPegawai);

// Membuang awalan "Exception: " supaya pesan enak dibaca saat ditampilkan di UI.
String pesanError(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

// Satu instance Dio per base URL, dibuat sekali lalu dipakai ulang, supaya
// kedua endpoint punya pengaturan timeout yang sama tanpa saling menimpa.
//
// mockapi.io pada paket gratis sering baru menjawab setelah belasan detik,
// terutama pada request pertama, jadi timeout dibuat lapang agar tidak muncul
// kegagalan palsu.
final Map<String, Dio> _dioPerBaseUrl = {};

Dio dioUntuk(String baseUrl) => _dioPerBaseUrl.putIfAbsent(
      baseUrl,
      () => Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30))),
    );

class ApiClient {
  /// [baseUrl] default-nya [kBaseUrl]. PegawaiService memakai
  /// [kBaseUrlPegawai]. [namaKey] hanya dipakai di pesan error, supaya jelas
  /// key .env mana yang belum diisi.
  ApiClient({String? baseUrl, String? namaKey})
      : _baseUrl = baseUrl ?? kBaseUrl,
        _namaKey = namaKey ?? 'BASE_URL';

  final String _baseUrl;
  final String _namaKey;

  Future<Response> get(String path) async {
    final Dio dio = _dioSiap();
    try {
      final response = await dio.get(Uri.encodeFull(path));
      return response;
    } on DioException catch (e) {
      throw Exception(_pesanError(e));
    }
  }

  Future<Response> post(String path, dynamic data) async {
    final Dio dio = _dioSiap();
    try {
      final response = await dio.post(Uri.encodeFull(path), data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(_pesanError(e));
    }
  }

  Future<Response> put(String path, dynamic data) async {
    final Dio dio = _dioSiap();
    try {
      final response = await dio.put(Uri.encodeFull(path), data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(_pesanError(e));
    }
  }

  Future<Response> delete(String path) async {
    final Dio dio = _dioSiap();
    try {
      final response = await dio.delete(Uri.encodeFull(path));
      return response;
    } on DioException catch (e) {
      throw Exception(_pesanError(e));
    }
  }

  Dio _dioSiap() {
    if (_belumDiatur(_baseUrl)) {
      throw Exception('Alamat API belum diatur: $_namaKey di file .env masih '
          'kosong atau masih contoh. Salin .env.example menjadi .env lalu isi '
          '$_namaKey dengan API endpoint mockapi.io milikmu.');
    }
    return dioUntuk(_baseUrl);
  }

  // DioException.message sering null (mis. pada timeout dan bad response),
  // sehingga tanpa pemetaan ini UI cuma menampilkan "Exception: null".
  String _pesanError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Koneksi ke server timeout. Periksa jaringan lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat menghubungi server. Periksa koneksi internet.';
      case DioExceptionType.badResponse:
        final int? status = e.response?.statusCode;
        if (status == 404) {
          return 'Data tidak ditemukan di server (404).';
        }
        return 'Server menolak permintaan (kode ${status ?? '-'}).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat server tidak valid.';
      case DioExceptionType.unknown:
        return e.message ?? 'Terjadi kesalahan saat menghubungi server.';
    }
  }
}
