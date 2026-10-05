import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/pegawai.dart';
import '../service/pegawai_service.dart';
import 'pegawai_detail.dart';

class PegawaiForm extends StatefulWidget {
  const PegawaiForm({super.key});

  @override
  State<PegawaiForm> createState() => _PegawaiFormState();
}

class _PegawaiFormState extends State<PegawaiForm> {
  final _formKey = GlobalKey<FormState>();
  final _nipCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();
  final _nomorTeleponCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _prosesSimpan = false;

  @override
  void dispose() {
    _nipCtrl.dispose();
    _namaCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    _nomorTeleponCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text("Tambah Pegawai"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _fieldNip(),
                const SizedBox(height: 12),
                _fieldNama(),
                const SizedBox(height: 12),
                _fieldTanggalLahir(),
                const SizedBox(height: 12),
                _fieldNomorTelepon(),
                const SizedBox(height: 12),
                _fieldEmail(),
                const SizedBox(height: 12),
                _fieldPassword(),
                const SizedBox(height: 20),
                _tombolSimpan(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldNip() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "NIP"),
      controller: _nipCtrl,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "NIP tidak boleh kosong";
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

  Widget _fieldEmail() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Email"),
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Email tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _fieldPassword() {
    return TextFormField(
      decoration: const InputDecoration(labelText: "Password"),
      controller: _passwordCtrl,
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password tidak boleh kosong";
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
    Pegawai pegawai = Pegawai(
      nip: _nipCtrl.text.trim(),
      nama: _namaCtrl.text.trim(),
      tanggalLahir: _tanggalLahirCtrl.text.trim(),
      nomorTelepon: _nomorTeleponCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    try {
      final Pegawai hasil = await PegawaiService().simpan(pegawai);
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PegawaiDetail(pegawai: hasil)));
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
