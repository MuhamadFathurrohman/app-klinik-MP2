import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';
import 'pasien_detail.dart';

class PasienForm extends StatefulWidget {
  const PasienForm({super.key});

  @override
  State<PasienForm> createState() => _PasienFormState();
}

class _PasienFormState extends State<PasienForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomorRmCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();
  final _nomorTeleponCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  bool _prosesSimpan = false;

  @override
  void dispose() {
    _nomorRmCtrl.dispose();
    _namaCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    _nomorTeleponCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text("Tambah Pasien"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _fieldNomorRm(),
                const SizedBox(height: 12),
                _fieldNama(),
                const SizedBox(height: 12),
                _fieldTanggalLahir(),
                const SizedBox(height: 12),
                _fieldNomorTelepon(),
                const SizedBox(height: 12),
                _fieldAlamat(),
                const SizedBox(height: 20),
                _tombolSimpan(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldNomorRm() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Nomor RM"),
      controller: _nomorRmCtrl,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Nomor RM tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _fieldNama() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Nama"),
      controller: _namaCtrl,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Nama tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _fieldTanggalLahir() {
    // Read-only supaya isinya selalu yyyy-MM-dd dan tidak bisa diketik bebas.
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Tanggal Lahir",
        hintText: "yyyy-MM-dd",
        suffixIcon: Icon(Icons.calendar_today),
      ),
      controller: _tanggalLahirCtrl,
      readOnly: true,
      onTap: _pilihTanggal,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Tanggal lahir tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Future<void> _pilihTanggal() async {
    final DateTime sekarang = DateTime.now();
    final DateTime pertama = DateTime(1940);
    // showDatePicker melempar assertion kalau initialDate di luar rentang,
    // sedangkan tanggal yang datang dari server bisa di luar 1940..hari ini.
    DateTime awal = DateTime.tryParse(_tanggalLahirCtrl.text) ??
        DateTime(sekarang.year - 20);
    if (awal.isBefore(pertama)) awal = pertama;
    if (awal.isAfter(sekarang)) awal = sekarang;
    final DateTime? dipilih = await showDatePicker(
      context: context,
      initialDate: awal,
      firstDate: pertama,
      lastDate: sekarang,
    );
    if (dipilih == null) return;
    setState(() {
      _tanggalLahirCtrl.text = _formatTanggal(dipilih);
    });
  }

  Widget _fieldNomorTelepon() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Nomor Telepon"),
      controller: _nomorTeleponCtrl,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Nomor telepon tidak boleh kosong";
        }
        return null;
      },
    );
  }

  // Alamat boleh kosong, jadi tidak diberi validator.
  Widget _fieldAlamat() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Alamat"),
      controller: _alamatCtrl,
      maxLines: 2,
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
    Pasien pasien = Pasien(
      nomorRm: _nomorRmCtrl.text.trim(),
      nama: _namaCtrl.text.trim(),
      tanggalLahir: _tanggalLahirCtrl.text.trim(),
      nomorTelepon: _nomorTeleponCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
    );
    try {
      final Pasien hasil = await PasienService().simpan(pasien);
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => PasienDetail(pasien: hasil)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _prosesSimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: ${pesanError(e)}")),
      );
    }
  }
}

String _formatTanggal(DateTime tanggal) {
  return "${tanggal.year.toString().padLeft(4, '0')}-"
      "${tanggal.month.toString().padLeft(2, '0')}-"
      "${tanggal.day.toString().padLeft(2, '0')}";
}
