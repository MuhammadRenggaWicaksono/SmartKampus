import 'package:flutter/material.dart';
import 'package:app_kampus/akademik/kp_screen.dart';
import 'package:app_kampus/akademik/skripsi_screen.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/konten_layar.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/data/kp_store.dart';
import 'package:app_kampus/data/skripsi_store.dart';
import 'package:app_kampus/studi/entri_krs_screen.dart';
import 'package:app_kampus/studi/lihat_krs_screen.dart';
import 'package:app_kampus/studi/lihat_khs_screen.dart';
import 'package:app_kampus/studi/transkrip_screen.dart';

/// Menu Akademik: KRS, Hasil Studi & Nilai, serta Tugas Akhir & Praktik.
class AkademikScreen extends StatelessWidget {
  const AkademikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Akademik',
              style: TextStyle(color: p.textPrimary, fontSize: 18),
            ),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            elevation: 0.5,
            automaticallyImplyLeading: false,
            iconTheme: IconThemeData(color: p.textPrimary),
          ),
          // Bantalan pegang ListView sendiri (persis seperti sebelum
          // dibungkus) supaya tampilan HP tidak bergeser; KontenLayar
          // hanya menambah bantalan saat jendela lebar.
          body: KontenLayar(
            paddingHp: EdgeInsets.zero,
            paddingLebar: const EdgeInsets.all(12),
            child: ValueListenableBuilder<List<PengajuanSkripsi>>(
              valueListenable: SkripsiStore.pengajuan,
              builder: (context, pengajuanSkripsi, _) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _buildRingkasan(p),
                  const SizedBox(height: 22),

                  // --- KELOMPOK 1: KRS ---
                  _buildSectionHeader(
                    p,
                    ikon: Icons.edit_note,
                    warna: Colors.orange,
                    judul: 'Kartu Rencana Studi (KRS)',
                    keterangan: 'Pengisian dan riwayat rencana studi',
                  ),
                  const SizedBox(height: 10),
                  _buildMenuGroup(
                    p,
                    children: [
                      _buildMenuItem(
                        context,
                        p,
                        ikon: Icons.edit_document,
                        warna: Colors.orange,
                        judul: 'Entri KRS',
                        keterangan: 'Ajukan atau ubah KRS semester berjalan',
                        lencana: 'Belum diajukan',
                        warnaLencana: p.warning,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const IsiKrsScreen(),
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        context,
                        p,
                        ikon: Icons.assignment_turned_in,
                        warna: Colors.blue,
                        judul: 'Lihat KRS',
                        keterangan: 'Daftar mata kuliah yang sudah diambil',
                        lencana: '${AppData.sksSemesterIni} SKS',
                        warnaLencana: p.accent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LihatKrsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // --- KELOMPOK 2: NILAI ---
                  _buildSectionHeader(
                    p,
                    ikon: Icons.workspace_premium_outlined,
                    warna: Colors.green,
                    judul: 'Hasil Studi & Nilai',
                    keterangan: 'Nilai akhir, IPS, dan rekap beban SKS',
                  ),
                  const SizedBox(height: 10),
                  _buildMenuGroup(
                    p,
                    children: [
                      _buildMenuItem(
                        context,
                        p,
                        ikon: Icons.grade,
                        warna: Colors.green,
                        judul: 'Lihat KHS',
                        keterangan: 'Nilai per mata kuliah beserta IPS',
                        lencana: 'IPS ${AppData.ipk.toStringAsFixed(2)}',
                        warnaLencana: p.success,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LihatKhsScreen(),
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        context,
                        p,
                        ikon: Icons.analytics,
                        warna: Colors.purple,
                        judul: 'Rekap Nilai',
                        keterangan: 'Transkrip dan total SKS yang ditempuh',
                        lencana: '${AppData.sksDitempuh} SKS',
                        warnaLencana: p.accent,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TranskripScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // --- KELOMPOK 3: TUGAS AKHIR & PRAKTIK ---
                  _buildSectionHeader(
                    p,
                    ikon: Icons.rocket_launch_outlined,
                    warna: Colors.teal,
                    judul: 'Tugas Akhir & Praktik',
                    keterangan: 'Kerja Praktik, KKN, dan penyusunan skripsi',
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<List<DataKp>>(
                    valueListenable: KpStore.daftar,
                    builder: (context, daftarKp, _) {
                      final kp = daftarKp.isEmpty ? null : daftarKp.first;
                      return _buildMenuGroup(
                        p,
                        children: [
                          _buildMenuItem(
                            context,
                            p,
                            ikon: Icons.work_history,
                            warna: Colors.teal,
                            judul: 'Kerja Praktik (KP)',
                            keterangan: kp == null
                                ? 'Isi DATA KP: instansi, judul, dan periode'
                                : '${kp.instansi} · ${kp.periodeSingkat}',
                            lencana: kp == null
                                ? 'Belum diisi'
                                : kp.status.labelSingkat,
                            warnaLencana: kp == null
                                ? p.warning
                                : _warnaStatusKp(p, kp.status),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const KpScreen(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            context,
                            p,
                            ikon: Icons.groups,
                            warna: Colors.brown,
                            judul: 'KKN',
                            keterangan: 'Kuliah Kerja Nyata tematik',
                            lencana: 'Segera',
                            warnaLencana: p.textMuted,
                            onTap: () => _belumTersedia(context, p, 'KKN'),
                          ),
                          _buildMenuItem(
                            context,
                            p,
                            ikon: Icons.school,
                            warna: Colors.indigo,
                            judul: 'Skripsi',
                            keterangan:
                                'Pengajuan judul, pembimbing, dan tahapan',
                            lencana: pengajuanSkripsi.isEmpty
                                ? 'Belum diajukan'
                                : '${pengajuanSkripsi.length} judul diajukan',
                            warnaLencana: pengajuanSkripsi.isEmpty
                                ? p.warning
                                : p.accent,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SkripsiScreen(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Warna lencana status KP di menu Akademik.
  Color _warnaStatusKp(AppPalette p, StatusKp status) {
    return switch (status) {
      StatusKp.menunggu => p.warning,
      StatusKp.disetujui => p.accentText,
      StatusKp.berjalan => Colors.teal,
      StatusKp.selesai => p.success,
      StatusKp.ditolak => p.danger,
    };
  }

  void _belumTersedia(BuildContext context, AppPalette p, String nama) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('Menu $nama belum tersedia')),
          ],
        ),
        backgroundColor: p.textMuted,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ------------------------------------------------------- kartu ringkasan
  Widget _buildRingkasan(AppPalette p) {
    return LayoutBuilder(
      builder: (context, c) {
        final lebar = c.maxWidth;
        return Container(
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.border),
            boxShadow: [
              BoxShadow(
                color: p.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: lebar >= 720 ? _bangunKartuLebar(p) : _bangunKartuSemua(p),
        );
      },
    );
  }

  // Layout sempit (HP): header di atas, tiga pilar statistik lalu bilah
  // kelulusan di bawah.
  Widget _bangunKartuSemua(AppPalette p) {
    final sksDitempuh = AppData.sksDitempuh;
    final sksTarget = kSksTargetLulus;
    final progresSks = (sksDitempuh / sksTarget).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bangunKartuHeader(p),
        Divider(height: 1, thickness: 1, color: p.divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            children: [
              Expanded(
                child: _buildPilarStat(
                  p,
                  label: 'IPK',
                  nilai: AppData.ipk.toStringAsFixed(2),
                  sublabel: 'Skala 4.00',
                  warnaNilai: p.accentText,
                  ikon: Icons.grade_rounded,
                  warnaIkon: Colors.amber.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPilarStat(
                  p,
                  label: 'TOTAL SKS',
                  nilai: '$sksDitempuh',
                  sublabel: 'dari $sksTarget SKS',
                  warnaNilai: p.textPrimary,
                  ikon: Icons.timer_outlined,
                  warnaIkon: Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPilarStat(
                  p,
                  label: 'MATAKULIAH',
                  nilai: '${AppData.mataKuliahAktif.length}',
                  sublabel: 'Semester ini',
                  warnaNilai: p.textPrimary,
                  ikon: Icons.menu_book_rounded,
                  warnaIkon: Colors.indigo,
                ),
              ),
            ],
          ),
        ),
        _bangunKartuProgres(p, progresSks),
      ],
    );
  }

  // Layout lebar (Web/laptop): identitas semester di kiri, tiga metrik di
  // kanan, dipisah garis tipis — tidak ada lagi tiga kotak sempit tertancap
  // di tengah kartu yang kosong.
  Widget _bangunKartuLebar(AppPalette p) {
    final sksDitempuh = AppData.sksDitempuh;
    final sksTarget = kSksTargetLulus;
    final progresSks = (sksDitempuh / sksTarget).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kiri: semester & progres kelulusan
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bangunChipSemester(p),
                const SizedBox(height: 12),
                Text(
                  AppData.semesterAktif,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Kelulusan SKS',
                      style: TextStyle(
                        fontSize: 12,
                        color: p.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(progresSks * 100).toInt()}% selesai',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: p.accentText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: LinearProgressIndicator(
                    value: progresSks,
                    minHeight: 8,
                    backgroundColor: p.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(p.accent),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$sksDitempuh dari $sksTarget SKS yang ditempuh',
                  style: TextStyle(fontSize: 11.5, color: p.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 28),
          Container(width: 1, height: 118, color: p.divider),
          const SizedBox(width: 28),
          // Kanan: tiga metrik utama
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildPilarStat(
                    p,
                    label: 'IPK',
                    nilai: AppData.ipk.toStringAsFixed(2),
                    sublabel: 'Skala 4.00',
                    warnaNilai: p.accentText,
                    ikon: Icons.grade_rounded,
                    warnaIkon: Colors.amber.shade700,
                  ),
                ),
                _pemisahMetrik(p),
                Expanded(
                  child: _buildPilarStat(
                    p,
                    label: 'TOTAL SKS',
                    nilai: '$sksDitempuh',
                    sublabel: 'dari $sksTarget SKS',
                    warnaNilai: p.textPrimary,
                    ikon: Icons.timer_outlined,
                    warnaIkon: Colors.teal,
                  ),
                ),
                _pemisahMetrik(p),
                Expanded(
                  child: _buildPilarStat(
                    p,
                    label: 'MATAKULIAH',
                    nilai: '${AppData.mataKuliahAktif.length}',
                    sublabel: 'Semester ini',
                    warnaNilai: p.textPrimary,
                    ikon: Icons.menu_book_rounded,
                    warnaIkon: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunKartuHeader(AppPalette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bangunChipSemester(p),
                const SizedBox(height: 8),
                Text(
                  AppData.semesterAktif,
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              shape: BoxShape.circle,
              border: Border.all(color: p.border),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: p.accentText,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunChipSemester(AppPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: p.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 13, color: p.accentText),
          const SizedBox(width: 5),
          Text(
            'SEMESTER ${AppData.sksPerSemester.length}',
            style: TextStyle(
              color: p.accentText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunKartuProgres(AppPalette p, double progresSks) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kelulusan SKS',
                style: TextStyle(
                  fontSize: 11,
                  color: p.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progresSks * 100).toInt()}% selesai',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: p.accentText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progresSks,
              minHeight: 6,
              backgroundColor: p.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(p.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pemisahMetrik(AppPalette p) {
    return Container(
      width: 1,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: p.divider,
    );
  }

  Widget _buildPilarStat(
    AppPalette p, {
    required String label,
    required String nilai,
    required String sublabel,
    required Color warnaNilai,
    required IconData ikon,
    required Color warnaIkon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, size: 12, color: warnaIkon),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              nilai,
              style: TextStyle(
                color: warnaNilai,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------- judul kelompok
  Widget _buildSectionHeader(
    AppPalette p, {
    required IconData ikon,
    required Color warna,
    required String judul,
    required String keterangan,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(ikon, size: 17, color: warna),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  keterangan,
                  style: TextStyle(fontSize: 11, color: p.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ grup menu
  Widget _buildMenuGroup(AppPalette p, {required List<Widget> children}) {
    return Container(
      decoration: p.cardDeco(radius: 16, borderColor: p.border),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 60, color: p.divider),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    AppPalette p, {
    required IconData ikon,
    required Color warna,
    required String judul,
    required String keterangan,
    required VoidCallback onTap,
    String? lencana,
    Color? warnaLencana,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      warna.withValues(alpha: 0.22),
                      warna.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(ikon, color: warna, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      keterangan,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.3,
                        color: p.textSecondary,
                      ),
                    ),
                    if (lencana != null) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (warnaLencana ?? p.accent).withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          lencana,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: warnaLencana ?? p.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(Icons.chevron_right, color: p.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
