/// Kuis mata kuliah — hasil `mod_quiz_get_quizzes_by_courses`.
///
/// Kuis adalah tipe aktivitas yang **berbeda** dari tugas (`mod_assign`).
/// Dosen sering memakai kuis untuk "Uji Ketuntasan CPMK", jadi jangan
/// menganggap semua pekerjaan mahasiswa muncul di daftar tugas.
class MoodleQuiz {
  const MoodleQuiz({
    required this.id,
    required this.courseId,
    required this.moduleId,
    required this.nama,
    required this.intro,
    required this.buka,
    required this.tutup,
    required this.batasWaktu,
    required this.jumlahPercobaan,
    required this.nilaiMaks,
  });

  /// Id kuis (`id`) — dipakai untuk memanggil nilai.
  final int id;

  final int courseId;

  /// `coursemodule` — id modul di mata kuliah, dipakai untuk URL
  /// `/mod/quiz/view.php?id=<moduleId>`.
  final int moduleId;

  final String nama;

  /// HTML mentah dari Moodle. Bersihkan dengan `bersihkanHtml()`.
  final String intro;

  /// Epoch detik kapan kuis dibuka / ditutup.
  final int? buka;
  final int? tutup;

  /// Batas waktu pengerjaan dalam detik. `0` = tanpa batas.
  final int batasWaktu;

  /// Berapa kali boleh dikerjakan. `0` = tak terbatas.
  final int jumlahPercobaan;

  /// Nilai maksimal kuis.
  final double nilaiMaks;

  bool get terbatasWaktu => batasWaktu > 0;

  String get labelBatasWaktu {
    if (batasWaktu <= 0) return 'Tanpa batas waktu';
    final menit = batasWaktu ~/ 60;
    if (menit < 60) return '$menit menit';
    final jam = menit ~/ 60;
    final sisa = menit % 60;
    return sisa == 0 ? '$jam jam' : '$jam jam $sisa menit';
  }

  String get labelPercobaan => jumlahPercobaan <= 0
      ? 'Tanpa batas percobaan'
      : '$jumlahPercobaan percobaan';

  factory MoodleQuiz.fromJson(Map<String, dynamic> json) {
    return MoodleQuiz(
      id: (json['id'] as num?)?.toInt() ?? 0,
      courseId: (json['course'] as num?)?.toInt() ?? 0,
      moduleId: (json['coursemodule'] as num?)?.toInt() ?? 0,
      nama: (json['name'] as String?) ?? '',
      intro: (json['intro'] as String?) ?? '',
      buka: _epoch(json['timeopen']),
      tutup: _epoch(json['timeclose']),
      batasWaktu: (json['timelimit'] as num?)?.toInt() ?? 0,
      jumlahPercobaan: (json['attempts'] as num?)?.toInt() ?? 0,
      nilaiMaks: _angka(json['grade'])?.toDouble() ?? 0,
    );
  }
}

/// Kuis + nilai akhir milik pengguna yang sedang login.
///
/// [nilai] `null` = belum ada nilai (belum dikerjakan atau belum dinilai).
class KuisRingkas {
  const KuisRingkas({required this.kuis, required this.nilai});

  final MoodleQuiz kuis;
  final double? nilai;

  bool get sudahAdaNilai => nilai != null;
}

int? _epoch(dynamic nilai) {
  final angka = (nilai as num?)?.toInt();
  if (angka == null || angka <= 0) return null;
  return angka;
}

/// Moodle kadang mengirim angka sebagai `num`, kadang sebagai `String`.
num? _angka(dynamic nilai) {
  if (nilai is num) return nilai;
  if (nilai is String) return num.tryParse(nilai);
  return null;
}