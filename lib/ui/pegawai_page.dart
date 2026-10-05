import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';
import 'pegawai_item.dart';
import 'pegawai_form.dart';
import '../widget/sidebar.dart';

class PegawaiPage extends StatefulWidget {
  const PegawaiPage({super.key});

  @override
  State<PegawaiPage> createState() => _PegawaiPageState();
}

class _PegawaiPageState extends State<PegawaiPage> {
  // Stream disimpan di state, bukan dibuat ulang di dalam build(), supaya satu
  // kali muat hanya menghasilkan satu request ke API.
  late Stream<List<Pegawai>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = getList();
  }

  Stream<List<Pegawai>> getList() async* {
    List<Pegawai> data = await PegawaiService().listData();
    yield data;
  }

  void refresh() {
    setState(() {
      _stream = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text("Data Pegawai"),
        actions: [
          GestureDetector(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.add),
            ),
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PegawaiForm()));
              if (!mounted) return;
              refresh();
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot<List<Pegawai>> snapshot) {
          if (snapshot.hasError) {
            return _pesanGagal(snapshot.error!);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<Pegawai> daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(child: Text('Data Kosong'));
          }

          return ListView.builder(
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              return PegawaiItem(
                pegawai: daftar[index],
                // Data bisa berubah di halaman detail (ubah/hapus), jadi daftar
                // dimuat ulang begitu kembali ke sini.
                onKembali: () {
                  if (!mounted) return;
                  refresh();
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _pesanGagal(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(pesanError(error), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: refresh,
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }
}
