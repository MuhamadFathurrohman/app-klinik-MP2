import 'package:flutter/material.dart';
import '../model/pasien.dart';
import 'pasien_detail.dart';

class PasienItem extends StatelessWidget {
  final Pasien pasien;

  // Dipanggil setelah halaman detail ditutup, supaya daftar bisa dimuat ulang.
  final VoidCallback? onKembali;

  const PasienItem({super.key, required this.pasien, this.onKembali});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => PasienDetail(pasien: pasien)));
        onKembali?.call();
      },
      child: Card(
        child: ListTile(
          title: Text(pasien.nama),
          subtitle: Text(pasien.nomorRm),
        ),
      ),
    );
  }
}
