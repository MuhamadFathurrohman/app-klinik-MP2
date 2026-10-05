import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinik_app/helpers/api_client.dart';
import 'package:klinik_app/model/poli.dart';
import 'package:klinik_app/service/poli_service.dart';

import 'fake_dio.dart';

void main() {
  setUp(pasangBaseUrlTest);

  tearDown(lepasFakeAdapter);

  group('Poli.fromJson', () {
    test('id angka diubah menjadi String', () {
      final poli = Poli.fromJson({"id": 7, "nama_poli": "Gigi"});

      expect(poli.id, "7");
      expect(poli.namaPoli, "Gigi");
    });

    test('nama_poli null tidak membuat crash', () {
      final poli = Poli.fromJson({"id": "1", "nama_poli": null});

      expect(poli.id, "1");
      expect(poli.namaPoli, "");
    });

    test('toJson hanya mengirim nama_poli, id dibuat server', () {
      final poli = Poli(id: "9", namaPoli: "Anak");

      expect(poli.toJson(), {"nama_poli": "Anak"});
    });
  });

  group('PoliService', () {
    test('listData memetakan daftar poli dari API', () async {
      pasangFakeAdapter((options) => jsonResponse(
          '[{"id":"1","nama_poli":"Gigi"},{"id":"2","nama_poli":"Anak"}]'));

      final hasil = await PoliService().listData();

      expect(hasil.length, 2);
      expect(hasil.first.id, "1");
      expect(hasil.first.namaPoli, "Gigi");
    });

    test('listData mengembalikan daftar kosong, bukan error', () async {
      pasangFakeAdapter((options) => jsonResponse('[]'));

      expect(await PoliService().listData(), isEmpty);
    });

    test('listData melempar pesan jelas kalau format data salah', () async {
      pasangFakeAdapter((options) => jsonResponse('{"pesan":"bukan list"}'));

      expect(
          () => PoliService().listData(),
          throwsA(predicate((e) =>
              e.toString().contains('Format data dari server tidak sesuai'))));
    });

    test('ubah memakai path poli/<id> tanpa kurung kurawal', () async {
      final adapter = pasangFakeAdapter(
          (options) => jsonResponse('{"id":"5","nama_poli":"Mata"}'));

      await PoliService().ubah(Poli(namaPoli: "Mata"), "5");

      expect(adapter.paths, ["poli/5"]);
    });

    test('hapus menolak poli tanpa id dan tidak memanggil API', () async {
      final adapter =
          pasangFakeAdapter((options) => jsonResponse('{"id":"1"}'));

      expect(
          () => PoliService().hapus(Poli(namaPoli: "Gigi")),
          throwsA(predicate(
              (e) => e.toString().contains('tidak punya id'))));
      expect(adapter.requests, isEmpty);
    });
  });

  group('ApiClient', () {
    test('timeout cukup panjang untuk mockapi.io di kedua endpoint', () {
      for (final base in [kBaseUrl, kBaseUrlPegawai]) {
        final options = dioUntuk(base).options;
        expect(options.connectTimeout!.inSeconds, greaterThanOrEqualTo(15));
        expect(options.receiveTimeout!.inSeconds, greaterThanOrEqualTo(15));
      }
    });

    test('BASE_URL dari .env dipakai sebagai alamat dasar', () {
      expect(kBaseUrl, 'https://contoh-test.mockapi.io/api/v1/');
      expect(isBaseUrlBelumDiatur, isFalse);
    });

    test('BASE_URL kosong terdeteksi belum diatur', () {
      dotenv.testLoad(fileInput: 'BASE_URL=');

      expect(isBaseUrlBelumDiatur, isTrue);
    });

    test('BASE_URL masih placeholder terdeteksi belum diatur', () {
      dotenv.testLoad(
          fileInput:
              'BASE_URL=https://REPLACE_WITH_YOUR_MOCKAPI_ID.mockapi.io/');

      expect(isBaseUrlBelumDiatur, isTrue);
    });

    test('request ditolak dengan pesan jelas kalau BASE_URL belum diatur',
        () async {
      dotenv.testLoad(fileInput: 'BASE_URL=');
      final adapter = pasangFakeAdapter((options) => jsonResponse('[]'));

      expect(
          () => PoliService().listData(),
          throwsA(predicate(
              (e) => e.toString().contains('Alamat API belum diatur'))));
      expect(adapter.requests, isEmpty);
    });

    test('status 404 dilaporkan dengan pesan yang bisa dibaca', () async {
      pasangFakeAdapter((options) => jsonResponse('{}', statusCode: 404));

      expect(
          () => PoliService().getById("99"),
          throwsA(predicate(
              (e) => e.toString().contains('tidak ditemukan di server'))));
    });

    test('pesanError membuang awalan Exception', () {
      expect(pesanError(Exception('Koneksi timeout')), 'Koneksi timeout');
    });
  });
}
