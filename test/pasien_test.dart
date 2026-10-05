import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinik_app/model/pasien.dart';
import 'package:klinik_app/service/pasien_service.dart';
import 'package:klinik_app/ui/pasien_form.dart';

import 'fake_dio.dart';

void main() {
  setUp(pasangBaseUrlTest);

  tearDown(lepasFakeAdapter);

  group('Pasien.fromJson', () {
    test('memetakan semua field dari JSON snake_case', () {
      final pasien = Pasien.fromJson({
        "id": "4",
        "nomor_rm": "RM-001",
        "nama": "Ani",
        "tanggal_lahir": "1995-12-01",
        "nomor_telepon": "08987654321",
        "alamat": "Jl. Merdeka 10",
      });

      expect(pasien.id, "4");
      expect(pasien.nomorRm, "RM-001");
      expect(pasien.nama, "Ani");
      expect(pasien.tanggalLahir, "1995-12-01");
      expect(pasien.nomorTelepon, "08987654321");
      expect(pasien.alamat, "Jl. Merdeka 10");
    });

    test('id bertipe int tetap dibaca sebagai String', () {
      expect(Pasien.fromJson({"id": 8, "nama": "Ani"}).id, "8");
    });

    test('field null menjadi string kosong, bukan crash', () {
      final pasien = Pasien.fromJson({
        "id": null,
        "nomor_rm": null,
        "nama": null,
        "tanggal_lahir": null,
        "nomor_telepon": null,
        "alamat": null,
      });

      expect(pasien.id, isNull);
      expect(pasien.nomorRm, "");
      expect(pasien.nama, "");
      expect(pasien.tanggalLahir, "");
      expect(pasien.nomorTelepon, "");
      expect(pasien.alamat, "");
    });

    test('tanggal bertipe Date dari mockapi dipotong jadi yyyy-MM-dd', () {
      final pasien = Pasien.fromJson(
          {"id": "1", "tanggal_lahir": "1995-12-01T00:00:00.000Z"});

      expect(pasien.tanggalLahir, "1995-12-01");
    });

    test('toJson memakai key snake_case dan tanpa id', () {
      final pasien = Pasien(
        id: "4",
        nomorRm: "RM-001",
        nama: "Ani",
        tanggalLahir: "1995-12-01",
        nomorTelepon: "08987654321",
        alamat: "Jl. Merdeka 10",
      );

      expect(pasien.toJson(), {
        "nomor_rm": "RM-001",
        "nama": "Ani",
        "tanggal_lahir": "1995-12-01",
        "nomor_telepon": "08987654321",
        "alamat": "Jl. Merdeka 10",
      });
    });
  });

  group('PasienService', () {
    test('listData memetakan daftar pasien dari API', () async {
      pasangFakeAdapter((options) => jsonResponse(
          '[{"id":"1","nomor_rm":"RM-001","nama":"Ani"},'
          '{"id":"2","nomor_rm":"RM-002","nama":"Joko"}]'));

      final hasil = await PasienService().listData();

      expect(hasil.length, 2);
      expect(hasil.first.nama, "Ani");
      expect(hasil.last.nomorRm, "RM-002");
    });

    test('tetap memakai endpoint utama (BASE_URL), bukan milik pegawai',
        () async {
      final adapter = pasangFakeAdapter((options) => jsonResponse('[]'));

      await PasienService().listData();

      expect(adapter.baseUrls, [baseUrlTest]);
      expect(adapter.paths, ['pasien']);
    });

    test('ubah memakai path pasien/<id>', () async {
      final adapter =
          pasangFakeAdapter((options) => jsonResponse('{"id":"7","nama":"Ani"}'));

      await PasienService().ubah(
          Pasien(
              nomorRm: "RM-001",
              nama: "Ani",
              tanggalLahir: "1995-12-01",
              nomorTelepon: "08987",
              alamat: ""),
          "7");

      expect(adapter.paths, ["pasien/7"]);
    });

    test('hapus menolak pasien tanpa id dan tidak memanggil API', () async {
      final adapter =
          pasangFakeAdapter((options) => jsonResponse('{"id":"1"}'));

      expect(
          () => PasienService().hapus(Pasien(
              nomorRm: "RM-001",
              nama: "Ani",
              tanggalLahir: "1995-12-01",
              nomorTelepon: "08987",
              alamat: "")),
          throwsA(predicate((e) => e.toString().contains('tidak punya id'))));
      expect(adapter.requests, isEmpty);
    });
  });

  group('PasienForm', () {
    testWidgets('menampilkan seluruh field sesuai skema',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PasienForm()));

      expect(find.text('Tambah Pasien'), findsOneWidget);
      expect(find.text('Nomor RM'), findsOneWidget);
      expect(find.text('Nama'), findsOneWidget);
      expect(find.text('Tanggal Lahir'), findsOneWidget);
      expect(find.text('Nomor Telepon'), findsOneWidget);
      expect(find.text('Alamat'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('menolak simpan saat field wajib kosong dan tidak memanggil API',
        (WidgetTester tester) async {
      final adapter =
          pasangFakeAdapter((options) => jsonResponse('{"id":"1"}'));

      await tester.pumpWidget(const MaterialApp(home: PasienForm()));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Nomor RM tidak boleh kosong'), findsOneWidget);
      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.text('Tanggal lahir tidak boleh kosong'), findsOneWidget);
      expect(find.text('Nomor telepon tidak boleh kosong'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    });

    testWidgets('alamat boleh kosong, tidak ikut divalidasi',
        (WidgetTester tester) async {
      pasangFakeAdapter((options) => jsonResponse('{"id":"1"}'));

      await tester.pumpWidget(const MaterialApp(home: PasienForm()));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Alamat tidak boleh kosong'), findsNothing);
    });
  });
}
