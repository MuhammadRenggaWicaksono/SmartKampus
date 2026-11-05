// ============================================================================
// SUMBER DATA TUNGGAL (single source of truth) UNTUK SELURUH APLIKASI
// ============================================================================
// Sebelumnya setiap layar menyimpan data dummy-nya sendiri, jadi nama
// mahasiswa, jadwal, dan jumlah SKS bisa berbeda antar halaman
// (Dashboard bilang "Muhammad", halaman Akun bilang "Rengga", jadwal
// Dashboard tidak ada di halaman Jadwal Kuliah, dll).
//
// Sekarang semuanya di sini. Ketika API kampus siap, cukup ganti isi file ini.

/// Target SKS kelulusan program studi.
const int kSksTargetLulus = 144;

/// Kampus memakai 16 kali tatap muka per mata kuliah per semester.
const int kRencanaTatapMuka = 16;

/// Satu sesi kuliah pada jadwal mingguan.
class KelasKuliah {
  /// Format "08:00 - 10:30".
  final String jam;
  final String kode;
  final String nama;
  final int sks;
  final String ruang;
  final String dosen;
  final bool adaLink;

  const KelasKuliah({
    required this.jam,
    required this.kode,
    required this.nama,
    required this.sks,
    required this.ruang,
    required this.dosen,
    this.adaLink = false,
  });

  static int _menit(String hhmm) {
    final bagian = hhmm.trim().split(':');
    return int.parse(bagian[0]) * 60 + int.parse(bagian[1]);
  }

  String get jamMulai => jam.split('-').first.trim();
  String get jamSelesai => jam.split('-').last.trim();
  int get menitMulai => _menit(jamMulai);
  int get menitSelesai => _menit(jamSelesai);

  /// true kalau [sekarang] berada di antara jam mulai dan selesai.
  bool sedangBerjalan(DateTime sekarang) {
    final kini = sekarang.hour * 60 + sekarang.minute;
    return kini >= menitMulai && kini < menitSelesai;
  }

  /// true kalau kelas belum dimulai.
  bool belumMulai(DateTime sekarang) {
    final kini = sekarang.hour * 60 + sekarang.minute;
    return kini < menitMulai;
  }
}

/// Jadwal satu hari (dipakai kartu "Jadwal Hari Ini" di Dashboard).
class JadwalHari {
  final String hari;
  final bool hariIni;
  final List<KelasKuliah> kelas;

  const JadwalHari({
    required this.hari,
    required this.hariIni,
    required this.kelas,
  });

  bool get kosong => kelas.isEmpty;
  int get totalSks => kelas.fold(0, (total, k) => total + k.sks);

  int get jumlahMk => kelas.length;
}

/// Riwayat Indeks Prestasi Semester.
class IpsSemester {
  final int semester;
  final String tahunAkademik;
  final String jenis;

  /// null = nilai semester ini belum dirilis kampus.
  final double? ips;

  const IpsSemester({
    required this.semester,
    required this.tahunAkademik,
    required this.jenis,
    this.ips,
  });

  bool get sudahAdaNilai => ips != null;
}

/// Mata kuliah yang sedang ditempuh semester ini, lengkap dengan rekap
/// presensi. Dipakai oleh grafik "Tatap Muka", grafik "Absensi",
/// dan halaman Presensi.
class MataKuliahAktif {
  final String kode;
  final String nama;
  final String kelas;
  final int sks;

  final int hadir;
  final int sakit;
  final int izin;
  final int alpa;

  const MataKuliahAktif({
    required this.kode,
    required this.nama,
    required this.kelas,
    required this.sks,
    required this.hadir,
    required this.sakit,
    required this.izin,
    required this.alpa,
  });

  /// Pertemuan yang sudah terlaksana (hadir + sakit + izin + alpa).
  int get terlaksana => hadir + sakit + izin + alpa;

  /// 0.0 - 1.0 terhadap rencana 16 pertemuan.
  double get rasioTerlaksana => terlaksana / kRencanaTatapMuka;

  /// Persentase kehadiran dari pertemuan yang sudah terlaksana.
  int get persenHadir =>
      terlaksana == 0 ? 0 : ((hadir / terlaksana) * 100).round();

  /// Persentase kehadiran terhadap 16 pertemuan (dipakai buat warning 75%).
  int get persenTerhadapRencana =>
      ((hadir / kRencanaTatapMuka) * 100).round();

