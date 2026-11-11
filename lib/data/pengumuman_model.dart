/// Satu baris tabel `public.pengumuman`.
///
/// Kolomnya mengikuti schema.sql apa adanya — tidak ada kolom tambahan, supaya
/// data dari Supabase dan data contoh lokal berbentuk sama persis.
class Pengumuman {
  final String id;
  final String judul;
  final String isi;
  final String kategori;
  final String? url;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
  final bool penting;

  const Pengumuman({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.url,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.penting,
  });

  factory Pengumuman.fromMap(Map<String, dynamic> m) {
    final tautan = (m['url'] as String?)?.trim();
    return Pengumuman(
      id: (m['id'] ?? '').toString(),
      judul: (m['judul'] ?? 'Tanpa judul').toString(),
      isi: (m['isi'] ?? '').toString(),
      kategori: (m['kategori'] ?? 'umum').toString().toLowerCase(),
      url: (tautan == null || tautan.isEmpty) ? null : tautan,
      tanggalMulai: _tanggal(m['tanggal_mulai']) ?? DateTime.now(),
      tanggalSelesai: _tanggal(m['tanggal_selesai']),
      penting: m['is_penting'] == true,
    );
  }

  /// PostgREST mengirim kolom `date` sebagai `'2026-11-10'` (String), bukan
  /// DateTime. Tanpa konversi ini, perbandingan tanggal akan salah diam-diam.
  static DateTime? _tanggal(Object? nilai) {
    if (nilai == null) return null;
    if (nilai is DateTime) return nilai;
    final teks = nilai.toString().trim();
    if (teks.isEmpty) return null;
    return DateTime.tryParse(teks);
  }

  static DateTime _hari(DateTime t) => DateTime(t.year, t.month, t.day);

  /// Pengumuman yang tanggal berlakunya sudah lewat tidak ditampilkan lagi.
  bool get kedaluwarsa {
    final selesai = tanggalSelesai;
    if (selesai == null) return false;
    return _hari(DateTime.now()).isAfter(_hari(selesai));
  }

  /// `tanggal_mulai` bisa diisi tanggal masa depan untuk menjadwalkan
  /// pengumuman, jadi yang belum waktunya belum ikut tampil.
  bool get sudahTerbit =>
      !_hari(DateTime.now()).isBefore(_hari(tanggalMulai));

  /// Layak tampil di feed sekarang.
  bool get aktif => sudahTerbit && !kedaluwarsa;

  String get kategoriLabel => switch (kategori) {
    'akademik' => 'Akademik',
    'keuangan' => 'Keuangan',
    'kemahasiswaan' => 'Kemahasiswaan',
    'skripsi' => 'Skripsi',
    'darurat' => 'Darurat',
    _ => 'Umum',
  };

  static const List<String> _bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// "Hari ini", "Kemarin", "3 hari lalu", atau "10 Nov 2026" kalau sudah lama.
  String get waktuLabel {
    final selisih = _hari(DateTime.now())
        .difference(_hari(tanggalMulai))
        .inDays;
    if (selisih <= 0) return 'Hari ini';
    if (selisih == 1) return 'Kemarin';
    if (selisih < 7) return '$selisih hari lalu';
    final t = _hari(tanggalMulai);
    return '${t.day} ${_bulan[t.month - 1]} ${t.year}';
  }

  /// "Berlaku sampai 20 Nov 2026" — null kalau tanpa batas waktu.
  String? get berlakuSampaiLabel {
    final selesai = tanggalSelesai;
    if (selesai == null) return null;
    final s = _hari(selesai);
    return 'Berlaku sampai ${s.day} ${_bulan[s.month - 1]} ${s.year}';
  }

  /// Penting duluan, lalu yang paling baru.
  static int banding(Pengumuman a, Pengumuman b) {
    if (a.penting != b.penting) return a.penting ? -1 : 1;
    return b.tanggalMulai.compareTo(a.tanggalMulai);
  }
}