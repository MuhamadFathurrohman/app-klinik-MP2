import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'helpers/user_info.dart';
import 'ui/beranda.dart';
import 'ui/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Kalau .env belum dibuat, aplikasi tetap jalan dan halaman data yang
  // menampilkan pesan bahwa alamat API belum diatur.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Gagal memuat .env: $e');
  }
  var token = await UserInfo().getToken();
  runApp(MaterialApp(
    title: "Klinik APP",
    debugShowCheckedModeBanner: false,
    home: token == null ? const Login() : const Beranda(),
  ));
}
