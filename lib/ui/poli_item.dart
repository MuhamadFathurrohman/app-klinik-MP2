import 'package:flutter/material.dart';
import '../model/poli.dart';
import 'poli_detail.dart';

class PoliItem extends StatelessWidget {
  final Poli poli;

  // Dipanggil setelah halaman detail ditutup, supaya daftar bisa dimuat ulang.
  final VoidCallback? onKembali;

  const PoliItem({super.key, required this.poli, this.onKembali});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => PoliDetail(poli: poli)));
        onKembali?.call();
      },
      child: Card(
        child: ListTile(
          title: Text(poli.namaPoli),
        ),
      ),
    );
  }
}
