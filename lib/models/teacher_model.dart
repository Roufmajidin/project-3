class TeacherData {
  final String email;
  final String id;
  final String mapel;
  final String nama;
  final List<Mengajar> mengajar;

  TeacherData({
    required this.email,
    required this.id,
    required this.mapel,
    required this.nama,
    required this.mengajar,
  });

  factory TeacherData.fromJson(Map<String, dynamic> json) {
    return TeacherData(
      email: json['email'],
      id: json['id'],
      mapel: json['mapel'],
      nama: json['nama'],
      mengajar: _parseMengajar(json['mengajar']),
    );
  }

  static List<Mengajar> _parseMengajar(dynamic mengajarJson) {
    if (mengajarJson is Map) {
      return mengajarJson.entries
          .where((entry) => entry.value is Map)
          .map((entry) => Mengajar.fromJson(Map<String, dynamic>.from(entry.value)))
          .toList();
    } else {
      return [];
    }
  }
}

class Mengajar {
  final String kelas;
  final String hari;
  final String waktu;
  final String? keterangan; // Optional field for non-KBM
  final String? jenis; // Optional field for non-KBM events
  final String? tanggal; // Optional field for non-KBM events

  Mengajar({
    required this.kelas,
    required this.hari,
    required this.waktu,
    this.keterangan,
    this.jenis,
    this.tanggal,
  });

  factory Mengajar.fromJson(Map<String, dynamic> json) {
    // Check for teaching schedules or non-teaching events
    if (json.containsKey('jenis') && json['jenis'] != null) {
      // Non-teaching event (e.g., Non-KBM)
      return Mengajar(
        kelas: json['kelas'] ?? '-', // Default if missing
        hari: json['hari'] ?? 'Unknown', // Default if missing
        waktu: json['waktu'] ?? '00:00', // Default if missing
        keterangan: json['keterangan'],
        jenis: json['jenis'],
        tanggal: json['tanggal'],
      );
    } else {
      // Regular teaching schedule
      return Mengajar(
        kelas: json['kelas'] ?? '-', // Default if missing
        hari: json['hari'] ?? 'Unknown', // Default if missing
        waktu: json['waktu'] ?? '00:00', // Default if missing
      );
    }
  }
}
