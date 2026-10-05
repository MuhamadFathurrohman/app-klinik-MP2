import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import 'pasien_item.dart';
import 'pasien_form.dart';
import '../widget/sidebar.dart';

class PasienPage extends StatefulWidget {
  const PasienPage({super.key});

  @override
  State<PasienPage> createState() => _PasienPageState();
}

class _PasienPageState extends State<PasienPage> {
  // Stream disimpan di state, bukan dibuat ulang di dalam build(), supaya satu
  // kali muat hanya menghasilkan satu request ke API.
  late Stream<List<Pasien>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = getList();
  }

  Stream<List<Pasien>> getList() async* {
    List<Pasien> data = await PasienService().listData();
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
        title: const Text("Data Pasien"),
        actions: [
          GestureDetector(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.add),
            ),
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PasienForm()));
              if (!mounted) return;
              refresh();
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot<List<Pasien>> snapshot) {
          if (snapshot.hasError) {
            return _pesanGagal(snapshot.error!);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<Pasien> daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(child: Text('Data Kosong'));
          }

          return ListView.builder(
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              return PasienItem(
                pasien: daftar[index],
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
