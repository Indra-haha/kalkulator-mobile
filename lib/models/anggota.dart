class Anggota {
  final String nim;
  final String nama;
  final String kelas;

  const Anggota({required this.nim, required this.nama, required this.kelas});

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      nim: json['nim'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      kelas: json['kelas'] as String? ?? '',
    );
  }
}