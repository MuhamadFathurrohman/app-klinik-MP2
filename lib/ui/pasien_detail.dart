import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import 'pasien_update_form.dart';

class PasienDetail extends StatefulWidget {
  final Pasien pasien;

  const PasienDetail({super.key, required this.pasien});

  @override
  State<PasienDetail> createState() => _PasienDetailState();
}

class _PasienDetailState extends State<PasienDetail> {
  // Satu stream dipakai bersama oleh seluruh halaman, jadi membuka halaman ini
  // hanya mengirim satu request ke API.
  late Stream<Pasien> _stream;
  bool _prosesHapus = false;

  @override
  void initState() {
    super.initState();
    _stream = getData();
  }

  Stream<Pasien> getData() async* {
    final String? id = widget.pasien.id;
    if (id == null || id.isEmpty) {
      throw Exception('Data pasien tidak punya id, detail tidak bisa dimuat.');
    }
    Pasien data = await PasienService().getById(id);
    yield data;
  }

  void refresh() {
    setState(() {
      _stream = getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text("Detail Pasien"),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot<Pasien> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(pesanError(snapshot.error!),
                    textAlign: TextAlign.center),
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final Pasien? pasien = snapshot.data;
          if (pasien == null) {
            return const Center(child: Text('Data Tidak Ditemukan'));
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _baris("Nomor RM", pasien.nomorRm),
                  _baris("Nama", pasien.nama),
                  _baris("Tanggal Lahir", pasien.tanggalLahir),
                  _baris("Nomor Telepon", pasien.nomorTelepon),
                  _baris("Alamat", pasien.alamat),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [_tombolUbah(pasien), _tombolHapus(pasien)],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        "$label : $nilai",
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _tombolUbah(Pasien pasien) {
    return ElevatedButton(
        onPressed: _prosesHapus
            ? null
            : () async {
                final bool? berubah = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PasienUpdateForm(pasien: pasien)));
                if (!mounted) return;
                if (berubah == true) {
                  refresh();
                }
              },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text("Ubah"));
  }

  Widget _tombolHapus(Pasien pasien) {
    return ElevatedButton(
        onPressed: _prosesHapus ? null : () => _konfirmasiHapus(pasien),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text("Hapus"));
  }

  void _konfirmasiHapus(Pasien pasien) {
    AlertDialog alertDialog = AlertDialog(
      content: const Text("Yakin ingin menghapus data ini?"),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _hapus(pasien);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("YA"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Tidak"),
        )
      ],
    );
    showDialog(context: context, builder: (context) => alertDialog);
  }

  Future<void> _hapus(Pasien pasien) async {
    setState(() => _prosesHapus = true);
    try {
      await PasienService().hapus(pasien);
      if (!mounted) return;
      // Kembali ke Data Pasien yang sudah ada di stack (bukan push halaman
      // baru) dan memberi tanda supaya daftarnya dimuat ulang.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _prosesHapus = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: ${pesanError(e)}")),
      );
    }
  }
}
