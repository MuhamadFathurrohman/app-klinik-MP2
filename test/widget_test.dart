// Widget test untuk klinik_app.
//
// Semua request API digantikan FakeDioAdapter (lihat test/fake_dio.dart),
// sehingga test tidak pernah menyentuh jaringan maupun mockapi.io.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:klinik_app/model/poli.dart';
import 'package:klinik_app/ui/beranda.dart';
import 'package:klinik_app/ui/login.dart';
import 'package:klinik_app/ui/poli_detail.dart';
import 'package:klinik_app/ui/poli_page.dart';

import 'fake_dio.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    pasangBaseUrlTest();
  });

  tearDown(lepasFakeAdapter);

  testWidgets('Halaman Login menampilkan form login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Login()));

    expect(find.text('Login Admin'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login kosong ditolak validator dan tidak pindah halaman',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Login()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Username tidak boleh kosong'), findsOneWidget);
    expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    expect(find.text('Login Admin'), findsOneWidget);
    expect(await SharedPreferences.getInstance()
        .then((pref) => pref.getString('token')), isNull);
  });

  testWidgets('Data Poli kosong menampilkan teks Data Kosong',
      (WidgetTester tester) async {
    pasangFakeAdapter((options) => jsonResponse('[]'));

    await tester.pumpWidget(const MaterialApp(home: PoliPage()));
    await tester.pumpAndSettle();

    expect(find.text('Data Kosong'), findsOneWidget);
  });

  testWidgets('Data Poli menampilkan daftar dari API',
      (WidgetTester tester) async {
    pasangFakeAdapter((options) => jsonResponse(
        '[{"id":"1","nama_poli":"Gigi"},{"id":"2","nama_poli":"Anak"}]'));

    await tester.pumpWidget(const MaterialApp(home: PoliPage()));
    await tester.pumpAndSettle();

    expect(find.text('Gigi'), findsOneWidget);
    expect(find.text('Anak'), findsOneWidget);
  });

  testWidgets('Data Poli yang gagal dimuat menampilkan pesan dan tombol ulang',
      (WidgetTester tester) async {
    pasangFakeAdapter((options) => jsonResponse('{}', statusCode: 500));

    await tester.pumpWidget(const MaterialApp(home: PoliPage()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Server menolak permintaan'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('Detail Poli hanya mengirim satu request ke API',
      (WidgetTester tester) async {
    final adapter = pasangFakeAdapter(
        (options) => jsonResponse('{"id":"1","nama_poli":"Gigi"}'));

    await tester.pumpWidget(MaterialApp(
        home: PoliDetail(poli: Poli(id: "1", namaPoli: "Gigi"))));
    await tester.pumpAndSettle();

    expect(find.text('Nama Poli : Gigi'), findsOneWidget);
    expect(adapter.paths, ['poli/1']);
  });

  testWidgets('Detail Poli tanpa id tidak memanggil poli/null',
      (WidgetTester tester) async {
    final adapter = pasangFakeAdapter(
        (options) => jsonResponse('{"id":"1","nama_poli":"Gigi"}'));

    await tester
        .pumpWidget(MaterialApp(home: PoliDetail(poli: Poli(namaPoli: "Gigi"))));
    await tester.pumpAndSettle();

    expect(adapter.requests, isEmpty);
    expect(find.textContaining('tidak punya id'), findsOneWidget);
  });

  testWidgets('Menu drawer tidak menumpuk halaman yang sama',
      (WidgetTester tester) async {
    pasangFakeAdapter((options) => jsonResponse('[]'));

    await tester.pumpWidget(const MaterialApp(home: Beranda()));
    await _bukaDrawer(tester, find.byType(Beranda));
    await tester.tap(find.text('Poli'));
    await tester.pumpAndSettle();

    expect(find.byType(PoliPage), findsOneWidget);
    expect(find.text('Data Poli'), findsOneWidget);

    // Menekan "Poli" lagi dari halaman Poli tidak boleh menambah halaman baru.
    await _bukaDrawer(tester, find.byType(PoliPage));
    await tester.tap(find.descendant(
        of: find.byType(Drawer), matching: find.text('Poli')));
    await tester.pumpAndSettle();

    expect(find.byType(PoliPage), findsOneWidget);

    // Dan "Beranda" mengembalikan ke halaman awal, bukan menumpuk Beranda baru.
    await _bukaDrawer(tester, find.byType(PoliPage));
    await tester.tap(find.descendant(
        of: find.byType(Drawer), matching: find.text('Beranda')));
    await tester.pumpAndSettle();

    expect(find.byType(PoliPage), findsNothing);
    expect(find.text('Selamat Datang'), findsOneWidget);
  });

  testWidgets('Tombol Ubah dan Hapus baru muncul setelah data termuat',
      (WidgetTester tester) async {
    pasangFakeAdapter(
        (options) => jsonResponse('{"id":"1","nama_poli":"Gigi"}'));

    await tester.pumpWidget(MaterialApp(
        home: PoliDetail(poli: Poli(id: "1", namaPoli: "Gigi"))));
    await tester.pump();

    // Saat masih loading tombol belum ada, jadi tidak mungkin ditekan sebelum
    // data siap (penyebab crash snapshot.data! di versi modul).
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Ubah'), findsNothing);
    expect(find.text('Hapus'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('Ubah'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
  });
}

/// Membuka drawer milik halaman tertentu (bukan drawer halaman di bawahnya).
Future<void> _bukaDrawer(WidgetTester tester, Finder halaman) async {
  final ScaffoldState scaffold = tester.state<ScaffoldState>(
      find.descendant(of: halaman, matching: find.byType(Scaffold)).first);
  scaffold.openDrawer();
  await tester.pumpAndSettle();
}
