// ============================================================================
// LEDGER KEUANGAN — data asli dari print-out keuangan kampus
// ============================================================================
// 12 baris transaksi apa adanya (No, Nama Transaksi, Debet, Kredit, Saldo).
// Angka TIDAK dibulatkan dan TIDAK dikarang ulang: saldo tiap baris disalin
// dari print-out, jadi bila ada yang aneh (mis. saldo sudah memuat sisa lebih
// semester sebelumnya) itu memang perilaku aslinya, bukan salah hitung di sini.
//
// Catatan: footer print-out menulis "Jumlah Debet Rp 41.500.000 / Kredit
// Rp 41.500.000", padahal jumlah barisnya Kredit = Rp 38.500.000. Yang dipakai
// adalah hasil penjumlahan baris, karena hanya itu yang konsisten dengan saldo
// akhir -Rp 3.000.000 pada baris terakhir.

/// Satu baris buku besar keuangan mahasiswa.
class TransaksiKeuangan {
  const TransaksiKeuangan({
    required this.no,
    required this.judul,
    required this.rincian,
    required this.meta,
    required this.tanggal,
    required this.semester,
    required this.debet,
    required this.kredit,
    required this.saldo,
  });

  /// Nomor urut pada print-out.
  final int no;

  /// Nama transaksi ringkas untuk daftar.
  final String judul;

  /// Rincian panjang (jenis UKT, nomor VA, dsb).
  final String rincian;

  /// Keterangan "Input di sistem ...".
  final String meta;

  final DateTime tanggal;

  /// Label semester pemilik tagihan, mis. "Ganjil 2026/2027".
  final String semester;

  /// Tagihan (menambah utang). 0 untuk baris pembayaran.
  final int debet;

  /// Pembayaran / keringanan (mengurangi utang). 0 untuk baris tagihan.
  final int kredit;

  /// Saldo setelah baris ini dihitung. Negatif = masih berutang.
  final int saldo;

  bool get tagihan => debet > 0;

  /// Nominal yang ditampilkan di kanan: debet untuk tagihan, kredit untuk
  /// pembayaran.
  int get nilai => tagihan ? debet : kredit;
}

/// Rekap satu semester (satu atau lebih tagihan + pembayarannya).
class RingkasanSemester {
  RingkasanSemester({required this.nama, required this.transaksi});

  /// Mis. "Ganjil 2026/2027".
  final String nama;

  /// Urut kronologis.
  final List<TransaksiKeuangan> transaksi;

  int get tagihan => transaksi.fold(0, (t, x) => t + x.debet);

  int get dibayar => transaksi.fold(0, (t, x) => t + x.kredit);

  /// Positif = kurang, nol = lunas, negatif = lebih bayar.
  int get selisih => tagihan - dibayar;

  int get jumlahTagihan => transaksi.where((t) => t.tagihan).length;

  int get jumlahPembayaran => transaksi.where((t) => !t.tagihan).length;

  /// Saldo sebelum baris pertama semester ini. Positif berarti ada sisa
  /// lebih dari semester sebelumnya yang ikut masuk.
  int get saldoAwal {
    final awal = transaksi.first;
    return awal.saldo + awal.debet - awal.kredit;
  }

  /// Saldo setelah baris terakhir semester ini. Negatif = masih berutang.
  int get saldoAkhir => transaksi.last.saldo;
}

class KeuanganData {
  KeuanganData._();

  /// Nomor VA terakhir yang dipakai membayar (baris 12). Dipakai halaman
  /// Keuangan sebagai nomor yang bisa disalin.
  static const String vaTerakhir = '966450-2411044';

  static const String _bulan =
      'Jan Feb Mar Apr Mei Jun Jul Agu Sep Okt Nov Des';

