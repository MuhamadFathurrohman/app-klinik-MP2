import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';
import 'pegawai_update_form.dart';

class PegawaiDetail extends StatefulWidget {
  final Pegawai pegawai;

  const PegawaiDetail({super.key, required this.pegawai});

  @override
  State<PegawaiDetail> createState() => _PegawaiDetailState();
}

class _PegawaiDetailState extends State<PegawaiDetail> {
  // Satu stream dipakai bersama oleh seluruh halaman, jadi membuka halaman ini
  // hanya mengirim satu request ke API.
  late Stream<Pegawai> _stream;
  bool _prosesHapus = false;

  @override
  void initState() {
    super.initState();
    _stream = getData();
  }

  Stream<Pegawai> getData() async* {
    final String? id = widget.pegawai.id;
    if (id == null || id.isEmpty) {
      throw Exception('Data pegawai tidak punya id, detail tidak bisa dimuat.');
    }
    Pegawai data = await PegawaiService().getById(id);
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
        title: const Text("Detail Pegawai"),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot<Pegawai> snapshot) {
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
          final Pegawai? pegawai = snapshot.data;
          if (pegawai == null) {
            return const Center(child: Text('Data Tidak Ditemukan'));
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _baris("NIP", pegawai.nip),
                  _baris("Nama", pegawai.nama),
                  _baris("Tanggal Lahir", pegawai.tanggalLahir),
                  _baris("Nomor Telepon", pegawai.nomorTelepon),
                  _baris("Email", pegawai.email),
                  // Password tidak ditampilkan polos di layar.
                  _baris("Password", "••••••"),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [_tombolUbah(pegawai), _tombolHapus(pegawai)],
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

  Widget _tombolUbah(Pegawai pegawai) {
    return ElevatedButton(
        onPressed: _prosesHapus
            ? null
            : () async {
                final bool? berubah = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PegawaiUpdateForm(pegawai: pegawai)));
                if (!mounted) return;
                if (berubah == true) {
                  refresh();
                }
              },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text("Ubah"));
  }

  Widget _tombolHapus(Pegawai pegawai) {
    return ElevatedButton(
        onPressed: _prosesHapus ? null : () => _konfirmasiHapus(pegawai),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text("Hapus"));
  }

  void _konfirmasiHapus(Pegawai pegawai) {
    AlertDialog alertDialog = AlertDialog(
      content: const Text("Yakin ingin menghapus data ini?"),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _hapus(pegawai);
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

  Future<void> _hapus(Pegawai pegawai) async {
    setState(() => _prosesHapus = true);
    try {
      await PegawaiService().hapus(pegawai);
      if (!mounted) return;
      // Kembali ke Data Pegawai yang sudah ada di stack (bukan push halaman
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
