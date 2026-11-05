import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_kampus/akademik/tambah_judul_skripsi_screen.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/data/skripsi_store.dart';

/// Halaman Skripsi: tahapan, pembimbing, dan daftar pengajuan judul.
class SkripsiScreen extends StatelessWidget {
  const SkripsiScreen({super.key});

  static const Color warnaAksi = Color(0xFF22C55E);

  Future<void> _bukaForm(BuildContext context) async {
    final tersimpan = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TambahJudulSkripsiScreen()),
    );

    if (tersimpan == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Judul skripsi berhasil diajukan.')),
            ],
          ),
          backgroundColor: warnaAksi,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Skripsi',
              style: TextStyle(color: p.textPrimary, fontSize: 18),
            ),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
          ),
          body: ValueListenableBuilder<List<PengajuanSkripsi>>(
            valueListenable: SkripsiStore.pengajuan,
            builder: (context, daftar, _) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildHero(p, daftar),
                const SizedBox(height: 20),
                _buildJudulBagian(p, 'ALUR PENYUSUNAN SKRIPSI'),
                const SizedBox(height: 10),
                _buildAlur(p),
                const SizedBox(height: 20),
                _buildJudulBagian(p, 'PEMBIMBING'),
                const SizedBox(height: 10),
                _buildPembimbing(p),
                const SizedBox(height: 20),
                _buildJudulBagian(
                  p,
                  'PENGAJUAN JUDUL',
                  lencana: '${daftar.length}',
                ),
                const SizedBox(height: 10),
                if (daftar.isEmpty)
                  _buildKosong(p)
                else
                  ...daftar.map((item) => _buildKartuPengajuan(context, p, item)),
              ],
            ),
          ),
          bottomNavigationBar: _buildTombolTambah(context, p),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- hero
  Widget _buildHero(AppPalette p, List<PengajuanSkripsi> daftar) {
    final selesai = tahapanSkripsi
        .where((t) => t.status == StatusTahapan.selesai)
        .length;
    final berjalan = tahapanSkripsi.firstWhere(
      (t) => t.status == StatusTahapan.berjalan,
      orElse: () => tahapanSkripsi.last,
    );
    final nomorTahap = tahapanSkripsi.indexOf(berjalan) + 1;
    final progres = (selesai + 1) / tahapanSkripsi.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.32),
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
                  Icons.school_outlined,
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
                      'Tahap $nomorTahap dari ${tahapanSkripsi.length}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      berjalan.nama,
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
              value: progres.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${AppData.semesterAktif} · ${daftar.length} judul diajukan',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------- judul bagian
  Widget _buildJudulBagian(AppPalette p, String teks, {String? lencana}) {
    return Row(
      children: [
        Text(
          teks,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: p.textSecondary,
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
                color: p.accent,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------- alur
  Widget _buildAlur(AppPalette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        children: [
          for (var i = 0; i < tahapanSkripsi.length; i++)
            _buildLangkah(p, tahapanSkripsi[i], i == tahapanSkripsi.length - 1),
        ],
      ),
    );
  }

  Widget _buildLangkah(AppPalette p, TahapanSkripsi tahap, bool terakhir) {
    final Color warna;
    final IconData ikon;
    switch (tahap.status) {
      case StatusTahapan.selesai:
        warna = kHadir;
        ikon = Icons.check;
      case StatusTahapan.berjalan:
        warna = p.accent;
        ikon = Icons.play_arrow_rounded;
      case StatusTahapan.belum:
        warna = p.textMuted;
        ikon = Icons.circle_outlined;
    }

    final aktif = tahap.status != StatusTahapan.belum;

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
                      color: tahap.status == StatusTahapan.selesai
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

  // ----------------------------------------------------------- pembimbing
  Widget _buildPembimbing(AppPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        children: [
          for (var i = 0; i < pembimbingSkripsi.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 16, color: p.divider),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Colors.indigo,
                      ),
                    ),
                    title: Text(
                      pembimbingSkripsi[i].peran,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: p.textSecondary,
                      ),
                    ),
                    subtitle: Text(
                      pembimbingSkripsi[i].sudahDitetapkan
                          ? pembimbingSkripsi[i].nama
                          : 'Belum ditetapkan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontStyle: pembimbingSkripsi[i].sudahDitetapkan
                            ? FontStyle.normal
                            : FontStyle.italic,
                        color: p.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 13, color: p.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pembimbing ditetapkan setelah judul disetujui Program Studi.',
                    style: TextStyle(fontSize: 11, color: p.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------- pengajuan
  Widget _buildKartuPengajuan(
    BuildContext context,
    AppPalette p,
    PengajuanSkripsi item,
  ) {
    final Color warnaStatus;
    switch (item.status) {
      case StatusSkripsi.menunggu:
        warnaStatus = p.warning;
      case StatusSkripsi.disetujui:
        warnaStatus = p.success;
      case StatusSkripsi.ditolak:
        warnaStatus = p.danger;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: 14, color: p.textSecondary),
              const SizedBox(width: 5),
              // Expanded supaya tanggal tidak menabrak lencana status kalau
              // teksnya panjang / ukuran font pengguna diperbesar.
              Expanded(
                child: Text(
                  item.tanggalDiajukan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: p.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: warnaStatus.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: warnaStatus,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.judul,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              fontWeight: FontWeight.bold,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.attach_file, size: 13, color: p.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${item.jumlahBerkasNyata} dari 3 berkas terisi',
                style: TextStyle(fontSize: 11, color: p.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < item.daftarBerkas.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _buildBarisBerkas(context, p, i + 1, item.daftarBerkas[i]),
          ],
          if (item.catatan.isNotEmpty) ...[
            const SizedBox(height: 12),
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
                  Icon(Icons.sticky_note_2_outlined, size: 13, color: p.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.catatan,
                      style: TextStyle(fontSize: 11, color: p.textSecondary),
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

  Widget _buildBarisBerkas(
    BuildContext context,
    AppPalette p,
    int nomor,
    String tautan,
  ) {
    final kosong = tautan.trim().isEmpty || tautan.trim() == '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (kosong ? p.textMuted : p.accent).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$nomor',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: kosong ? p.textMuted : p.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              kosong ? 'Tidak ada berkas' : tautan,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontStyle: kosong ? FontStyle.italic : FontStyle.normal,
                color: kosong ? p.textMuted : p.textPrimary,
              ),
            ),
          ),
          if (!kosong)
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                Clipboard.setData(ClipboardData(text: tautan));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Link berkas $nomor disalin.'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
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

  Widget _buildKosong(AppPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 48, color: p.textMuted),
          const SizedBox(height: 12),
          Text(
            'Belum ada pengajuan judul',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tekan tombol di bawah untuk mengajukan judul skripsi beserta '
            'link berkas pendukung.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: p.textSecondary),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- tombol
  Widget _buildTombolTambah(BuildContext context, AppPalette p) {
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
            onPressed: () => _bukaForm(context),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text(
              'Tambah Judul Skripsi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: warnaAksi,
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