  int get totalAbsen => sakit + izin + alpa;
}

/// Pusat data aplikasi.
class AppData {
  AppData._();

  // ------------------------------------------------------------ identitas
  static const String nama = 'Muhammad Rengga Wicaksono';
  static const String namaPanggilan = 'Rengga';
  static const String nim = '2411044';
  static const String programStudi = 'S1 Informatika';
  static const String fakultas = 'Fakultas Ilmu Komputer';
  static const String semesterAktif = 'Semester Ganjil 2026/2027';
  static const String semesterAktifSingkat = 'Ganjil 2026/2027';
  static const String statusMahasiswa = 'Mahasiswa Aktif';
  static const String statusTagihan = 'Lunas';
  static const String sisaTagihan = 'Rp 0';

  /// Inisial untuk avatar (tanpa foto profil).
  static String get inisial {
    final bagian = nama.split(' ').where((k) => k.isNotEmpty).toList();
    if (bagian.isEmpty) return '?';
    if (bagian.length == 1) return bagian.first.substring(0, 1).toUpperCase();
    return (bagian[0].substring(0, 1) + bagian[1].substring(0, 1))
        .toUpperCase();
  }

  static const List<String> namaHari = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  // ---------------------------------------------------- jadwal mingguan
  static const Map<String, List<KelasKuliah>> jadwalMingguan =
      <String, List<KelasKuliah>>{
    'Senin': <KelasKuliah>[
      KelasKuliah(
        jam: '08:00 - 10:30',
        kode: '111500',
        nama: 'SISTEM MANAJEMEN BASIS DATA',
        sks: 3,
        ruang: 'LAB D (FIKOM)',
        dosen: 'NASRUDDIN BIN IDRIS, S.Kom., M.Kom.',
        adaLink: true,
      ),
      KelasKuliah(
        jam: '10:30 - 13:00',
        kode: '111400',
        nama: 'SIMULASI DAN GAME KOMPUTER',
        sks: 3,
        ruang: 'LAB A (FIKOM)',
        dosen: 'HERUZULKIFLI ROWA, S.Kom, M.Kom',
      ),
      KelasKuliah(
        jam: '13:00 - 15:30',
        kode: '111600',
        nama: 'TEKNOLOGI APLIKASI BERGERAK',
        sks: 3,
        ruang: 'LAB B (FIKOM)',
        dosen: 'ISTIA BUDI, S.T., M.M.',
      ),
    ],
    'Selasa': <KelasKuliah>[
      KelasKuliah(
        jam: '13:00 - 15:30',
        kode: '111100',
        nama: 'PENALARAN KOMPUTER',
        sks: 3,
        ruang: 'A201',
        dosen: 'ISA ROSITA, S.Kom., M.Cs.',
      ),
    ],
    'Rabu': <KelasKuliah>[
      KelasKuliah(
        jam: '19:00 - 20:30',
        kode: '111300',
        nama: 'ROBOTIKA',
        sks: 3,
        ruang: 'LAB ROBOTIK (FIKOM)',
        dosen: "MUHAMMAD SAFI'I, S.Kom., M.Kom.",
      ),
    ],
    'Kamis': <KelasKuliah>[
      KelasKuliah(
        jam: '08:00 - 10:30',
        kode: '110600',
        nama: 'JARINGAN NIRKABEL',
        sks: 3,
        ruang: 'LAB JARINGAN (FIKOM)',
        dosen: 'WISNU HERA PAMUNGKAS, S.T.P., M.Eng',
      ),
      KelasKuliah(
        jam: '13:00 - 15:30',
        kode: '111000',
        nama: 'PEMROGRAMAN APLIKASI BERGERAK',
        sks: 3,
        ruang: 'LAB A (FIKOM)',
        dosen: 'PRAMUDYA PRIMA INSAN, S.Kom., M.Kom.',
      ),
    ],
    'Jumat': <KelasKuliah>[
      KelasKuliah(
        jam: '08:00 - 09:40',
        kode: '000800',
        nama: 'PENULISAN DAN PUBLIKASI ILMIAH',
        sks: 2,
        ruang: 'A202',
        dosen: 'YUSUF WIBISONO, S.E., M.T.I.',
        adaLink: true,
      ),
    ],
  };

