import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klinik_app/helpers/api_client.dart';
import 'package:klinik_app/model/pegawai.dart';
import 'package:klinik_app/service/pegawai_service.dart';
import 'package:klinik_app/ui/pegawai_form.dart';
import 'package:klinik_app/ui/pegawai_update_form.dart';

import 'fake_dio.dart';

void main() {
  setUp(pasangBaseUrlTest);

  tearDown(lepasFakeAdapter);

  group('Pegawai.fromJson', () {
    test('memetakan semua field dari JSON snake_case', () {
      final pegawai = Pegawai.fromJson({
        "id": "3",
        "nip": "198765",
        "nama": "Budi",
        "tanggal_lahir": "1990-04-21",
        "nomor_telepon": "08123456789",
        "email": "budi@klinik.com",
        "password": "rahasia",
      });

      expect(pegawai.id, "3");
      expect(pegawai.nip, "198765");
      expect(pegawai.nama, "Budi");
      expect(pegawai.tanggalLahir, "1990-04-21");
      expect(pegawai.nomorTelepon, "08123456789");
      expect(pegawai.email, "budi@klinik.com");
      expect(pegawai.password, "rahasia");
    });

    test('id bertipe int tetap dibaca sebagai String', () {
      expect(Pegawai.fromJson({"id": 12, "nama": "Budi"}).id, "12");
    });

    test('field null menjadi string kosong, bukan crash', () {
      final pegawai = Pegawai.fromJson({
        "id": null,
        "nip": null,
        "nama": null,
        "tanggal_lahir": null,
        "nomor_telepon": null,
        "email": null,
        "password": null,
      });

      expect(pegawai.id, isNull);
      expect(pegawai.nip, "");
      expect(pegawai.nama, "");
      expect(pegawai.tanggalLahir, "");
      expect(pegawai.nomorTelepon, "");
      expect(pegawai.email, "");
      expect(pegawai.password, "");
    });

    test('tanggal bertipe Date dari mockapi dipotong jadi yyyy-MM-dd', () {
      final pegawai = Pegawai.fromJson(
          {"id": "1", "tanggal_lahir": "1990-04-21T00:00:00.000Z"});

      expect(pegawai.tanggalLahir, "1990-04-21");
    });

    test('toJson memakai key snake_case dan tanpa id', () {
      final pegawai = Pegawai(
        id: "3",
        nip: "198765",
        nama: "Budi",
        tanggalLahir: "1990-04-21",
        nomorTelepon: "08123456789",
        email: "budi@klinik.com",
        password: "rahasia",
      );

      expect(pegawai.toJson(), {
        "nip": "198765",
        "nama": "Budi",
        "tanggal_lahir": "1990-04-21",
        "nomor_telepon": "08123456789",
        "email": "budi@klinik.com",
        "password": "rahasia",
      });
    });
  });

  group('PegawaiService', () {
    test('listData memetakan daftar pegawai dari API', () async {
      pasangFakeAdapter((options) => jsonResponse(
          '[{"id":"1","nip":"111","nama":"Budi"},'
          '{"id":"2","nip":"222","nama":"Siti"}]'));

      final hasil = await PegawaiService().listData();

      expect(hasil.length, 2);
      expect(hasil.first.nama, "Budi");
      expect(hasil.last.nip, "222");
    });

    test('ubah memakai path pegawai/<id>', () async {
      final adapter = pasangFakeAdapter(
          (options) => jsonResponse('{"id":"5","nama":"Budi"}'));

      await PegawaiService().ubah(
          Pegawai(
              nip: "111",
              nama: "Budi",
              tanggalLahir: "1990-04-21",
              nomorTelepon: "08123",
              email: "budi@klinik.com",
              password: "rahasia"),
          "5");

      expect(adapter.paths, ["pegawai/5"]);
    });

    test('memakai endpoint kedua (BASE_URL_PEGAWAI), bukan BASE_URL', () async {
      final adapter = pasangFakeAdapter((options) => jsonResponse('[]'));

      await PegawaiService().listData();

      expect(adapter.baseUrls, [baseUrlPegawaiTest]);
      expect(adapter.paths, ['pegawai']);
    });

    test('pesan error menyebut BASE_URL_PEGAWAI kalau endpointnya belum diisi',
        () async {
      dotenv.testLoad(fileInput: 'BASE_URL=$baseUrlTest\n'
          'BASE_URL_PEGAWAI=https://REPLACE_WITH_YOUR_SECOND_MOCKAPI_ID.mockapi.io/');
      final adapter = pasangFakeAdapter((options) => jsonResponse('[]'));

      expect(isBaseUrlPegawaiBelumDiatur, isTrue);
      expect(isBaseUrlBelumDiatur, isFalse);
      expect(
          () => PegawaiService().listData(),
          throwsA(predicate(
              (e) => e.toString().contains('BASE_URL_PEGAWAI'))));
      expect(adapter.requests, isEmpty);
    });

    test('hapus menolak pegawai tanpa id dan tidak memanggil API', () async {
      final adapter =
          pasangFakeAdapter((options) => jsonResponse('{"id":"1"}'));

      expect(
          () => PegawaiService().hapus(Pegawai(
              nip: "111",
              nama: "Budi",
              tanggalLahir: "1990-04-21",
              nomorTelepon: "08123",
              email: "budi@klinik.com",
              password: "rahasia")),
          throwsA(predicate((e) => e.toString().contains('tidak punya id'))));
      expect(adapter.requests, isEmpty);
    });
  });

  group('PegawaiForm', () {
    testWidgets('menampilkan seluruh field sesuai skema',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PegawaiForm()));

      expect(find.text('Tambah Pegawai'), findsOneWidget);
      expect(find.text('NIP'), findsOneWidget);
      expect(find.text('Nama'), findsOneWidget);
      expect(find.text('Tanggal Lahir'), findsOneWidget);
      expect(find.text('Nomor Telepon'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('menolak simpan saat field kosong dan tidak memanggil API',
        (WidgetTester tester) async {
      final adapter =
          pasangFakeAdapter((options) => jsonResponse('{"id":"1"}'));

      await tester.pumpWidget(const MaterialApp(home: PegawaiForm()));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('NIP tidak boleh kosong'), findsOneWidget);
      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.text('Tanggal lahir tidak boleh kosong'), findsOneWidget);
      expect(find.text('Nomor telepon tidak boleh kosong'), findsOneWidget);
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    });

    testWidgets('date picker tetap terbuka walau tanggal lama di luar rentang',
        (WidgetTester tester) async {
      // Data lama bisa berisi tanggal sebelum 1940 (atau tanggal masa depan),
      // yang bikin showDatePicker melempar assertion kalau tidak dibatasi.
      pasangFakeAdapter((options) => jsonResponse(
          '{"id":"1","nip":"111","nama":"Budi","tanggal_lahir":"1930-01-01",'
          '"nomor_telepon":"08123","email":"b@k.com","password":"rahasia"}'));

      await tester.pumpWidget(MaterialApp(
          home: PegawaiUpdateForm(
              pegawai: Pegawai(
                  id: "1",
                  nip: "111",
                  nama: "Budi",
                  tanggalLahir: "1930-01-01",
                  nomorTelepon: "08123",
                  email: "b@k.com",
                  password: "rahasia"))));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tanggal Lahir'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('password disamarkan di layar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PegawaiForm()));

      final TextField password = tester.widget<TextField>(find.descendant(
          of: find.ancestor(
              of: find.text('Password'), matching: find.byType(TextFormField)),
          matching: find.byType(TextField)));

      expect(password.obscureText, isTrue);
    });
  });
}
