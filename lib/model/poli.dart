class Poli {
  String? id;
  String namaPoli;

  Poli({this.id, required this.namaPoli});

  // mockapi.io bisa mengirim id berupa angka maupun string, dan nama_poli bisa
  // null kalau record dibuat tanpa field itu, jadi semuanya dinormalkan di sini.
  factory Poli.fromJson(Map<String, dynamic> json) => Poli(
        id: json["id"]?.toString(),
        namaPoli: json["nama_poli"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {"nama_poli": namaPoli};
}
