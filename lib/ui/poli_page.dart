import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import 'poli_item.dart';
import 'poli_form.dart';
import '../widget/sidebar.dart';

class PoliPage extends StatefulWidget {
  const PoliPage({super.key});

  @override
  State<PoliPage> createState() => _PoliPageState();
}

class _PoliPageState extends State<PoliPage> {
  // Stream disimpan di state, bukan dibuat ulang di dalam build(), supaya satu
  // kali muat hanya menghasilkan satu request ke API.
  late Stream<List<Poli>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = getList();
  }

  Stream<List<Poli>> getList() async* {
    List<Poli> data = await PoliService().listData();
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
        title: const Text("Data Poli"),
        actions: [
          GestureDetector(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.add),
            ),
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PoliForm()));
              if (!mounted) return;
              refresh();
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot<List<Poli>> snapshot) {
          if (snapshot.hasError) {
            return _pesanGagal(snapshot.error!);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<Poli> daftar = snapshot.data ?? [];
          if (daftar.isEmpty) {
            return const Center(child: Text('Data Kosong'));
          }

          return ListView.builder(
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              return PoliItem(
                poli: daftar[index],
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
