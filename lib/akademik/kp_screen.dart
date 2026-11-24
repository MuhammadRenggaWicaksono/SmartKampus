import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_kampus/akademik/tambah_kp_screen.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/konten_layar.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/data/kp_store.dart';
import 'package:app_kampus/data/skripsi_store.dart' show formatTanggalSingkat;

/// Halaman Kerja Praktik (KP): ringkasan kegiatan, alur tahapan, data KP,
/// daftar dokumen, dan catatan bimbingan.
class KpScreen extends StatefulWidget {
  const KpScreen({super.key});

  static const Color warnaAksi = Color(0xFF22C55E);

  @override
  State<KpScreen> createState() => _KpScreenState();
}

class _KpScreenState extends State<KpScreen> {
  // ------------------------------------------------------------- tambah/ubah
  Future<void> _bukaForm({DataKp? awal}) async {
    final tersimpan = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TambahKpScreen(awal: awal)),
    );

    if (tersimpan == true && mounted) {
      _pesan(
        awal == null
            ? 'Data KP berhasil disimpan.'
            : 'Data KP berhasil diperbarui.',
        KpScreen.warnaAksi,
      );
    }
  }

  void _pesan(String teks, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(teks)),
          ],
        ),
        backgroundColor: warna,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _konfirmasiHapus(DataKp kp) async {
    final hapus = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus data KP?'),
        content: Text(
          'Data KP di ${kp.instansi} akan dihapus dari daftar. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (hapus == true && mounted) {
      KpStore.hapus(kp.id);
      _pesan('Data KP dihapus.', Colors.red);
    }
  }

  Future<void> _salinRingkasan(DataKp kp) async {
    final teks = StringBuffer()
      ..writeln('DATA KERJA PRAKTIK')
      ..writeln('Instansi: ${kp.instansi}')
      ..writeln('Judul KP: ${kp.judul}')
      ..writeln('Periode: ${kp.periodeTeks} (${kp.durasiBulan} bulan)')
      ..writeln('Pembimbing Lapangan: ${kp.pembimbingLapangan}')
      ..writeln(
        'Pembimbing Kampus: '
        '${kp.pembimbingKampus.isEmpty ? '-' : kp.pembimbingKampus}',
      )
      ..writeln('Status: ${kp.status.label}');

    await Clipboard.setData(ClipboardData(text: teks.toString()));
    // ignore: use_build_context_synchronously
    if (mounted) _pesan('Ringkasan data KP disalin.', const Color(0xFF1565C0));
  }

  // --------------------------------------------------------------- dokumen
  Future<void> _aturDokumen(DataKp kp) async {
    final tautan = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetDokumen(kp: kp),
    );

    if (tautan == null) return;
    for (final entry in tautan.entries) {
      KpStore.simpanTautan(kp.id, entry.key, entry.value);
    }
    if (mounted) _pesan('Dokumen KP diperbarui.', KpScreen.warnaAksi);
  }

  // ------------------------------------------------------------- bimbingan
  Future<void> _tambahBimbingan(DataKp? kp) async {
    final baru = await showDialog<BimbinganKp>(
      context: context,
      builder: (_) => _DialogBimbingan(kp: kp),
    );

    if (baru == null) return;
    KpStore.tambahBimbingan(baru);
    if (mounted) _pesan('Catatan bimbingan ditambahkan.', KpScreen.warnaAksi);
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Kerja Praktik',
              style: TextStyle(color: p.textPrimary, fontSize: 18),
            ),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
          ),
          body: KontenLayar(
            paddingHp: EdgeInsets.zero,
            paddingLebar: EdgeInsets.zero,
            child: ValueListenableBuilder<List<DataKp>>(
              valueListenable: KpStore.daftar,
              builder: (context, daftar, _) {
                final kp = daftar.isEmpty ? null : daftar.first;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _buildHero(p, kp),
                    const SizedBox(height: 20),
                    _buildJudulBagian(p, 'ALUR KERJA PRAKTIK'),
                    const SizedBox(height: 10),
                    _buildAlur(p, kp),
                    const SizedBox(height: 20),
                    if (kp == null)
                      _buildKosong(p)
                    else ...<Widget>[
                      _buildJudulBagian(p, 'DATA KP'),
                      const SizedBox(height: 10),
                      _buildKartuData(context, p, kp),
                      const SizedBox(height: 20),
                      _buildJudulBagian(
                        p,
                        'DOKUMEN',
                        lencana:
                            '${kp.jumlahDokumenTerisi}/${dokumenKp.length}',
                      ),
                      const SizedBox(height: 10),
                      _buildKartuDokumen(context, p, kp),
                      const SizedBox(height: 20),
                      _buildJudulBimbingan(p),
                      const SizedBox(height: 10),
                      _buildDaftarBimbingan(p, kp),
                    ],
                    if (daftar.length > 1) ...<Widget>[
                      const SizedBox(height: 20),
                      _buildJudulBagian(
                        p,
                        'RIWAYAT KERJA PRAKTIK',
                        lencana: '${daftar.length - 1}',
                      ),
                      const SizedBox(height: 10),
                      for (final lama in daftar.skip(1))
                        _buildKartuRiwayat(context, p, lama),
                    ],
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: _buildFooter(p),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ hero
  Widget _buildHero(AppPalette p, DataKp? kp) {
    final tahapan = tahapanKpUntuk(kp);
    final progres = progresTahapanKp(tahapan);
    final berjalan = tahapan.firstWhere(
      (t) => t.status == StatusTahapanKp.berjalan,
      orElse: () => tahapan.firstWhere(
        (t) => t.status == StatusTahapanKp.belum,
        orElse: () => tahapan.last,
      ),
    );
    final nomor = tahapan.indexOf(berjalan) + 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.30),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_history,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kp == null
                          ? 'Belum ada data KP'
                          : 'Tahap $nomor dari ${tahapan.length}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kp == null ? 'Menunggu pengajuan' : berjalan.nama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progres,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          if (kp != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    kp.instansi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildPilStatus(kp.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event_available,
                  size: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${kp.periodeSingkat} · ${kp.durasiBulan} bulan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              '${AppData.semesterAktif} · isi formulir DATA KP untuk memulai',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPilStatus(StatusKp status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.labelSingkat,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ----------------------------------------------------------- judul bagian
  Widget _buildJudulBagian(AppPalette p, String teks, {String? lencana}) {
    return Row(
      children: [
        // Flexible: judul bagian juga dipakai berdampingan dengan tombol
        // "Tambah" di kepala daftar bimbingan, jadi teksnya harus boleh
        // menyusut supaya tidak meluber di layar sempit.
        Flexible(
          child: Text(
            teks,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: p.textSecondary,
            ),
          ),
        ),
        if (lencana != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              lencana,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: p.accentText,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildJudulBimbingan(AppPalette p) {
    return ValueListenableBuilder<List<BimbinganKp>>(
      valueListenable: KpStore.bimbingan,
      builder: (context, daftar, _) => Row(
        children: [
          Expanded(
            child: _buildJudulBagian(
              p,
              'CATATAN BIMBINGAN',
              lencana: '${daftar.length}x',
            ),
          ),
          TextButton.icon(
            onPressed: () => _tambahBimbingan(KpStore.aktif),
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'Tambah',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              foregroundColor: p.accentText,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ alur
  Widget _buildAlur(AppPalette p, DataKp? kp) {
    final tahapan = tahapanKpUntuk(kp);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        children: [
          for (var i = 0; i < tahapan.length; i++)
            _buildLangkah(p, tahapan[i], i == tahapan.length - 1),
        ],
      ),
    );
  }

  Widget _buildLangkah(AppPalette p, TahapanKp tahap, bool terakhir) {
    final Color warna;
    final IconData ikon;
    switch (tahap.status) {
      case StatusTahapanKp.selesai:
        warna = kHadir;
        ikon = Icons.check;
      case StatusTahapanKp.berjalan:
        warna = p.accent;
        ikon = Icons.play_arrow_rounded;
      case StatusTahapanKp.belum:
        warna = p.textMuted;
        ikon = Icons.circle_outlined;
    }

    final aktif = tahap.status != StatusTahapanKp.belum;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: aktif ? warna : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: aktif ? warna : p.border,
                      width: 1.6,
                    ),
                  ),
                  child: Icon(
                    ikon,
                    size: 14,
                    color: aktif ? Colors.white : p.textMuted,
                  ),
                ),
                if (!terakhir)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: tahap.status == StatusTahapanKp.selesai
                          ? kHadir
                          : p.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tahap.nama,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: aktif ? FontWeight.bold : FontWeight.w600,
                      color: aktif ? p.textPrimary : p.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tahap.keterangan,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- data KP
  Widget _buildKartuData(BuildContext context, AppPalette p, DataKp kp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  kp.judul,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Opsi data KP',
                color: p.card,
                icon: Icon(Icons.more_vert, size: 20, color: p.textSecondary),
                onSelected: (aksi) {
                  switch (aksi) {
                    case 'ubah':
                      _bukaForm(awal: kp);
                    case 'salin':
                      _salinRingkasan(kp);
                    case 'hapus':
                      _konfirmasiHapus(kp);
                    default:
                      if (aksi.startsWith('status:')) {
                        final status = StatusKp.values.firstWhere(
                          (s) => s.name == aksi.substring(7),
                        );
                        KpStore.perbarui(kp.copyWith(status: status));
                        _pesan(
                          'Status KP: ${status.label}.',
                          KpScreen.warnaAksi,
                        );
                      }
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'ubah',
                    child: _buildMenuOpsi(
                      p,
                      Icons.edit_outlined,
                      'Ubah data KP',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'salin',
                    child: _buildMenuOpsi(
                      p,
                      Icons.copy_all_outlined,
                      'Salin ringkasan',
                    ),
                  ),
                  PopupMenuDivider(height: 1, color: p.divider),
                  for (final s in StatusKp.values)
                    PopupMenuItem<String>(
                      value: 'status:${s.name}',
                      child: _buildMenuOpsi(
                        p,
                        s == kp.status
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        'Status: ${s.label}',
                        warna: s == kp.status ? p.accentText : null,
                      ),
                    ),
                  PopupMenuDivider(height: 1, color: p.divider),
                  PopupMenuItem<String>(
                    value: 'hapus',
                    child: _buildMenuOpsi(
                      p,
                      Icons.delete_outline,
                      'Hapus data KP',
                      warna: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBaris(p, Icons.apartment, 'Instansi', kp.instansi),
          _buildBaris(
            p,
            Icons.event_available,
            'Periode',
            '${kp.periodeTeks} · ${kp.durasiBulan} bulan',
          ),
          _buildBaris(
            p,
            Icons.badge_outlined,
            'Pembimbing Lapangan',
            kp.pembimbingLapangan,
          ),
          _buildBaris(
            p,
            Icons.school_outlined,
            'Pembimbing Kampus',
            kp.pembimbingKampus.isEmpty
                ? 'Belum ditetapkan'
                : kp.pembimbingKampus,
            pudar: kp.pembimbingKampus.isEmpty,
          ),
          _buildBaris(p, Icons.event_note, 'Diajukan', kp.tanggalDiajukan),
          if (kp.catatan.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 13,
                    color: p.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      kp.catatan,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: p.textSecondary,
                      ),
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

  Widget _buildMenuOpsi(
    AppPalette p,
    IconData ikon,
    String teks, {
    Color? warna,
  }) {
    return Row(
      children: [
        Icon(ikon, size: 17, color: warna ?? p.textSecondary),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            teks,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: warna ?? p.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildBaris(
    AppPalette p,
    IconData ikon,
    String label,
    String nilai, {
    bool pudar = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 15, color: p.textMuted),
          const SizedBox(width: 8),
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: TextStyle(fontSize: 11.5, color: p.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              nilai,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                fontWeight: pudar ? FontWeight.normal : FontWeight.w600,
                fontStyle: pudar ? FontStyle.italic : FontStyle.normal,
                color: pudar ? p.textSecondary : p.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- dokumen
  Widget _buildKartuDokumen(BuildContext context, AppPalette p, DataKp kp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: kp.progresDokumen,
                    minHeight: 6,
                    backgroundColor: p.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(p.success),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${kp.jumlahDokumenTerisi}/${dokumenKp.length}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: p.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final dok in dokumenKp) ...[
            _buildBarisDokumen(context, p, kp, dok),
            if (dok != dokumenKp.last) const SizedBox(height: 8),
          ],
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _aturDokumen(kp),
              icon: const Icon(Icons.edit_note, size: 16),
              label: const Text(
                'Atur dokumen',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: p.accentText,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarisDokumen(
    BuildContext context,
    AppPalette p,
    DataKp kp,
    DokumenKp dok,
  ) {
    final terisi = kp.dokumenTerisi(dok.id);
    final tautan = kp.tautanDokumen(dok.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            terisi ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: terisi ? p.success : p.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dok.nama,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  terisi ? tautan : dok.keterangan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: terisi ? FontStyle.normal : FontStyle.italic,
                    color: terisi ? p.accentText : p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (terisi)
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: tautan));
                if (context.mounted) {
                  _pesan('Tautan ${dok.nama} disalin.', KpScreen.warnaAksi);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.copy, size: 15, color: p.accentText),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ bimbingan
  Widget _buildDaftarBimbingan(AppPalette p, DataKp kp) {
    return ValueListenableBuilder<List<BimbinganKp>>(
      valueListenable: KpStore.bimbingan,
      builder: (context, daftar, _) {
        if (daftar.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
            decoration: p.cardDeco(borderColor: p.border),
            child: Column(
              children: [
                Icon(Icons.forum_outlined, size: 42, color: p.textMuted),
                const SizedBox(height: 10),
                Text(
                  'Belum ada catatan bimbingan',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tekan "Tambah" untuk mencatat hasil bimbingan bersama '
                  'pembimbing lapangan atau kampus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: p.textSecondary),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: p.cardDeco(borderColor: p.border),
          child: Column(
            children: [
              for (var i = 0; i < daftar.length; i++) ...[
                if (i > 0) Divider(height: 1, indent: 16, color: p.divider),
                ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.forum_outlined,
                      size: 18,
                      color: Colors.teal,
                    ),
                  ),
                  title: Text(
                    daftar[i].topik,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      <String>[
                        daftar[i].tanggalTeks,
                        if (daftar[i].pembimbing.isNotEmpty)
                          daftar[i].pembimbing,
                        if (daftar[i].catatan.isNotEmpty) daftar[i].catatan,
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'Hapus catatan',
                    onPressed: () => KpStore.hapusBimbingan(i),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: p.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------- riwayat
  Widget _buildKartuRiwayat(BuildContext context, AppPalette p, DataKp kp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  kp.instansi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  kp.status.labelSingkat,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: p.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            kp.periodeTeks,
            style: TextStyle(fontSize: 11.5, color: p.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  KpStore.jadikanAktif(kp.id);
                  _pesan('Data KP dijadikan data aktif.', KpScreen.warnaAksi);
                },
                style: TextButton.styleFrom(
                  foregroundColor: p.accentText,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Jadikan aktif',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => _bukaForm(awal: kp),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Ubah',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: p.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- kosong
  Widget _buildKosong(AppPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        children: [
          Icon(Icons.work_off_outlined, size: 48, color: p.textMuted),
          const SizedBox(height: 12),
          Text(
            'Belum ada data KP',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tekan tombol di bawah untuk mengisi formulir DATA KP: instansi, '
            'judul kegiatan, periode, dan pembimbing lapangan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: p.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- tombol
  Widget _buildFooter(AppPalette p) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: p.card,
          border: Border(top: BorderSide(color: p.divider)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _bukaForm(),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text(
              'Tambah Data KP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: KpScreen.warnaAksi,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lembar isian tautan dokumen KP.
///
/// Dibuat sebagai widget sendiri supaya TextEditingController-nya hidup
/// selama animasi keluar bottom sheet. Kalau controller dibuat di pemanggil
/// lalu di-dispose begitu sheet ditutup, TextField yang masih dianimasikan
/// memakai controller yang sudah mati ("used after being disposed").
class _SheetDokumen extends StatefulWidget {
  const _SheetDokumen({required this.kp});

  final DataKp kp;

  @override
  State<_SheetDokumen> createState() => _SheetDokumenState();
}

class _SheetDokumenState extends State<_SheetDokumen> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      for (final dok in dokumenKp)
        dok.id: TextEditingController(text: widget.kp.tautanDokumen(dok.id)),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _simpan() {
    Navigator.of(context).pop(<String, String>{
      for (final dok in dokumenKp) dok.id: _controllers[dok.id]!.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DOKUMEN KP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tempel tautan berkas (Google Drive dsb). Kosongkan atau '
                  'isi "-" kalau dokumennya belum ada.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                for (final dok in dokumenKp) ...[
                  Text(
                    dok.nama,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: p.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _controllers[dok.id],
                    keyboardType: TextInputType.url,
                    style: TextStyle(fontSize: 13, color: p.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'https://drive.google.com/...',
                      hintStyle: TextStyle(fontSize: 12, color: p.textMuted),
                      isDense: true,
                      filled: true,
                      fillColor: p.inputFill,
                      prefixIcon: Icon(
                        Icons.link,
                        size: 18,
                        color: p.textSecondary,
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 42),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: p.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: p.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: p.accent, width: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: p.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _simpan,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KpScreen.warnaAksi,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog "Catatan Bimbingan".
///
/// Sama seperti [_SheetDokumen]: controller & tanggal tinggal di State dialog
/// supaya tidak dipakai setelah di-dispose saat animasi tutup berjalan.
class _DialogBimbingan extends StatefulWidget {
  const _DialogBimbingan({this.kp});

  final DataKp? kp;

  @override
  State<_DialogBimbingan> createState() => _DialogBimbinganState();
}

class _DialogBimbinganState extends State<_DialogBimbingan> {
  final _topikCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  late final TextEditingController _pembimbingCtrl;

  DateTime _tanggal = DateTime.now();

  @override
  void initState() {
    super.initState();
    final kp = widget.kp;
    _pembimbingCtrl = TextEditingController(
      text: (kp != null && kp.pembimbingKampus.isNotEmpty)
          ? kp.pembimbingKampus
          : (kp?.pembimbingLapangan ?? ''),
    );
  }

  @override
  void dispose() {
    _topikCtrl.dispose();
    _catatanCtrl.dispose();
    _pembimbingCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final pilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2010),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (pilih != null) setState(() => _tanggal = pilih);
  }

  void _simpan() {
    final topik = _topikCtrl.text.trim();
    if (topik.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Topik bimbingan wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      BimbinganKp(
        tanggal: _tanggal,
        topik: topik,
        catatan: _catatanCtrl.text.trim(),
        pembimbing: _pembimbingCtrl.text.trim(),
      ),
    );
  }

  InputDecoration _dekorasi(AppPalette p, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 12.5, color: p.textSecondary),
      isDense: true,
      filled: true,
      fillColor: p.inputFill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.accent, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => AlertDialog(
        backgroundColor: p.card,
        title: Text(
          'Catatan Bimbingan',
          style: TextStyle(fontSize: 16, color: p.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: _pilihTanggal,
                icon: Icon(Icons.event, size: 16, color: p.textPrimary),
                label: Text(
                  'Tanggal: ${formatTanggalSingkat(_tanggal)}',
                  style: TextStyle(color: p.textPrimary, fontSize: 12.5),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: p.border),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _topikCtrl,
                style: TextStyle(fontSize: 13, color: p.textPrimary),
                decoration: _dekorasi(p, 'Topik bimbingan'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pembimbingCtrl,
                style: TextStyle(fontSize: 13, color: p.textPrimary),
                decoration: _dekorasi(p, 'Pembimbing'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _catatanCtrl,
                minLines: 2,
                maxLines: 4,
                style: TextStyle(fontSize: 13, color: p.textPrimary),
                decoration: _dekorasi(p, 'Catatan / arahan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal', style: TextStyle(color: p.textSecondary)),
          ),
          TextButton(
            onPressed: _simpan,
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: KpScreen.warnaAksi,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
