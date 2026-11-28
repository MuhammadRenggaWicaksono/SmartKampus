/// Status pengumpulan satu tugas —
/// hasil `mod_assign_get_submission_status`.
///
/// Bentuk response Moodle:
/// ```json
/// {
///   "lastattempt": {
///     "submission": {"status": "draft", "timemodified": 1700000000},
///     "canedit": true, "graded": false, "locked": false
///   },
///   "gradingsummary": {"grade": 85},
///   "feedback": {"grade": {"grade": "85 / 100"}}
/// }
/// ```
class MoodleSubmission {
  const MoodleSubmission({
    required this.adaPercobaan,
    required this.status,
    required this.dapatDiubah,
    required this.sudahDinilai,
    required this.terkunci,
    required this.diubahPada,
    required this.nilai,
    required this.berkas,
  });

  /// Status kosong — dipakai sebelum data pertama datang.
  static const MoodleSubmission kosong = MoodleSubmission(
    adaPercobaan: false,
    status: 'new',
    dapatDiubah: true,
    sudahDinilai: false,
    terkunci: false,
    diubahPada: null,
    nilai: null,
    berkas: <SubmissionFile>[],
  );

  /// false = mahasiswa belum pernah menyentuh tugas ini.
  final bool adaPercobaan;

  /// `new` | `draft` | `submitted` | `reopened`.
  final String status;

  /// Moodle masih mengizinkan perubahan (belum lewat batas / belum dinilai).
  final bool dapatDiubah;

  /// Sudah ada nilai dari dosen.
  final bool sudahDinilai;

  /// Pengumpulan ditutup.
  final bool terkunci;

  /// Kapan pengumpulan terakhir diubah (epoch detik).
  final int? diubahPada;

  /// Nilai dari `gradingsummary`.
  final double? nilai;

  /// Berkas yang sudah ada di area pengumpulan.
  final List<SubmissionFile> berkas;

  bool get sudahDikumpul => status == 'submitted' || status == 'reopened';
  bool get masihDraf => status == 'draft';

  /// Label status siap tampil.
  String get labelStatus {
    if (sudahDinilai) return 'Sudah dinilai';
    switch (status) {
      case 'submitted':
        return 'Sudah dikumpulkan';
      case 'draft':
        return 'Draf tersimpan';
      case 'reopened':
        return 'Dibuka ulang untuk perbaikan';
      default:
        return 'Belum dikumpulkan';
    }
  }

  factory MoodleSubmission.fromJson(Map<String, dynamic> json) {
    final last = _map(json['lastattempt']);
    final sub = _map(last['submission']);
    final ringkas = _map(json['gradingsummary']);
    final nilai = ringkas['grade'];

    return MoodleSubmission(
      adaPercobaan: sub.isNotEmpty,
      status: (sub['status'] as String?) ?? 'new',
      dapatDiubah: last['canedit'] == true,
      sudahDinilai: last['graded'] == true,
      terkunci: last['locked'] == true,
      diubahPada: _epoch(sub['timemodified']),
      nilai: nilai is num ? nilai.toDouble() : null,
      berkas: _berkasDari(sub),
    );
  }
}

/// Satu berkas yang sudah berada di area pengumpulan.
class SubmissionFile {
  const SubmissionFile({
    required this.nama,
    required this.url,
    required this.ukuran,
    required this.mimetype,
  });

  final String nama;
  final String url;
  final int ukuran;
  final String mimetype;

  factory SubmissionFile.fromJson(Map<String, dynamic> json) {
    return SubmissionFile(
      nama: (json['filename'] as String?) ?? '',
      url: (json['fileurl'] as String?) ?? '',
      ukuran: (json['filesize'] as num?)?.toInt() ?? 0,
      mimetype: (json['mimetype'] as String?) ?? '',
    );
  }
}

/// Hasil unggahan ke `/webservice/upload.php`.
class UploadResult {
  const UploadResult({
    required this.itemId,
    required this.nama,
    required this.url,
    required this.ukuran,
  });

  /// `itemid` area draf — dipakai lagi untuk berkas berikutnya, lalu
  /// dikirim ke `mod_assign_save_submission`.
  final int itemId;
  final String nama;
  final String url;
  final int ukuran;

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      itemId: (json['itemid'] as num?)?.toInt() ?? 0,
      nama: (json['filename'] as String?) ?? '',
      url: (json['fileurl'] as String?) ?? '',
      ukuran: (json['filesize'] as num?)?.toInt() ?? 0,
    );
  }
}

List<SubmissionFile> _berkasDari(Map<String, dynamic> sub) {
  final plugins = sub['plugins'];
  if (plugins is! List) return const <SubmissionFile>[];

  final hasil = <SubmissionFile>[];
  for (final plugin in plugins) {
    final areas = _map(plugin)['fileareas'];
    if (areas is! List) continue;
    for (final area in areas) {
      final berkas = _map(area)['files'];
      if (berkas is! List) continue;
      for (final f in berkas) {
        final map = _map(f);
        if (map.isEmpty) continue;
        hasil.add(SubmissionFile.fromJson(map));
      }
    }
  }
  return hasil;
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? value.cast<String, dynamic>() : <String, dynamic>{};

int? _epoch(dynamic nilai) {
  final angka = (nilai as num?)?.toInt();
  if (angka == null || angka <= 0) return null;
  return angka;
}