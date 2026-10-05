import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/pegawai.dart';

class PegawaiService {
  // Resource "pegawai" berada di endpoint mockapi kedua, bukan di BASE_URL
  // yang dipakai poli dan pasien. Dibuat sebagai getter supaya nilainya selalu
  // dibaca ulang dari .env.
  ApiClient get _api =>
      ApiClient(baseUrl: kBaseUrlPegawai, namaKey: 'BASE_URL_PEGAWAI');

  Future<List<Pegawai>> listData() async {
    final Response response = await _api.get('pegawai');
    final data = response.data;
    if (data is! List) {
      throw Exception('Format data dari server tidak sesuai.');
    }
    List<Pegawai> result = data.map((item) => _kePegawai(item)).toList();
    return result;
  }

  Future<Pegawai> simpan(Pegawai pegawai) async {
    var data = pegawai.toJson();
    final Response response = await _api.post('pegawai', data);
    Pegawai result = _kePegawai(response.data);
    return result;
  }

  Future<Pegawai> ubah(Pegawai pegawai, String id) async {
    var data = pegawai.toJson();
    final Response response = await _api.put('pegawai/$id', data);
    Pegawai result = _kePegawai(response.data);
    return result;
  }

  Future<Pegawai> getById(String id) async {
    final Response response = await _api.get('pegawai/$id');
    Pegawai result = _kePegawai(response.data);
    return result;
  }

  Future<Pegawai> hapus(Pegawai pegawai) async {
    final String? id = pegawai.id;
    if (id == null || id.isEmpty) {
      throw Exception('Data pegawai tidak punya id, tidak bisa dihapus.');
    }
    final Response response = await _api.delete('pegawai/$id');
    Pegawai result = _kePegawai(response.data);
    return result;
  }

  // mockapi.io bisa menjawab dengan string (mis. pesan error) atau Map dengan
  // key dinamis, jadi bentuknya diperiksa dulu sebelum dipetakan ke Pegawai.
  Pegawai _kePegawai(dynamic json) {
    if (json is! Map) {
      throw Exception('Format data pegawai dari server tidak sesuai.');
    }
    return Pegawai.fromJson(Map<String, dynamic>.from(json));
  }
}
