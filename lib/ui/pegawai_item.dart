import 'package:flutter/material.dart';
import '../model/pegawai.dart';
import 'pegawai_detail.dart';

class PegawaiItem extends StatelessWidget {
  final Pegawai pegawai;

  // Dipanggil setelah halaman detail ditutup, supaya daftar bisa dimuat ulang.
  final VoidCallback? onKembali;

  const PegawaiItem({super.key, required this.pegawai, this.onKembali});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PegawaiDetail(pegawai: pegawai)));
        onKembali?.call();
      },
      child: Card(
        child: ListTile(
          title: Text(pegawai.nama),
          subtitle: Text(pegawai.nip),
        ),
      ),
    );
  }
}
