import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';

class PoliUpdateForm extends StatefulWidget {
  final Poli poli;

  const PoliUpdateForm({super.key, required this.poli});

  @override
  State<PoliUpdateForm> createState() => _PoliUpdateFormState();
}

class _PoliUpdateFormState extends State<PoliUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPoliCtrl = TextEditingController();
  bool _prosesMuat = true;
  bool _prosesSimpan = false;
  String? _pesanGagalMuat;

  Future<void> getData() async {
    final String? id = widget.poli.id;
    if (id == null || id.isEmpty) {
      setState(() {
        _prosesMuat = false;
        _pesanGagalMuat = 'Data poli tidak punya id, tidak bisa diubah.';
      });
      return;
    }
    try {
      Poli data = await PoliService().getById(id);
      // Halaman bisa sudah ditutup sebelum request selesai; tanpa cek ini
      // setState dipanggil setelah dispose dan aplikasi melempar error.
      if (!mounted) return;
      setState(() {
        _namaPoliCtrl.text = data.namaPoli;
        _prosesMuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _prosesMuat = false;
        _pesanGagalMuat = pesanError(e);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _namaPoliCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text("Ubah Poli"),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_prosesMuat) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pesanGagalMuat != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_pesanGagalMuat!, textAlign: TextAlign.center),
        ),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _fieldNamaPoli(),
              const SizedBox(height: 20),
              _tombolSimpan()
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldNamaPoli() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Nama Poli"),
      controller: _namaPoliCtrl,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Nama poli tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _tombolSimpan() {
    return ElevatedButton(
        onPressed: _prosesSimpan ? null : _simpan,
        child: Text(_prosesSimpan ? "Menyimpan..." : "Simpan Perubahan"));
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String id = widget.poli.id!;
    setState(() => _prosesSimpan = true);
    Poli poli = Poli(namaPoli: _namaPoliCtrl.text.trim());
    try {
      await PoliService().ubah(poli, id);
      if (!mounted) return;
      // Cukup kembali ke halaman detail yang sudah ada di stack sambil memberi
      // tanda bahwa data berubah. Versi lama melakukan pop lalu pushReplacement
      // sehingga halaman detail jadi menumpuk.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _prosesSimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan perubahan: ${pesanError(e)}")),
      );
    }
  }
}
