import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:klinik_app/helpers/api_client.dart';

/// Adapter palsu untuk dio supaya seluruh test berjalan tanpa jaringan.
///
/// Dipasang ke instance Dio milik api_client.dart, jadi ApiClient dan service
/// diuji apa adanya tanpa perlu mengubah kode produksi.
class FakeDioAdapter implements HttpClientAdapter {
  FakeDioAdapter(this.handler);

  /// Mengembalikan body untuk tiap request yang masuk.
  final ResponseBody Function(RequestOptions options) handler;

  /// Semua request yang sempat dikirim, dipakai untuk memastikan jumlah
  /// pemanggilan API tidak berlebihan dan endpoint-nya benar.
  final List<RequestOptions> requests = [];

  List<String> get paths => requests.map((r) => r.path).toList();

  List<String> get baseUrls => requests.map((r) => r.baseUrl).toList();

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(String body, {int statusCode = 200}) {
  return ResponseBody.fromString(body, statusCode, headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  });
}

/// Alamat palsu untuk kedua endpoint mockapi. Sengaja dibuat berbeda supaya
/// test bisa memastikan pegawai memakai endpoint kedua.
const String baseUrlTest = 'https://contoh-test.mockapi.io/api/v1/';
const String baseUrlPegawaiTest =
    'https://contoh-test-pegawai.mockapi.io/api/v1/';

/// Mengisi BASE_URL dan BASE_URL_PEGAWAI versi test, supaya ApiClient punya
/// alamat tanpa membaca file .env asli dan tanpa menyentuh mockapi sungguhan.
void pasangBaseUrlTest() {
  dotenv.testLoad(fileInput: 'BASE_URL=$baseUrlTest\n'
      'BASE_URL_PEGAWAI=$baseUrlPegawaiTest');
}

final Map<Dio, HttpClientAdapter> _adapterAsli = {};

/// Memasang adapter palsu ke semua instance Dio (endpoint utama dan pegawai).
FakeDioAdapter pasangFakeAdapter(
    ResponseBody Function(RequestOptions options) handler) {
  final adapter = FakeDioAdapter(handler);
  for (final Dio dio in [dioUntuk(kBaseUrl), dioUntuk(kBaseUrlPegawai)]) {
    _adapterAsli.putIfAbsent(dio, () => dio.httpClientAdapter);
    dio.httpClientAdapter = adapter;
  }
  return adapter;
}

/// Mengembalikan adapter asli. Dipanggil di tearDown tiap file test.
void lepasFakeAdapter() {
  _adapterAsli.forEach((dio, adapter) => dio.httpClientAdapter = adapter);
  _adapterAsli.clear();
}
