import 'package:flutter/foundation.dart';

// ============================================================================
// DATA & STATE MODUL SKRIPSI
// ============================================================================
// Berkas layar dilarang menyimpan data dummy sendiri (lihat skill
// smartkampus-flutter-ui). Karena daftar pengajuan judul bisa BERTAMBAH dari
// form, datanya disimpan di store ini — pakai ValueNotifier supaya halaman
// Skripsi ikut ter-refresh otomatis, mengikuti pola yang sudah dipakai
// theme_notifier.dart. Tanpa dependency baru.

/// Status satu pengajuan judul skripsi.
enum StatusSkripsi { menunggu, disetujui, ditolak }

extension StatusSkripsiLabel on StatusSkripsi {
  String get label => switch (this) {
    StatusSkripsi.menunggu => 'Menunggu Verifikasi',
    StatusSkripsi.disetujui => 'Disetujui',
    StatusSkripsi.ditolak => 'Ditolak',
  };
}

/// Satu baris pengajuan judul skripsi beserta link berkas pendukungnya.
///
/// Aturan kampus: minimal satu link berkas harus diisi. Link berkas 2 dan 3
/// kalau tidak ada diisi dengan karakter "-".
class PengajuanSkripsi {
  final String judul;
  final String berkas1;
  final String berkas2;
  final String berkas3;
  final DateTime diajukan;
  final StatusSkripsi status;
  final String catatan;

  const PengajuanSkripsi({
    required this.judul,
    required this.berkas1,
    required this.berkas2,
    required this.berkas3,
    required this.diajukan,
    this.status = StatusSkripsi.menunggu,
    this.catatan = '',
  });

  List<String> get daftarBerkas => <String>[berkas1, berkas2, berkas3];

  /// Berkas yang benar-benar ada isinya (bukan kosong dan bukan "-").
  int get jumlahBerkasNyata =>
      daftarBerkas.where((b) => b.trim().isNotEmpty && b.trim() != '-').length;

  String get tanggalDiajukan => formatTanggalSingkat(diajukan);
}

/// Tahapan penyusunan skripsi.
enum StatusTahapan { selesai, berjalan, belum }

class TahapanSkripsi {
  final String nama;
  final String keterangan;
  final StatusTahapan status;

  const TahapanSkripsi({
    required this.nama,
    required this.keterangan,
    required this.status,
  });
}

/// Urutan tahapan skripsi dari pengajuan sampai sidang.
const List<TahapanSkripsi> tahapanSkripsi = <TahapanSkripsi>[
  TahapanSkripsi(
    nama: 'Pengajuan Judul',
    keterangan: 'Ajukan judul beserta link berkas pendukung',
    status: StatusTahapan.berjalan,
  ),
  TahapanSkripsi(
    nama: 'Verifikasi & ACC Judul',
    keterangan: 'Judul diverifikasi oleh Program Studi',
    status: StatusTahapan.belum,
  ),
  TahapanSkripsi(
    nama: 'Penetapan Pembimbing',
    keterangan: 'Dosen pembimbing 1 dan 2 ditetapkan',
    status: StatusTahapan.belum,
  ),
  TahapanSkripsi(
    nama: 'Bimbingan & Proposal',
    keterangan: 'Minimal 8 kali bimbingan tercatat',
    status: StatusTahapan.belum,
  ),
  TahapanSkripsi(
    nama: 'Seminar Proposal',
    keterangan: 'Presentasi proposal di depan penguji',
    status: StatusTahapan.belum,
  ),
  TahapanSkripsi(
    nama: 'Sidang Skripsi',
    keterangan: 'Ujian akhir dan revisi naskah',
    status: StatusTahapan.belum,
  ),
];

/// Info pembimbing. Belum ditetapkan selama judul belum di-ACC.
class PembimbingSkripsi {
  final String peran;
  final String nama;

  const PembimbingSkripsi({required this.peran, required this.nama});

  bool get sudahDitetapkan => nama.trim().isNotEmpty && nama.trim() != '-';
}

const List<PembimbingSkripsi> pembimbingSkripsi = <PembimbingSkripsi>[
  PembimbingSkripsi(peran: 'Pembimbing 1', nama: '-'),
  PembimbingSkripsi(peran: 'Pembimbing 2', nama: '-'),
];

/// Store pengajuan judul. Satu-satunya sumber data untuk halaman Skripsi.
class SkripsiStore {
  SkripsiStore._();

  static final ValueNotifier<List<PengajuanSkripsi>> pengajuan =
      ValueNotifier<List<PengajuanSkripsi>>(<PengajuanSkripsi>[
    PengajuanSkripsi(
      judul:
          'Penerapan Algoritma YOLOv8 untuk Deteksi Penggunaan Alat Pelindung '
          'Diri pada Laboratorium Fakultas Ilmu Komputer',
      berkas1: 'https://drive.google.com/file/d/1a2b3c4d5e6f7g8h/view',
      berkas2: 'https://drive.google.com/file/d/9i8h7g6f5e4d3c2b/view',
      berkas3: '-',
      diajukan: DateTime(2026, 10, 28),
      catatan: 'Menunggu verifikasi judul oleh Program Studi.',
    ),
  ]);

  /// Tambah pengajuan baru di urutan paling atas.
  static void tambah(PengajuanSkripsi baru) {
    pengajuan.value = <PengajuanSkripsi>[baru, ...pengajuan.value];
  }

  static int get jumlahPengajuan => pengajuan.value.length;

  static PengajuanSkripsi? get terakhir =>
      pengajuan.value.isEmpty ? null : pengajuan.value.first;
}

const List<String> namaBulanSingkat = <String>[
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

/// 28 Oktober 2026 -> "28 Okt 2026".
String formatTanggalSingkat(DateTime tanggal) {
  final hari = tanggal.day.toString().padLeft(2, '0');
  return '$hari ${namaBulanSingkat[tanggal.month - 1]} ${tanggal.year}';
}
