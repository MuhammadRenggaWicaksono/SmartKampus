import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';

/// Rekap presensi per mata kuliah.
///
/// Sebelumnya halaman ini hanya menampilkan halaman error
/// ("Presensi tidak dapat ditampilkan" / "unauthorize view") dan tidak ikut
/// tema global, jadi tetap putih menyala di Dark Mode.
class PresensiScreen extends StatelessWidget {
  const PresensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Presensi Kuliah',
                style: TextStyle(color: p.textPrimary, fontSize: 18),
              ),
              backgroundColor: p.card,
              foregroundColor: p.textPrimary,
              iconTheme: IconThemeData(color: p.textPrimary),
              elevation: 0.5,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRingkasan(p),
                const SizedBox(height: 20),
                Text(
                  'RINCIAN PER MATA KULIAH',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ...AppData.mataKuliahAktif.map((mk) => _buildKartuMk(p, mk)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRingkasan(AppPalette p) {
    final hadir = AppData.totalHadir;
    final total = AppData.totalPertemuanTerlaksana;
    final persen = AppData.persenKehadiran;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: p.cardDeco(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (persen >= 75 ? kHadir : kAlpa).withValues(alpha: 0.15),
                ),
                child: Text(
                  '$persen%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: persen >= 75 ? kHadir : kAlpa,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kehadiran Semester Ini',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$hadir hadir dari $total pertemuan yang sudah terlaksana',
                      style: TextStyle(fontSize: 12, color: p.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rencana ${AppData.totalPertemuanRencana} pertemuan '
                      '($kRencanaTatapMuka x ${AppData.mataKuliahAktif.length} mata kuliah)',
                      style: TextStyle(fontSize: 11, color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildStat(p, kHadir, 'Hadir', AppData.totalHadir),
              _buildStat(p, kSakit, 'Sakit', AppData.totalSakit),
              _buildStat(p, kIzin, 'Izin', AppData.totalIzin),
              _buildStat(p, kAlpa, 'Alpa', AppData.totalAlpa),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(AppPalette p, Color warna, String label, int nilai) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$nilai',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: warna,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: p.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuMk(AppPalette p, MataKuliahAktif mk) {
    final rawan = mk.persenTerhadapRencana < 75;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: p.cardDeco(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mk.nama,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${mk.kode} • Kelas ${mk.kelas} • ${mk.sks} SKS',
                      style: TextStyle(fontSize: 11, color: p.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (rawan ? kAlpa : kHadir).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rawan ? 'RAWAN' : '${mk.persenHadir}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: rawan ? kAlpa : kHadir,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBarPresensi(p, mk),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${mk.terlaksana}/$kRencanaTatapMuka pertemuan',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.textPrimary,
                ),
              ),
              Text(
                'H ${mk.hadir} · S ${mk.sakit} · I ${mk.izin} · A ${mk.alpa}',
                style: TextStyle(fontSize: 11, color: p.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bar bertumpuk: proporsi hadir/sakit/izin/alpa terhadap rencana 16x.
  Widget _buildBarPresensi(AppPalette p, MataKuliahAktif mk) {
    final sisa = kRencanaTatapMuka - mk.terlaksana;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            if (mk.hadir > 0)
              Expanded(flex: mk.hadir, child: ColoredBox(color: kHadir)),
            if (mk.sakit > 0)
              Expanded(flex: mk.sakit, child: ColoredBox(color: kSakit)),
            if (mk.izin > 0)
              Expanded(flex: mk.izin, child: ColoredBox(color: kIzin)),
            if (mk.alpa > 0)
              Expanded(flex: mk.alpa, child: ColoredBox(color: kAlpa)),
            if (sisa > 0)
              Expanded(flex: sisa, child: ColoredBox(color: p.surfaceAlt)),
          ],
        ),
      ),
    );
  }
}