  // ------------------------------------------- mata kuliah semester ini
  // 8 mata kuliah, total 23 SKS — sama persis dengan KRS 2026/2027 Ganjil.
  static const List<MataKuliahAktif> mataKuliahAktif = <MataKuliahAktif>[
    MataKuliahAktif(
      kode: '111500',
      nama: 'SISTEM MANAJEMEN BASIS DATA',
      kelas: 'IFB5A',
      sks: 3,
      hadir: 9,
      sakit: 1,
      izin: 0,
      alpa: 0,
    ),
    MataKuliahAktif(
      kode: '111400',
      nama: 'SIMULASI DAN GAME KOMPUTER',
      kelas: 'IFB5A',
      sks: 3,
      hadir: 8,
      sakit: 0,
      izin: 1,
      alpa: 0,
    ),
    MataKuliahAktif(
      kode: '111600',
      nama: 'TEKNOLOGI APLIKASI BERGERAK',
      kelas: 'IFB5A',
      sks: 3,
      hadir: 10,
      sakit: 0,
      izin: 0,
      alpa: 0,
    ),
    MataKuliahAktif(
      kode: '111100',
      nama: 'PENALARAN KOMPUTER',
      kelas: 'IFB5A',
      sks: 3,
      hadir: 7,
      sakit: 0,
      izin: 1,
      alpa: 1,
    ),
    MataKuliahAktif(
      kode: '111300',
      nama: 'ROBOTIKA',
      kelas: 'IFB5J',
      sks: 3,
      hadir: 8,
      sakit: 0,
      izin: 0,
      alpa: 0,
    ),
    MataKuliahAktif(
      kode: '110600',
      nama: 'JARINGAN NIRKABEL',
      kelas: 'IFB5A',
      sks: 3,
      hadir: 9,
      sakit: 1,
      izin: 0,
      alpa: 0,
    ),
    MataKuliahAktif(
      kode: '111000',
      nama: 'PEMROGRAMAN APLIKASI BERGERAK',
      kelas: 'IFB5A',
      sks: 3,
      hadir: 10,
      sakit: 0,
      izin: 0,
      alpa: 0,
    ),
    MataKuliahAktif(
      kode: '000800',
      nama: 'PENULISAN DAN PUBLIKASI ILMIAH',
      kelas: 'IFB5A',
      sks: 2,
      hadir: 8,
      sakit: 0,
      izin: 1,
      alpa: 0,
    ),
  ];

  // ------------------------------------------------------ riwayat IPS
  // Semester 5 (yang sedang berjalan) belum punya nilai, begitu juga 6-8.
  static const List<IpsSemester> riwayatIps = <IpsSemester>[
    IpsSemester(
      semester: 1,
      tahunAkademik: '2024/2025',
      jenis: 'Ganjil',
      ips: 3.68,
    ),
    IpsSemester(
      semester: 2,
      tahunAkademik: '2024/2025',
      jenis: 'Genap',
      ips: 3.70,
    ),
    IpsSemester(
      semester: 3,
      tahunAkademik: '2025/2026',
      jenis: 'Ganjil',
      ips: 3.58,
    ),
    IpsSemester(
      semester: 4,
      tahunAkademik: '2025/2026',
      jenis: 'Genap',
      ips: 3.76,
    ),
    IpsSemester(
      semester: 5,
      tahunAkademik: '2026/2027',
      jenis: 'Ganjil',
    ),
    IpsSemester(
      semester: 6,
      tahunAkademik: '2026/2027',
      jenis: 'Genap',
    ),
    IpsSemester(
      semester: 7,
      tahunAkademik: '2027/2028',
      jenis: 'Ganjil',
    ),
    IpsSemester(
      semester: 8,
      tahunAkademik: '2027/2028',
      jenis: 'Genap',
    ),
  ];

  /// IPS minimal yang ditargetkan.
  static const double targetIps = 3.50;

  // ----------------------------------------------- perhitungan SKS
  /// SKS yang diambil tiap semester (indeks 0 = semester 1).
  static const List<int> sksPerSemester = <int>[23, 24, 23, 23, 23];

  /// SKS semester ini (dihitung dari daftar mata kuliah, jadi selalu sinkron).
  static int get sksSemesterIni =>
      mataKuliahAktif.fold(0, (total, mk) => total + mk.sks);

  /// Total SKS yang sudah ditempuh sampai semester ini.
  static int get sksDitempuh =>
      sksPerSemester.fold(0, (total, sks) => total + sks);

  /// SKS yang sudah selesai dinilai (tanpa semester berjalan).
  static int get sksSelesai => sksDitempuh - sksSemesterIni;

