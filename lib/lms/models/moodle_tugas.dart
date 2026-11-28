/// Tugas mata kuliah — hasil `mod_assign_get_assignments`.
///
/// Bentuk response Moodle: `{"courses": [{"id": 3, "assignments": [...]}]}`.
/// `fromJson` di sini menerima satu entri dari `assignments`.
class Assignment {
  const Assignment({
    required this.id,
    required this.courseId,
    required this.nama,
    required this.intro,
    required this.tenggat,
    required this.buka,
    required this.batasAkhir,
    required this.nilaiMaks,
    required this.unggahBerkas,
    required this.bolehTerlambat,
  });

  final int id;
  final int courseId;
  final String nama;

  /// HTML mentah dari Moodle. Bersihkan dengan `bersihkanHtml()`.
  final String intro;

  /// Unix epoch (detik) atau `null` kalau tidak ada tenggat.
  final int? tenggat;

  /// Kapan pengumpulan dibuka (epoch detik).
  final int? buka;

  /// Batas akhir setelah tenggat (epoch detik).
  final int? batasAkhir;
  final double nilaiMaks;

  /// true kalau tugas menerima unggahan berkas (dipakai di Tahap 3).
  final bool unggahBerkas;

  /// true kalau pengumpulan setelah tenggat masih diterima.
  final bool bolehTerlambat;

  factory Assignment.fromJson(Map<String, dynamic> json) {
    final plugin = json['configs'];
    return Assignment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      courseId: (json['course'] as num?)?.toInt() ?? 0,
      nama: (json['name'] as String?) ?? '',
      intro: (json['intro'] as String?) ?? '',
      tenggat: _epoch(json['duedate']),
      buka: _epoch(json['allowsubmissionsfromdate']),
      batasAkhir: _epoch(json['cutoffdate']),
      nilaiMaks: (json['grade'] as num?)?.toDouble() ?? 0,
      unggahBerkas: _adaUnggahan(plugin),
      bolehTerlambat: (json['cutoffdate'] as num?)?.toInt() == null ||
          json['cutoffdate'] == 0,
    );
  }
}

bool _adaUnggahan(dynamic configs) {
  if (configs is! List) return true; // default Moodle: tugas berbasis berkas
  for (final item in configs) {
    if (item is Map &&
        item['plugin'] == 'file' &&
        item['subtype'] == 'assignsubmission' &&
        item['name'] == 'enabled' &&
        item['value'] == 1) {
      return true;
    }
  }
  return false;
}

int? _epoch(dynamic nilai) {
  final angka = (nilai as num?)?.toInt();
  if (angka == null || angka <= 0) return null;
  return angka;
}