import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import 'poli_update_form.dart';

class PoliDetail extends StatefulWidget {
  final Poli poli;

  const PoliDetail({super.key, required this.poli});

  @override
  State<PoliDetail> createState() => _PoliDetailState();
}

class _PoliDetailState extends State<PoliDetail> {
  // Satu stream dipakai bersama oleh seluruh halaman. Versi awal memanggil
  // getData() di dalam build() dan di dalam masing-masing tombol, sehingga satu
  // kali buka halaman mengirim tiga request ke API.
  late Stream<Poli> _stream;
  bool _prosesHapus = false;

  @override
  void initState() {
    super.initState();
    _stream = getData();
  }

  Stream<Poli> getData() async* {
    final String? id = widget.poli.id;
    if (id == null || id.isEmpty) {
      throw Exception('Data poli tidak punya id, detail tidak bisa dimuat.');
    }
    Poli data = await PoliService().getById(id);
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
        title: const Text("Detail Poli"),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot<Poli> snapshot) {
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
          final Poli? poli = snapshot.data;
          if (poli == null) {
            return const Center(child: Text('Data Tidak Ditemukan'));
          }
          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Nama Poli : ${poli.namaPoli}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // Data yang sudah termuat dikirim ke tombol, jadi tidak ada
                // lagi snapshot.data! yang bisa null saat tombol ditekan.
                children: [_tombolUbah(poli), _tombolHapus(poli)],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _tombolUbah(Poli poli) {
    return ElevatedButton(
        onPressed: _prosesHapus
            ? null
            : () async {
                final bool? berubah = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PoliUpdateForm(poli: poli)));
                if (!mounted) return;
                if (berubah == true) {
                  refresh();
                }
              },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text("Ubah"));
  }

  Widget _tombolHapus(Poli poli) {
    return ElevatedButton(
        onPressed: _prosesHapus ? null : () => _konfirmasiHapus(poli),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text("Hapus"));
  }

  void _konfirmasiHapus(Poli poli) {
    AlertDialog alertDialog = AlertDialog(
      content: const Text("Yakin ingin menghapus data ini?"),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _hapus(poli);
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

  Future<void> _hapus(Poli poli) async {
    setState(() => _prosesHapus = true);
    try {
      await PoliService().hapus(poli);
      if (!mounted) return;
      // Kembali ke Data Poli yang sudah ada di stack (bukan push halaman baru)
      // dan memberi tanda supaya daftarnya dimuat ulang.
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
