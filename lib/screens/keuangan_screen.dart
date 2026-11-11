import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/data/keuangan_data.dart';

/// Halaman Keuangan.
///
/// Struktur mengikuti Dashboard: judul 24pt, kartu `p.cardDeco()`, pemisah
/// antar blok 24dp. Sebelumnya halaman ini punya kartu VA oranye bergradasi
/// sendiri (satu-satunya oranye di aplikasi) dan daftar transaksi yang
/// dipotong jadi 3 tanpa konteks semester — sekarang datanya dikelompokkan
/// per semester dengan rekap tagihan di atas.
class KeuanganScreen extends StatefulWidget {
  const KeuanganScreen({super.key});

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> {
  /// Semester yang sedang terbuka. Default hanya semester berjalan, supaya
  /// halaman tidak langsung berisi 12 baris transaksi.
  late final Set<String> _terbuka = <String>{
    KeuanganData.perSemester.first.nama,
  };

  bool get _semuaTerbuka => _terbuka.length == KeuanganData.perSemester.length;

  void _alihSemua() {
    setState(() {
      if (_semuaTerbuka) {
        _terbuka.clear();
      } else {
        _terbuka.addAll(KeuanganData.perSemester.map((s) => s.nama));
      }
    });
  }

  void _alih(String nama) {
    setState(() {
      if (!_terbuka.remove(nama)) _terbuka.add(nama);
    });
  }

  void _salinVa(AppPalette p) {
    final nomor = KeuanganData.vaTerakhir.replaceAll(RegExp(r'[^0-9]'), '');
    Clipboard.setData(ClipboardData(text: nomor));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: p.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: p.success, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Nomor VA berhasil disalin',
                style: TextStyle(color: p.textPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(p),
                    const SizedBox(height: 24),
                    _buildRingkasan(p),
                    const SizedBox(height: 16),
                    _buildKartuVa(p),
                    const SizedBox(height: 24),
                    _buildJudulRiwayat(p),
                    const SizedBox(height: 12),
                    ...KeuanganData.perSemester.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildKartuSemester(p, s),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildRekap(p),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------- header
  Widget _buildHeader(AppPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keuangan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: p.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppData.nim} · ${AppData.semesterAktif}',
          style: TextStyle(fontSize: 13, color: p.textSecondary),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ ringkasan
  Widget _buildRingkasan(AppPalette p) {
    final tunggakan = KeuanganData.tunggakan;
    final lunas = tunggakan == 0;
    final warna = lunas ? p.success : p.danger;
    final persen = (KeuanganData.rasioTerbayar * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: p.cardDeco(borderColor: warna.withValues(alpha: 0.35)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SISA TAGIHAN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: p.textSecondary,
                  ),
                ),
              ),
              _buildChip(lunas ? 'LUNAS' : 'BELUM LUNAS', warna),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              KeuanganData.rupiah(tunggakan),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: warna,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _subjudulRingkasan(),
            style: TextStyle(
              fontSize: 11.5,
              height: 1.3,
              color: p.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: KeuanganData.rasioTerbayar,
              minHeight: 6,
              backgroundColor: p.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(
                lunas ? p.success : p.accent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$persen% sudah dibayar',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: p.textSecondary,
                  ),
                ),
              ),
              Text(
                'dari ${KeuanganData.rupiah(KeuanganData.totalDebet)}',
                style: TextStyle(fontSize: 10, color: p.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 0.5, color: p.divider),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStat(p, 'TOTAL TAGIHAN', KeuanganData.totalDebet),
              const SizedBox(width: 12),
              _buildStat(
                p,
                'TOTAL DIBAYAR',
                KeuanganData.totalKredit,
                warna: p.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Subjudul di bawah angka sisa tagihan. Menyebut sisa lebih semester
  /// lalu supaya angka "Rp 3.000.000" tidak terlihat bertentangan dengan
  /// chip "KURANG Rp 4 jt" di kartu Ganjil 2026/2027.
  String _subjudulRingkasan() {
    final nama = KeuanganData.semesterBerjalan?.nama;
    if (nama == null) return 'Tidak ada tagihan aktif';
    final lebih = KeuanganData.sisaLebihMasuk;
    if (lebih == 0) return nama;
    return '$nama · sudah termasuk sisa lebih '
        '${KeuanganData.rupiah(lebih)} dari semester lalu';
  }

  Widget _buildStat(AppPalette p, String label, int nilai, {Color? warna}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: p.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              KeuanganData.rupiah(nilai),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: warna ?? p.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- VA BNI
  Widget _buildKartuVa(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance, color: p.accentText, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VIRTUAL ACCOUNT BNI',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    KeuanganData.vaTerakhir.replaceAll('-', ' '),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: p.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Nomor terakhir dipakai · ${_tanggalVa()}',
                  style: TextStyle(fontSize: 10, color: p.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _salinVa(p),
            tooltip: 'Salin nomor VA',
            icon: Icon(Icons.copy_rounded, color: p.accentText, size: 20),
          ),
        ],
      ),
    );
  }

  String _tanggalVa() {
    for (final t in KeuanganData.transaksi.reversed) {
      if (!t.tagihan) return KeuanganData.tanggalPendek(t.tanggal);
    }
    return '-';
  }

  // ------------------------------------------------------- judul riwayat
  Widget _buildJudulRiwayat(AppPalette p) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: p.textSecondary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Riwayat Tagihan',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _alihSemua,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _semuaTerbuka ? 'Tutup semua' : 'Buka semua',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: p.accentText,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------- kartu per semester
  Widget _buildKartuSemester(AppPalette p, RingkasanSemester s) {
    final buka = _terbuka.contains(s.nama);
    final selisih = s.selisih;
    final warna = selisih > 0
        ? (s.nama == KeuanganData.perSemester.first.nama ? p.danger : p.warning)
        : (selisih == 0 ? p.success : p.accent);
    final label = selisih > 0
        ? 'KURANG ${KeuanganData.rupiahRingkas(selisih)}'
        : (selisih < 0
              ? 'LEBIH ${KeuanganData.rupiahRingkas(-selisih)}'
              : 'LUNAS');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: p.cardDeco(),
      child: Column(
        children: [
          InkWell(
            onTap: () => _alih(s.nama),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.nama,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${s.transaksi.length} transaksi · tagihan '
                          '${KeuanganData.rupiahRingkas(s.tagihan)}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: p.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildChip(label, warna),
                  Icon(
                    buka ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: p.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (buka) ...[
            Divider(height: 1, thickness: 0.5, color: p.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
              child: Column(
                children: [
                  for (var i = 0; i < s.transaksi.length; i++) ...[
                    _buildBaris(p, s.transaksi[i]),
                    if (i != s.transaksi.length - 1)
                      Divider(height: 1, thickness: 0.5, color: p.divider),
                  ],
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              color: p.surfaceAlt.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dibayar ${KeuanganData.rupiah(s.dibayar)}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    'Tagihan ${KeuanganData.rupiah(s.tagihan)}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBaris(AppPalette p, TransaksiKeuangan t) {
    final warna = t.tagihan ? p.danger : p.success;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 34,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.rincian,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.25,
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${KeuanganData.tanggalPendek(t.tanggal)} · ${t.meta}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: p.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                KeuanganData.rupiah(t.nilai, tanda: !t.tagihan),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: warna,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'saldo ${KeuanganData.rupiah(t.saldo)}',
                style: TextStyle(fontSize: 9.5, color: p.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- rekap
  Widget _buildRekap(AppPalette p) {
    final saldo = KeuanganData.saldoAkhir;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(elevated: false, borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REKAP KESELURUHAN',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: p.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBarisRekap(
            p,
            'Total debet',
            KeuanganData.rupiah(KeuanganData.totalDebet),
          ),
          const SizedBox(height: 8),
          _buildBarisRekap(
            p,
            'Total kredit',
            KeuanganData.rupiah(KeuanganData.totalKredit),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, thickness: 0.5, color: p.divider),
          const SizedBox(height: 10),
          _buildBarisRekap(
            p,
            'Saldo akhir',
            KeuanganData.rupiah(saldo),
            tebal: true,
            warna: saldo < 0 ? p.danger : p.success,
          ),
          const SizedBox(height: 10),
          Text(
            'Saldo negatif berarti masih ada tagihan yang belum dibayar. '
            'Angka diambil dari print-out keuangan kampus.',
            style: TextStyle(fontSize: 9.5, height: 1.35, color: p.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBarisRekap(
    AppPalette p,
    String label,
    String nilai, {
    bool tebal = false,
    Color? warna,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: tebal ? FontWeight.bold : FontWeight.w500,
              color: tebal ? p.textPrimary : p.textSecondary,
            ),
          ),
        ),
        Text(
          nilai,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: tebal ? FontWeight.bold : FontWeight.w600,
            color: warna ?? p.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        teks,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: warna,
        ),
      ),
    );
  }
}
