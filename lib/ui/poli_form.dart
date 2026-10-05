import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/poli.dart';
import '../service/poli_service.dart';
import 'poli_detail.dart';

class PoliForm extends StatefulWidget {
  const PoliForm({super.key});

  @override
  State<PoliForm> createState() => _PoliFormState();
}

class _PoliFormState extends State<PoliForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPoliCtrl = TextEditingController();
  bool _prosesSimpan = false;

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
        title: const Text("Tambah Poli"),
      ),
      body: SingleChildScrollView(
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
      ),
    );
  }

  Widget _fieldNamaPoli() {
    // TextFormField, bukan TextField, supaya validator Form ikut berjalan.
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
        child: Text(_prosesSimpan ? "Menyimpan..." : "Simpan"));
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _prosesSimpan = true);
    Poli poli = Poli(namaPoli: _namaPoliCtrl.text.trim());
    try {
      final Poli hasil = await PoliService().simpan(poli);
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => PoliDetail(poli: hasil)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _prosesSimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: ${pesanError(e)}")),
      );
    }
  }
}
