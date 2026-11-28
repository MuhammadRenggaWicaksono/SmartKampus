import 'package:app_kampus/lms/models/moodle_course.dart';

/// Sekumpulan mata kuliah dalam satu semester — satu tab di beranda LMS.
class CourseGroup {
  const CourseGroup({required this.label, required this.courses});

  final String label;
  final List<MoodleCourse> courses;
}

/// Semester dari sebuah mata kuliah.
///
/// Di Moodle kampus ini `shortname` cuma kode angka polos (mis. "35303"),
/// sedangkan kode kelas yang memuat semester ada di dalam tanda kurung pada
/// `fullname` — contoh: `BAHASA INGGRIS BISNIS (IFB4B)` → Semester 4.
/// Urutan sumber yang dicoba: kode dalam kurung → `shortname` → `fullname`.
/// `null` kalau tidak ada angka yang masuk akal.
int? semesterOfCourse(MoodleCourse course) {
  for (final sumber in <String>[
    _kodeDalamKurung(course.fullName),
    course.shortName,
    course.fullName,
  ]) {
    final nilai = _angkaSemester(sumber);
    if (nilai != null) return nilai;
  }
  return null;
}

/// Isi tanda kurung pertama pada nama mata kuliah, mis. "(IFB4B)" → "IFB4B".
String _kodeDalamKurung(String teks) {
  final cocok = RegExp(r'\(([^)]+)\)').firstMatch(teks);
  return cocok?.group(1) ?? '';
}

int? _angkaSemester(String teks) {
  final cocok = RegExp(r'\d+').firstMatch(teks);
  if (cocok == null) return null;

  final nilai = int.tryParse(cocok.group(0)!);
  if (nilai == null || nilai < 1 || nilai > 8) return null;
  return nilai;
}

/// Kelompokkan mata kuliah per semester, urut **turun** (semester terbaru di
/// kiri supaya semester aktif langsung terlihat). Mata kuliah tanpa kode
/// semester yang jelas masuk ke kelompok "Lainnya" di paling akhir.
List<CourseGroup> groupCoursesBySemester(List<MoodleCourse> courses) {
  final peta = <int?, List<MoodleCourse>>{};
  for (final course in courses) {
    peta
        .putIfAbsent(semesterOfCourse(course), () => <MoodleCourse>[])
        .add(course);
  }

  final kunci = peta.keys.toList()
    ..sort((a, b) {
      if (a == null) return 1;
      if (b == null) return -1;
      return b.compareTo(a);
    });

  return [
    for (final k in kunci)
      CourseGroup(
        label: k == null ? 'Lainnya' : 'Semester $k',
        courses: peta[k]!
          ..sort((a, b) => a.shortName.compareTo(b.shortName)),
      ),
  ];
}