  /// Seluruh transaksi, urut kronologis persis seperti print-out.
  static final List<TransaksiKeuangan> transaksi = <TransaksiKeuangan>[
    TransaksiKeuangan(
      no: 1,
      judul: 'UKT S1 IF Pagi — Gel. II 2024',
      rincian: 'UKT S1 IF PAGI 2024 · 2024/GANJIL · Rp 9.000.000',
      meta: 'Input di sistem 6 Sep 2024',
      tanggal: DateTime(2024, 9, 6),
      semester: 'Ganjil 2024/2025',
      debet: 9000000,
      kredit: 0,
      saldo: -9000000,
    ),
    TransaksiKeuangan(
      no: 2,
      judul: 'Pembayaran TF MB Mandiri',
      rincian: 'Transfer 26/06/2024 + 29/07/2024',
      meta: 'Input di sistem 8 Sep 2024',
      tanggal: DateTime(2024, 9, 8),
      semester: 'Ganjil 2024/2025',
      debet: 0,
      kredit: 9000000,
      saldo: 0,
    ),
    TransaksiKeuangan(
      no: 3,
      judul: 'UKT S1 IF Pagi — Gel. II 2024',
      rincian: 'UKT S1 IF PAGI 2024 · 2024/GENAP · Rp 8.500.000',
      meta: 'Input di sistem 10 Feb 2025',
      tanggal: DateTime(2025, 2, 10),
      semester: 'Genap 2024/2025',
      debet: 8500000,
      kredit: 0,
      saldo: -8500000,
    ),
    TransaksiKeuangan(
      no: 4,
      judul: 'Pembayaran via BNI',
      rincian: 'VA 093127-2411044',
      meta: 'Input di sistem 14 Feb 2025',
      tanggal: DateTime(2025, 2, 14),
      semester: 'Genap 2024/2025',
      debet: 0,
      kredit: 8500000,
      saldo: 0,
    ),
    TransaksiKeuangan(
      no: 5,
      judul: 'UKT S1 IF Malam — Gel. II 2024',
      rincian: 'UKT S1 IF MALAM 2024 · 2025/GANJIL · Rp 8.500.000',
      meta: 'Input di sistem 3 Sep 2025',
      tanggal: DateTime(2025, 9, 3),
      semester: 'Ganjil 2025/2026',
      debet: 8500000,
      kredit: 0,
      saldo: -8500000,
    ),
    TransaksiKeuangan(
      no: 6,
      judul: 'Pembayaran via BNI',
      rincian: 'VA 907023-2411044',
      meta: 'Input di sistem 8 Sep 2025',
      tanggal: DateTime(2025, 9, 8),
      semester: 'Ganjil 2025/2026',
      debet: 0,
      kredit: 4250000,
      saldo: -4250000,
    ),
    TransaksiKeuangan(
      no: 7,
      judul: 'Pembayaran via BNI',
      rincian: 'VA 966644-2411044',
      meta: 'Input di sistem 6 Des 2025',
      tanggal: DateTime(2025, 12, 6),
      semester: 'Ganjil 2025/2026',
      debet: 0,
      kredit: 4250000,
      saldo: 0,
    ),
    TransaksiKeuangan(
      no: 8,
      judul: 'UKT S1 IF Pagi — Gel. II 2024',
      rincian: 'UKT S1 IF PAGI 2024 · 2025/GENAP · Rp 8.000.000',
      meta: 'Input di sistem 19 Feb 2026',
      tanggal: DateTime(2026, 2, 19),
      semester: 'Genap 2025/2026',
      debet: 8000000,
      kredit: 0,
      saldo: -8000000,
    ),
    TransaksiKeuangan(
      no: 9,
      judul: 'Pembayaran via BNI',
      rincian: 'VA 908131-2411044',
      meta: 'Input di sistem 21 Feb 2026',
      tanggal: DateTime(2026, 2, 21),
      semester: 'Genap 2025/2026',
      debet: 0,
      kredit: 4000000,
      saldo: -4000000,
    ),
    TransaksiKeuangan(
      no: 10,
      judul: 'Beasiswa Gratispoll 2026',
      rincian: 'Semester Genap 2025/2026 · 16/03/2026',
      meta: 'Input di sistem 30 Mar 2026',
      tanggal: DateTime(2026, 3, 16),
      semester: 'Genap 2025/2026',
      debet: 0,
      kredit: 5000000,
      saldo: 1000000,
    ),
    TransaksiKeuangan(
      no: 11,
      judul: 'UKT S1 IF Pagi — Gel. II 2024',
      rincian: 'UKT S1 IF PAGI 2024 · 2026/GANJIL · Rp 7.500.000',
      meta: 'Input di sistem 31 Agu 2026',
      tanggal: DateTime(2026, 8, 31),
      semester: 'Ganjil 2026/2027',
      debet: 7500000,
      kredit: 0,
      saldo: -6500000,
    ),
    TransaksiKeuangan(
      no: 12,
      judul: 'Pembayaran via BNI',
      rincian: 'VA 966450-2411044',
      meta: 'Input di sistem 2 Sep 2026',
      tanggal: DateTime(2026, 9, 2),
      semester: 'Ganjil 2026/2027',
      debet: 0,
      kredit: 3500000,
      saldo: -3000000,
    ),
  ];

