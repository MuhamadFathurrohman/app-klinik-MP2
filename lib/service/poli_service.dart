import 'package:dio/dio.dart';
import '../helpers/api_client.dart';
import '../model/poli.dart';

class PoliService {
  Future<List<Poli>> listData() async {
    final Response response = await ApiClient().get('poli');
    final data = response.data;
    if (data is! List) {
      throw Exception('Format data dari server tidak sesuai.');
    }
    List<Poli> result = data.map((item) => _kePoli(item)).toList();
    return result;
  }

  Future<Poli> simpan(Poli poli) async {
    var data = poli.toJson();
    final Response response = await ApiClient().post('poli', data);
    Poli result = _kePoli(response.data);
    return result;
  }

  Future<Poli> ubah(Poli poli, String id) async {
    var data = poli.toJson();
    final Response response = await ApiClient().put('poli/$id', data);
    Poli result = _kePoli(response.data);
    return result;
  }

  Future<Poli> getById(String id) async {
    final Response response = await ApiClient().get('poli/$id');
    Poli result = _kePoli(response.data);
    return result;
  }

  Future<Poli> hapus(Poli poli) async {
    final String? id = poli.id;
    if (id == null || id.isEmpty) {
      throw Exception('Data poli tidak punya id, tidak bisa dihapus.');
    }
    final Response response = await ApiClient().delete('poli/$id');
    Poli result = _kePoli(response.data);
    return result;
  }

  // mockapi.io bisa menjawab dengan string (mis. pesan error) atau Map dengan
  // key dinamis, jadi bentuknya diperiksa dulu sebelum dipetakan ke Poli.
  Poli _kePoli(dynamic json) {
    if (json is! Map) {
      throw Exception('Format data poli dari server tidak sesuai.');
    }
    return Poli.fromJson(Map<String, dynamic>.from(json));
  }
}
