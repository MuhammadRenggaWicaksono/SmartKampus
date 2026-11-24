import 'package:flutter/foundation.dart';

import 'package:app_kampus/data/skripsi_store.dart'
    show formatTanggalSingkat, namaBulanSingkat;

// ============================================================================
// DATA & STATE MODUL KERJA PRAKTIK (KP)
// ============================================================================
// Menyesuaikan formulir "DATA KP" milik web kampus, tapi disimpan di store ini
// supaya layar tidak menyimpan data dummy sendiri. Pola sama dengan
// skripsi_store.dart: ValueNotifier, tanpa dependency baru.

/// Nama bulan lengkap (Januari … Desember), untuk label periode KP
/// seperti "September 2026".
const List<String> namaBulanPanjang = <String>[
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Status satu data Kerja Praktik di Program Studi.
enum StatusKp { menunggu, disetujui, berjalan, selesai, ditolak }

extension StatusKpLabel on StatusKp {
  String get label => switch (this) {
    StatusKp.menunggu => 'Menunggu Verifikasi',
    StatusKp.disetujui => 'Disetujui Prodi',
    StatusKp.berjalan => 'Sedang Berjalan',
    StatusKp.selesai => 'Selesai',
    StatusKp.ditolak => 'Ditolak',
  };

  /// Keterangan singkat untuk lencana di menu Akademik.
  String get labelSingkat => switch (this) {
    StatusKp.menunggu => 'Menunggu',
    StatusKp.disetujui => 'Disetujui',
    StatusKp.berjalan => 'Berjalan',
    StatusKp.selesai => 'Selesai',
    StatusKp.ditolak => 'Ditolak',
  };
}

/// Satu bulan + tahun. Dipakai untuk "Bulan tahun awal KP" dan
/// "Bulan tahun akhir KP" pada formulir DATA KP.
@immutable
class PeriodeKp implements Comparable<PeriodeKp> {
  /// 1 = Januari … 12 = Desember.
  final int bulan;
  final int tahun;

  const PeriodeKp({required this.bulan, required this.tahun});

  /// Bulan di luar 1..12 digeser otomatis ke tahun berikutnya/sebelumnya,
  /// supaya perhitungan "akhir = awal + 2 bulan" tidak pernah menghasilkan
  /// bulan 13 atau 0.
  factory PeriodeKp.normalisasi(int bulan, int tahun) {
    final total = tahun * 12 + (bulan - 1);
    return PeriodeKp(bulan: total % 12 + 1, tahun: total ~/ 12);
  }

  String get namaBulan => namaBulanPanjang[bulan - 1];

  /// "September 2026".
  String get label => '$namaBulan $tahun';

  /// "Sep 2026".
  String get labelSingkat => '${namaBulanSingkat[bulan - 1]} $tahun';

  /// Jumlah bulan sejak tahun 0 — mempermudah selisih dan urutan.
  int get nomorBulan => tahun * 12 + (bulan - 1);

  /// Selisih bulan ke [lain]; negatif kalau [lain] lebih awal.
  int selisihBulanKe(PeriodeKp lain) => lain.nomorBulan - nomorBulan;

  /// Periode ini digeser [n] bulan (boleh negatif).
  PeriodeKp geser(int n) => PeriodeKp.normalisasi(bulan + n, tahun);

  @override
  int compareTo(PeriodeKp other) => nomorBulan.compareTo(other.nomorBulan);

  bool operator <(PeriodeKp lain) => nomorBulan < lain.nomorBulan;
  bool operator <=(PeriodeKp lain) => nomorBulan <= lain.nomorBulan;
  bool operator >(PeriodeKp lain) => nomorBulan > lain.nomorBulan;
  bool operator >=(PeriodeKp lain) => nomorBulan >= lain.nomorBulan;

  @override
  bool operator ==(Object other) =>
      other is PeriodeKp && other.bulan == bulan && other.tahun == tahun;

  @override
  int get hashCode => Object.hash(bulan, tahun);

  @override
  String toString() => label;
}

/// Lama KP dalam bulan (inklusif: September–Desember = 4 bulan).
/// Mengembalikan 0 kalau [akhir] lebih awal dari [awal].
int durasiBulanKp(PeriodeKp awal, PeriodeKp akhir) {
  final selisih = awal.selisihBulanKe(akhir);
  return selisih < 0 ? 0 : selisih + 1;
}

/// Daftar tahun untuk dropdown periode: 2010 (sama dengan web kampus)
/// sampai dua tahun setelah tahun berjalan.
List<int> daftarTahunKp({int tahunAwal = 2010, int? tahunSekarang}) {
  final kini = tahunSekarang ?? DateTime.now().year;
  final akhir = kini + 2 < tahunAwal ? tahunAwal : kini + 2;
  return <int>[for (var t = tahunAwal; t <= akhir; t++) t];
}

/// Satu dokumen KP yang harus dilampirkan mahasiswa.
@immutable
class DokumenKp {
  final String id;
  final String nama;
  final String keterangan;

  const DokumenKp({
    required this.id,
    required this.nama,
    required this.keterangan,
  });
}

/// Berkas yang diminta Koordinator KP. Semua boleh dikosongkan dulu
/// (diisi bertahap), hanya saja progresnya ikut terhitung.
const List<DokumenKp> dokumenKp = <DokumenKp>[
  DokumenKp(
    id: 'proposal',
    nama: 'Proposal KP',
    keterangan: 'Rencana kegiatan yang disetujui kedua pembimbing',
  ),
  DokumenKp(
    id: 'surat-izin',
    nama: 'Surat Izin KP',
    keterangan: 'Surat pengantar Program Studi ke instansi mitra',
  ),
  DokumenKp(
    id: 'lembar-bimbingan',
    nama: 'Lembar Bimbingan',
    keterangan: 'Bukti bimbingan berkala bersama pembimbing',
  ),
  DokumenKp(
    id: 'laporan',
    nama: 'Laporan Akhir KP',
    keterangan: 'Naskah laporan setelah kegiatan di instansi selesai',
  ),
  DokumenKp(
    id: 'penilaian',
    nama: 'Lembar Penilaian',
    keterangan: 'Nilai resmi dari pembimbing lapangan',
  ),
];

/// Satu baris data Kerja Praktik — isi formulir DATA KP web kampus.
@immutable
class DataKp {
  final String id;
  final String instansi;
  final String judul;

  /// Pembimbing dari pihak instansi.
  final String pembimbingLapangan;

  /// Pembimbing dari kampus (dosen) — tidak ada di web, ditambahkan di sini.
  final String pembimbingKampus;

  final PeriodeKp awal;
  final PeriodeKp akhir;
  final StatusKp status;
  final DateTime diajukan;
  final String catatan;

  /// id dokumen (lihat [dokumenKp]) → tautan berkas. Tautan kosong atau "-"
  /// berarti dokumen belum diunggah.
  final Map<String, String> tautan;

  DataKp({
    required this.id,
    required this.instansi,
    required this.judul,
    required this.pembimbingLapangan,
    required this.awal,
    required this.akhir,
    this.pembimbingKampus = '',
    this.status = StatusKp.menunggu,
    DateTime? diajukan,
    this.catatan = '',
    this.tautan = const <String, String>{},
  }) : diajukan = diajukan ?? _defaultDiajukan;

  /// Kalau [diajukan] tidak diisi, semua DataKp baru memakai epoch ini.
  static final DateTime _defaultDiajukan = DateTime(2026, 1, 1);

  /// Lama kegiatan dalam bulan.
  int get durasiBulan => durasiBulanKp(awal, akhir);

  /// "September 2026 – Desember 2026".
  String get periodeTeks => '${awal.label} – ${akhir.label}';

  /// "Sep 2026 – Des 2026".
  String get periodeSingkat => '${awal.labelSingkat} – ${akhir.labelSingkat}';

  String get tanggalDiajukan => formatTanggalSingkat(diajukan);

  bool get keduaPembimbingLengkap =>
      pembimbingLapangan.trim().isNotEmpty &&
      pembimbingKampus.trim().isNotEmpty;

  /// Tautan dokumen, atau string kosong kalau belum diisi.
  String tautanDokumen(String idDokumen) => tautan[idDokumen]?.trim() ?? '';

  bool dokumenTerisi(String idDokumen) {
    final isi = tautanDokumen(idDokumen);
    return isi.isNotEmpty && isi != '-';
  }

  int get jumlahDokumenTerisi =>
      dokumenKp.where((d) => dokumenTerisi(d.id)).length;

  double get progresDokumen =>
      dokumenKp.isEmpty ? 0 : jumlahDokumenTerisi / dokumenKp.length;

  DataKp copyWith({
    String? id,
    String? instansi,
    String? judul,
    String? pembimbingLapangan,
    String? pembimbingKampus,
    PeriodeKp? awal,
    PeriodeKp? akhir,
    StatusKp? status,
    DateTime? diajukan,
    String? catatan,
    Map<String, String>? tautan,
  }) {
    return DataKp(
      id: id ?? this.id,
      instansi: instansi ?? this.instansi,
      judul: judul ?? this.judul,
      pembimbingLapangan: pembimbingLapangan ?? this.pembimbingLapangan,
      pembimbingKampus: pembimbingKampus ?? this.pembimbingKampus,
      awal: awal ?? this.awal,
      akhir: akhir ?? this.akhir,
      status: status ?? this.status,
      diajukan: diajukan ?? this.diajukan,
      catatan: catatan ?? this.catatan,
      tautan: tautan ?? this.tautan,
    );
  }
}

/// Tahapan penyusunan Kerja Praktik.
enum StatusTahapanKp { selesai, berjalan, belum }

@immutable
class TahapanKp {
  final String nama;
  final String keterangan;
  final StatusTahapanKp status;

  const TahapanKp({
    required this.nama,
    required this.keterangan,
    required this.status,
  });
}

/// Kerangka tahapan (statusnya diisi oleh [tahapanKpUntuk]).
const List<({String nama, String keterangan})> _kerangkaTahapanKp =
    <({String nama, String keterangan})>[
      (
        nama: 'Pengajuan Data KP',
        keterangan: 'Instansi, judul, periode, dan pembimbing lapangan diisi',
      ),
      (
        nama: 'Verifikasi Program Studi',
        keterangan: 'Data KP diperiksa Koordinator KP',
      ),
      (
        nama: 'Penetapan Pembimbing',
        keterangan: 'Pembimbing lapangan dan pembimbing kampus ditetapkan',
      ),
      (
        nama: 'Pelaksanaan KP',
        keterangan: 'Kegiatan berjalan di instansi mitra',
      ),
      (
        nama: 'Bimbingan & Laporan',
        keterangan: 'Bimbingan berkala dan penyusunan laporan akhir',
      ),
      (
        nama: 'Penilaian & Selesai',
        keterangan: 'Nilai instansi masuk dan KP dinyatakan selesai',
      ),
    ];

/// Tahapan KP yang diturunkan dari status satu data KP.
///
/// Kalau [kp] null → semua tahap belum dimulai. Status `disetujui` naik satu
/// tahap begitu kedua pembimbing sudah terisi.
List<TahapanKp> tahapanKpUntuk(DataKp? kp) {
  final status = kp?.status;
  final lengkap = kp?.keduaPembimbingLengkap ?? false;

  const belum = StatusTahapanKp.belum;
  const kerja = StatusTahapanKp.berjalan;
  const beres = StatusTahapanKp.selesai;

  final List<StatusTahapanKp> urutan = switch (status) {
    null => const <StatusTahapanKp>[belum, belum, belum, belum, belum, belum],
    StatusKp.ditolak => const <StatusTahapanKp>[
      beres,
      belum,
      belum,
      belum,
      belum,
      belum,
    ],
    StatusKp.menunggu => const <StatusTahapanKp>[
      beres,
      kerja,
      belum,
      belum,
      belum,
      belum,
    ],
    StatusKp.disetujui =>
      lengkap
          ? const <StatusTahapanKp>[beres, beres, beres, kerja, belum, belum]
          : const <StatusTahapanKp>[beres, beres, kerja, belum, belum, belum],
    StatusKp.berjalan => const <StatusTahapanKp>[
      beres,
      beres,
      beres,
      beres,
      kerja,
      belum,
    ],
    StatusKp.selesai => const <StatusTahapanKp>[
      beres,
      beres,
      beres,
      beres,
      beres,
      beres,
    ],
  };

  return <TahapanKp>[
    for (var i = 0; i < _kerangkaTahapanKp.length; i++)
      TahapanKp(
        nama: _kerangkaTahapanKp[i].nama,
        keterangan: _kerangkaTahapanKp[i].keterangan,
        status: urutan[i],
      ),
  ];
}

/// Progres tahapan (0..1) — dipakai bilah progres di halaman KP.
double progresTahapanKp(List<TahapanKp> tahapan) {
  if (tahapan.isEmpty) return 0;
  final selesai = tahapan
      .where((t) => t.status == StatusTahapanKp.selesai)
      .length;
  final adaBerjalan = tahapan.any((t) => t.status == StatusTahapanKp.berjalan);
  final nilai = selesai + (adaBerjalan ? 0.5 : 0);
  return (nilai / tahapan.length).clamp(0.0, 1.0);
}

/// Satu catatan bimbingan KP.
@immutable
class BimbinganKp {
  final DateTime tanggal;
  final String topik;
  final String catatan;

  /// Nama pembimbing yang membimbing (lapangan atau kampus).
  final String pembimbing;

  const BimbinganKp({
    required this.tanggal,
    required this.topik,
    this.catatan = '',
    this.pembimbing = '',
  });

  String get tanggalTeks => formatTanggalSingkat(tanggal);
}

/// Store KP: satu-satunya sumber data untuk halaman Kerja Praktik.
class KpStore {
  KpStore._();

  static const PeriodeKp _awalBawaan = PeriodeKp(bulan: 9, tahun: 2026);

  /// Daftar data KP, terbaru di paling atas. Entri pertama = KP aktif.
  static final ValueNotifier<List<DataKp>> daftar = ValueNotifier<List<DataKp>>(
    <DataKp>[
      DataKp(
        id: 'kp-2026-telkom',
        instansi: 'PT Telkom Indonesia (Persero) Tbk — Balikpapan',
        judul:
            'Perancangan Dashboard Monitoring Gangguan Jaringan Berbasis Web '
            'pada Divisi Network Operation Center',
        pembimbingLapangan: 'Budi Santoso, S.T.',
        pembimbingKampus: 'Dr. Andi Pratama, M.Kom.',
        awal: _awalBawaan,
        akhir: PeriodeKp(bulan: 12, tahun: 2026),
        status: StatusKp.berjalan,
        diajukan: DateTime(2026, 8, 12),
        catatan:
            'Surat balasan instansi sudah diterima. Laporan akhir '
            'ditargetkan selesai Desember 2026.',
        tautan: const <String, String>{
          'proposal': 'https://drive.google.com/file/d/proposal-kp/view',
          'surat-izin': 'https://drive.google.com/file/d/surat-izin-kp/view',
          'lembar-bimbingan': '-',
          'laporan': '-',
          'penilaian': '-',
        },
      ),
    ],
  );

  /// Catatan bimbingan, terbaru di paling atas.
  static final ValueNotifier<List<BimbinganKp>> bimbingan =
      ValueNotifier<List<BimbinganKp>>(<BimbinganKp>[
        BimbinganKp(
          tanggal: DateTime(2026, 11, 18),
          topik: 'Bab 4 — pengujian dashboard',
          catatan: 'Tambahkan pengujian beban pada halaman monitoring.',
          pembimbing: 'Dr. Andi Pratama, M.Kom.',
        ),
        BimbinganKp(
          tanggal: DateTime(2026, 11, 6),
          topik: 'Draft Bab 3 & 4',
          catatan: 'Perbaiki penamaan grafik dan satuan waktu.',
          pembimbing: 'Dr. Andi Pratama, M.Kom.',
        ),
        BimbinganKp(
          tanggal: DateTime(2026, 10, 24),
          topik: 'Pengambilan data gangguan NOC',
          catatan: 'Data satu bulan penuh sudah diserahkan ke pembimbing.',
          pembimbing: 'Budi Santoso, S.T.',
        ),
      ]);

  /// Data KP yang ditampilkan sebagai kartu utama.
  static DataKp? get aktif => daftar.value.isEmpty ? null : daftar.value.first;

  static int get jumlah => daftar.value.length;

  static List<DataKp> get riwayat =>
      daftar.value.length <= 1 ? const <DataKp>[] : daftar.value.sublist(1);

  /// Data KP yang ditampilkan halaman = yang terbaru, atau yang cocok [id].
  static DataKp? cari(String id) {
    for (final kp in daftar.value) {
      if (kp.id == id) return kp;
    }
    return null;
  }

  /// Tambah data KP baru di urutan paling atas (langsung jadi KP aktif).
  static void tambah(DataKp baru) {
    daftar.value = <DataKp>[baru, ...daftar.value];
  }

  /// Ganti data KP yang punya id sama, tanpa mengubah urutannya.
  static void perbarui(DataKp ubah) {
    daftar.value = <DataKp>[
      for (final kp in daftar.value) kp.id == ubah.id ? ubah : kp,
    ];
  }

  static void hapus(String id) {
    daftar.value = daftar.value
        .where((kp) => kp.id != id)
        .toList(growable: false);
  }

  /// Jadikan [id] sebagai KP aktif (dipindah ke paling atas).
  static void jadikanAktif(String id) {
    final kp = cari(id);
    if (kp == null) return;
    daftar.value = <DataKp>[kp, ...daftar.value.where((k) => k.id != id)];
  }

  /// Isi/ganti tautan satu dokumen. [tautan] kosong berarti dokumen dikosongkan.
  static void simpanTautan(String idKp, String idDokumen, String tautan) {
    final kp = cari(idKp);
    if (kp == null) return;
    final baru = Map<String, String>.from(kp.tautan);
    final bersih = tautan.trim();
    if (bersih.isEmpty) {
      baru.remove(idDokumen);
    } else {
      baru[idDokumen] = bersih;
    }
    perbarui(kp.copyWith(tautan: baru));
  }

  /// Jumlah dokumen yang sudah terisi pada KP aktif (atau 0 tanpa data).
  static int get jumlahDokumenTerisi => aktif?.jumlahDokumenTerisi ?? 0;

  static void tambahBimbingan(BimbinganKp baru) {
    bimbingan.value = <BimbinganKp>[baru, ...bimbingan.value];
  }

  static void hapusBimbingan(int index) {
    if (index < 0 || index >= bimbingan.value.length) return;
    bimbingan.value = <BimbinganKp>[
      for (var i = 0; i < bimbingan.value.length; i++)
        if (i != index) bimbingan.value[i],
    ];
  }
}

/// Periode awal bawaan untuk form: bulan & tahun berjalan.
PeriodeKp periodeAwalBawaan([DateTime? sekarang]) {
  final kini = sekarang ?? DateTime.now();
  return PeriodeKp(bulan: kini.month, tahun: kini.year);
}

/// Periode akhir bawaan untuk form: [bulanTambahan] bulan setelah awal.
PeriodeKp periodeAkhirBawaan([DateTime? sekarang, int bulanTambahan = 2]) =>
    periodeAwalBawaan(sekarang).geser(bulanTambahan);

/// id unik untuk data KP baru.
String idKpBaru([DateTime? sekarang]) =>
    'kp-${(sekarang ?? DateTime.now()).microsecondsSinceEpoch}';