  /// Rekap per semester, terbaru lebih dulu.
  static List<RingkasanSemester> get perSemester {
    final urutan = <String>[];
    final kelompok = <String, List<TransaksiKeuangan>>{};
    for (final t in transaksi) {
      if (!kelompok.containsKey(t.semester)) {
        urutan.add(t.semester);
        kelompok[t.semester] = <TransaksiKeuangan>[];
      }
      kelompok[t.semester]!.add(t);
    }
    return urutan.reversed
        .map(
          (nama) => RingkasanSemester(nama: nama, transaksi: kelompok[nama]!),
        )
        .toList();
  }

  static int get totalDebet => transaksi.fold(0, (t, x) => t + x.debet);

  static int get totalKredit => transaksi.fold(0, (t, x) => t + x.kredit);

  /// Saldo akhir menurut baris terakhir print-out. Negatif = masih berutang.
  static int get saldoAkhir => transaksi.last.saldo;

  /// Tagihan yang belum dibayar (0 bila lunas / lebih bayar).
  static int get tunggakan => saldoAkhir < 0 ? -saldoAkhir : 0;

  /// Sisa lebih dari semester lalu yang ikut menutup tagihan semester ini.
  /// Contoh: Genap 2025/2026 lebih bayar Rp 1.000.000, jadi tagihan Ganjil
  /// 2026/2027 yang kurang Rp 4.000.000 menyisakan Rp 3.000.000.
  static int get sisaLebihMasuk {
    final awal = perSemester.first.saldoAwal;
    return awal > 0 ? awal : 0;
  }

  /// Porsi yang sudah dibayar dari seluruh tagihan, 0..1.
  static double get rasioTerbayar {
    if (totalDebet <= 0) return 1;
    return (totalKredit / totalDebet).clamp(0.0, 1.0);
  }

  /// Tagihan semester yang sedang berjalan (kosong bila tidak ada barisnya).
  static RingkasanSemester? get semesterBerjalan {
    for (final s in perSemester) {
      if (s.selisih > 0) return s;
    }
    return null;
  }

  // ------------------------------------------------------------- format teks

  static String _grup(int nilai) {
    final teks = nilai.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < teks.length; i++) {
      if (i > 0 && (teks.length - i) % 3 == 0) buffer.write('.');
      buffer.write(teks[i]);
    }
    return buffer.toString();
  }

  /// "Rp 9.000.000". `tanda: true` menambahkan "+" / "-" di depan
  /// (dipakai kolom debet/kredit).
  static String rupiah(int nilai, {bool tanda = false}) {
    final prefix = nilai < 0 ? '-Rp ' : (tanda && nilai > 0 ? '+Rp ' : 'Rp ');
    return '$prefix${_grup(nilai.abs())}';
  }

  /// Bentuk pendek untuk chip: "Rp 3 jt", "Rp 7,5 jt", "Rp 500 rb".
  static String rupiahRingkas(int nilai) {
    final abs = nilai.abs();
    final tanda = nilai < 0 ? '-' : '';
    if (abs == 0) return 'Rp 0';
    if (abs < 1000000) {
      return '${tanda}Rp ${(abs / 1000).toStringAsFixed(0)} rb';
    }
    final jt = abs / 1000000;
    final teks = jt == jt.roundToDouble()
        ? jt.toStringAsFixed(0)
        : jt.toStringAsFixed(1).replaceAll('.', ',');
    return '${tanda}Rp $teks jt';
  }

  /// "6 Sep 2024".
  static String tanggalPendek(DateTime t) {
    final nama = _bulan.split(' ')[t.month - 1];
    return '${t.day} $nama ${t.year}';
  }
}
