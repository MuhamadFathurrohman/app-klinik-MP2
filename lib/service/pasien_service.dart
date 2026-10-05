import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/pasien.dart';

class PasienService {
  Future<List<Pasien>> listData() async {
    final Response response = await ApiClient().get('pasien');
    final data = response.data;
    if (data is! List) {
      throw Exception('Format data dari server tidak sesuai.');
    }
    List<Pasien> result = data.map((item) => _kePasien(item)).toList();
    return result;
  }

  Future<Pasien> simpan(Pasien pasien) async {
    var data = pasien.toJson();
    final Response response = await ApiClient().post('pasien', data);
    Pasien result = _kePasien(response.data);
    return result;
  }

  Future<Pasien> ubah(Pasien pasien, String id) async {
    var data = pasien.toJson();
    final Response response = await ApiClient().put('pasien/$id', data);
    Pasien result = _kePasien(response.data);
    return result;
  }

  Future<Pasien> getById(String id) async {
    final Response response = await ApiClient().get('pasien/$id');
    Pasien result = _kePasien(response.data);
    return result;
  }

  Future<Pasien> hapus(Pasien pasien) async {
    final String? id = pasien.id;
    if (id == null || id.isEmpty) {
      throw Exception('Data pasien tidak punya id, tidak bisa dihapus.');
    }
    final Response response = await ApiClient().delete('pasien/$id');
    Pasien result = _kePasien(response.data);
    return result;
  }

  // mockapi.io bisa menjawab dengan string (mis. pesan error) atau Map dengan
  // key dinamis, jadi bentuknya diperiksa dulu sebelum dipetakan ke Pasien.
  Pasien _kePasien(dynamic json) {
    if (json is! Map) {
      throw Exception('Format data pasien dari server tidak sesuai.');
    }
    return Pasien.fromJson(Map<String, dynamic>.from(json));
  }
}
