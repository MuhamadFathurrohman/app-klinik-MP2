class Pegawai {
  String? id;
  String nip;
  String nama;
  String tanggalLahir;
  String nomorTelepon;
  String email;
  String password;

  Pegawai({
    this.id,
    required this.nip,
    required this.nama,
    required this.tanggalLahir,
    required this.nomorTelepon,
    required this.email,
    required this.password,
  });

  // mockapi.io bisa mengirim id berupa angka maupun string, dan field yang
  // belum diisi bisa bernilai null, jadi semuanya dinormalkan di sini.
  factory Pegawai.fromJson(Map<String, dynamic> json) => Pegawai(
        id: json["id"]?.toString(),
        nip: (json["nip"] ?? "").toString(),
        nama: (json["nama"] ?? "").toString(),
        tanggalLahir: _keTanggal(json["tanggal_lahir"]),
        nomorTelepon: (json["nomor_telepon"] ?? "").toString(),
        email: (json["email"] ?? "").toString(),
        password: (json["password"] ?? "").toString(),
      );

  Map<String, dynamic> toJson() => {
        "nip": nip,
        "nama": nama,
        "tanggal_lahir": tanggalLahir,
        "nomor_telepon": nomorTelepon,
        "email": email,
        "password": password,
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