  /// Sisa SKS menuju kelulusan.
  static int get sksSisa => kSksTargetLulus - sksDitempuh;

  /// 0.0 - 1.0 terhadap target kelulusan.
  static double get rasioSks => sksDitempuh / kSksTargetLulus;

  /// Label kartu dashboard: "116 / 144".
  static String get labelSksTotal => '$sksDitempuh / $kSksTargetLulus';

  /// IPK kumulatif (rata-rata berbobot SKS, hanya semester yang sudah dinilai).
  static double get ipk {
    var bobot = 0.0;
    var sks = 0;
    for (var i = 0; i < riwayatIps.length; i++) {
      final nilai = riwayatIps[i].ips;
      if (nilai == null || i >= sksPerSemester.length) continue;
      bobot += nilai * sksPerSemester[i];
      sks += sksPerSemester[i];
    }
    if (sks == 0) return 0;
    return double.parse((bobot / sks).toStringAsFixed(2));
  }

  // --------------------------------------------- rekap pertemuan & absen
  static int get totalPertemuanTerlaksana =>
      mataKuliahAktif.fold(0, (total, mk) => total + mk.terlaksana);

  static int get totalPertemuanRencana =>
      mataKuliahAktif.length * kRencanaTatapMuka;

  static int get totalHadir =>
      mataKuliahAktif.fold(0, (total, mk) => total + mk.hadir);

  static int get totalSakit =>
      mataKuliahAktif.fold(0, (total, mk) => total + mk.sakit);

  static int get totalIzin =>
      mataKuliahAktif.fold(0, (total, mk) => total + mk.izin);

  static int get totalAlpa =>
      mataKuliahAktif.fold(0, (total, mk) => total + mk.alpa);

  /// Total ketidakhadiran (sakit + izin + alpa).
  static int get totalAbsen => totalSakit + totalIzin + totalAlpa;

  static int get persenKehadiran => totalPertemuanTerlaksana == 0
      ? 0
      : ((totalHadir / totalPertemuanTerlaksana) * 100).round();

  /// Mata kuliah yang kehadirannya di bawah 75% dari rencana 16 pertemuan.
  static List<MataKuliahAktif> get mataKuliahRawanKehadiran =>
      mataKuliahAktif.where((mk) => mk.persenTerhadapRencana < 75).toList();

  // ------------------------------------------------------------- helper
  static String namaHariDari(DateTime tanggal) =>
      namaHari[tanggal.weekday - 1];

  /// Kelas hari ini. Kalau hari ini tidak ada kelas, ambil hari terdekat
  /// berikutnya yang ada kelas supaya dashboard tidak tampak kosong.
  static JadwalHari jadwalTerdekat([DateTime? sekarang]) {
    final now = sekarang ?? DateTime.now();
    final hariIni = namaHariDari(now);

    final kelasHariIni = jadwalMingguan[hariIni] ?? const <KelasKuliah>[];
    if (kelasHariIni.isNotEmpty) {
      return JadwalHari(hari: hariIni, hariIni: true, kelas: kelasHariIni);
    }

    for (var langkah = 1; langkah <= 7; langkah++) {
      final indeks = (now.weekday - 1 + langkah) % 7;
      final nama = namaHari[indeks];
      final kelas = jadwalMingguan[nama];
      if (kelas != null && kelas.isNotEmpty) {
        return JadwalHari(hari: nama, hariIni: false, kelas: kelas);
      }
    }

    return JadwalHari(hari: hariIni, hariIni: true, kelas: const <KelasKuliah>[]);
  }

  /// Mata kuliah yang sedang berlangsung sekarang (kalau ada).
  static KelasKuliah? kelasSedangBerjalan([DateTime? sekarang]) {
    final now = sekarang ?? DateTime.now();
    final jadwal = jadwalMingguan[namaHariDari(now)];
    if (jadwal == null) return null;
    for (final kelas in jadwal) {
      if (kelas.sedangBerjalan(now)) return kelas;
    }
    return null;
  }

  /// Kelas berikutnya hari ini (kalau ada).
  static KelasKuliah? kelasBerikutnya([DateTime? sekarang]) {
    final now = sekarang ?? DateTime.now();
    final jadwal = jadwalMingguan[namaHariDari(now)];
    if (jadwal == null) return null;
    for (final kelas in jadwal) {
      if (kelas.belumMulai(now)) return kelas;
    }
    return null;
  }
}
