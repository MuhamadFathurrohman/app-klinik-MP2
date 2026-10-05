class Pasien {
  String? id;
  String nomorRm;
  String nama;
  String tanggalLahir;
  String nomorTelepon;
  String alamat;

  Pasien({
    this.id,
    required this.nomorRm,
    required this.nama,
    required this.tanggalLahir,
    required this.nomorTelepon,
    required this.alamat,
  });

  // mockapi.io bisa mengirim id berupa angka maupun string, dan field yang
  // belum diisi bisa bernilai null, jadi semuanya dinormalkan di sini.
  factory Pasien.fromJson(Map<String, dynamic> json) => Pasien(
        id: json["id"]?.toString(),
        nomorRm: (json["nomor_rm"] ?? "").toString(),
        nama: (json["nama"] ?? "").toString(),
        tanggalLahir: _keTanggal(json["tanggal_lahir"]),
        nomorTelepon: (json["nomor_telepon"] ?? "").toString(),
        alamat: (json["alamat"] ?? "").toString(),
      );

  Map<String, dynamic> toJson() => {
        "nomor_rm": nomorRm,
        "nama": nama,
        "tanggal_lahir": tanggalLahir,
        "nomor_telepon": nomorTelepon,
        "alamat": alamat,
      };
}

// Resource mockapi bertipe Date mengirim tanggal lengkap seperti
// "2001-05-17T00:00:00.000Z", sedangkan aplikasi memakai format yyyy-MM-dd.
String _keTanggal(dynamic nilai) {
  if (nilai == null) return '';
  final String teks = nilai.toString();
  final DateTime? tanggal = DateTime.tryParse(teks);
  if (tanggal == null) return teks;
  return "${tanggal.year.toString().padLeft(4, '0')}-"
      "${tanggal.month.toString().padLeft(2, '0')}-"
      "${tanggal.day.toString().padLeft(2, '0')}";
}
