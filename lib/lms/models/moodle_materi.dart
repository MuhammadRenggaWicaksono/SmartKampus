/// Materi & modul mata kuliah — hasil `core_course_get_contents`.
///
/// Moodle mengirim daftar *section* (pertemuan/topik). Tiap section berisi
/// *module* (resource, url, folder, forum, quiz, assign, ...). Tiap module bisa
/// punya beberapa *file*.
library;

/// Satu berkas di dalam module.
class ModuleFile {
  const ModuleFile({
    required this.nama,
    required this.url,
    required this.ukuran,
    required this.mimetype,
  });

  final String nama;

  /// URL `pluginfile.php` — belum ada token. Pakai `withToken()` saat dibuka.
  final String url;
  final int ukuran;
  final String mimetype;

  bool get pdf => mimetype.contains('pdf') || nama.toLowerCase().endsWith('.pdf');

  factory ModuleFile.fromJson(Map<String, dynamic> json) => ModuleFile(
    nama: (json['filename'] as String?) ?? '',
    url: (json['fileurl'] as String?) ?? '',
    ukuran: (json['filesize'] as num?)?.toInt() ?? 0,
    mimetype: (json['mimetype'] as String?) ?? '',
  );
}

/// Satu aktivitas/sumber belajar (resource, url, quiz, forum, assign, ...).
class CourseModule {
  const CourseModule({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.url,
    required this.deskripsi,
    required this.berkas,
  });

  final int id;
  final String nama;

  /// `modname` Moodle: resource, url, folder, assign, forum, quiz, label, ...
  final String jenis;

  /// Tautan langsung (untuk `url`, `quiz`, `assign`, dst). Bisa kosong.
  final String url;

  /// HTML mentah dari Moodle. Bersihkan dengan `bersihkanHtml()`.
  final String deskripsi;
  final List<ModuleFile> berkas;

  bool get adaBerkas => berkas.isNotEmpty;

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    final isi = json['contents'];
    return CourseModule(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nama: (json['name'] as String?) ?? '',
      jenis: (json['modname'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      deskripsi: (json['description'] as String?) ?? '',
      berkas: isi is List
          ? isi
                .whereType<Map>()
                .map((e) => ModuleFile.fromJson(e.cast<String, dynamic>()))
                .toList(growable: false)
          : const <ModuleFile>[],
    );
  }
}

/// Satu pertemuan/topik dalam mata kuliah.
class CourseSection {
  const CourseSection({
    required this.id,
    required this.nama,
    required this.ringkasan,
    required this.modules,
  });

  final int id;
  final String nama;

  /// HTML mentah dari Moodle. Bersihkan dengan `bersihkanHtml()`.
  final String ringkasan;
  final List<CourseModule> modules;

  bool get kosong => modules.isEmpty;

  /// Salinan section tanpa modul bertipe [jenis].
  ///
  /// Dipakai supaya tab Materi tidak lagi menampilkan aktivitas yang sudah
  /// punya tab sendiri (tugas, kuis, forum) — itu sumber kebingungan
  /// "tugasnya kok ada di materi".
  CourseSection tanpaJenis(Set<String> jenis) {
    final sisa = modules
        .where((m) => !jenis.contains(m.jenis))
        .toList(growable: false);
    if (sisa.length == modules.length) return this;
    return CourseSection(
      id: id,
      nama: nama,
      ringkasan: ringkasan,
      modules: sisa,
    );
  }

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    final isi = json['modules'];
    return CourseSection(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nama: (json['name'] as String?) ?? '',
      ringkasan: (json['summary'] as String?) ?? '',
      modules: isi is List
          ? isi
                .whereType<Map>()
                .map((e) => CourseModule.fromJson(e.cast<String, dynamic>()))
                .toList(growable: false)
          : const <CourseModule>[],
    );
  }
}