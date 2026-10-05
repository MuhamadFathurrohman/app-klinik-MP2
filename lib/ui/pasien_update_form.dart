import 'package:flutter/material.dart';
import '../helpers/api_client.dart';
import '../model/pasien.dart';
import '../service/pasien_service.dart';

class PasienUpdateForm extends StatefulWidget {
  final Pasien pasien;

  const PasienUpdateForm({super.key, required this.pasien});

  @override
  State<PasienUpdateForm> createState() => _PasienUpdateFormState();
}

class _PasienUpdateFormState extends State<PasienUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomorRmCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();
  final _nomorTeleponCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  bool _prosesMuat = true;
  bool _prosesSimpan = false;
  String? _pesanGagalMuat;

  Future<void> getData() async {
    final String? id = widget.pasien.id;
    if (id == null || id.isEmpty) {
      setState(() {
        _prosesMuat = false;
        _pesanGagalMuat = 'Data pasien tidak punya id, tidak bisa diubah.';
      });
      return;
    }
    try {
      Pasien data = await PasienService().getById(id);
      // Halaman bisa sudah ditutup sebelum request selesai; tanpa cek ini
      // setState dipanggil setelah dispose dan aplikasi melempar error.
      if (!mounted) return;
      setState(() {
        _nomorRmCtrl.text = data.nomorRm;
        _namaCtrl.text = data.nama;
        _tanggalLahirCtrl.text = data.tanggalLahir;
        _nomorTeleponCtrl.text = data.nomorTelepon;
        _alamatCtrl.text = data.alamat;
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
        title: const Text("Ubah Pasien"),
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
        child: Text(_prosesSimpan ? "Menyimpan..." : "Simpan Perubahan"));
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String id = widget.pasien.id!;
    setState(() => _prosesSimpan = true);
    Pasien pasien = Pasien(
      nomorRm: _nomorRmCtrl.text.trim(),
      nama: _namaCtrl.text.trim(),
      tanggalLahir: _tanggalLahirCtrl.text.trim(),
      nomorTelepon: _nomorTeleponCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
    );
    try {
      await PasienService().ubah(pasien, id);
      if (!mounted) return;
      // Cukup kembali ke halaman detail yang sudah ada di stack sambil memberi
      // tanda bahwa data berubah, supaya detail mengambil data terbaru.
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

String _formatTanggal(DateTime tanggal) {
  return "${tanggal.year.toString().padLeft(4, '0')}-"
      "${tanggal.month.toString().padLeft(2, '0')}-"
      "${tanggal.day.toString().padLeft(2, '0')}";
}
