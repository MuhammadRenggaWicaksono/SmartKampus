import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';

enum ChartMode { absensi }

/// Kartu "Statistik Akademik": rekap kehadiran memakai **angka pasti**
/// (jumlah pertemuan), bukan persen.
///
/// Mengikuti tampilan website legacy kampus: setiap status — Hadir, Sakit,
/// Izin, Alpa — ditampilkan terpisah per mata kuliah supaya pembaca tidak
/// menebak status mana yang "hilang" di balik satu persentase gabungan.
class StatistikChart extends StatelessWidget {
  const StatistikChart({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: p.cardDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(p),
              const SizedBox(height: 16),
              _buildRingkasan(p),
              const SizedBox(height: 4),
              const Divider(height: 26),
              for (final mk in AppData.mataKuliahAktif) _buildBaris(p, mk),
              const SizedBox(height: 6),
              _buildCatatan(p),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------- header
  Widget _buildHeader(AppPalette p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: p.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.insights, color: p.accent, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistik Akademik',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  height: 1.2,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Rekap kehadiran semester ini — jumlah pertemuan',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.25,
                  color: p.textCardSupport,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------- ringkasan total (angka)
  Widget _buildRingkasan(AppPalette p) {
    return Row(
      children: [
        _ringkasanSel(p, 'Hadir', AppData.totalHadir, kHadir),
        const SizedBox(width: 8),
        _ringkasanSel(p, 'Sakit', AppData.totalSakit, kSakit),
        const SizedBox(width: 8),
        _ringkasanSel(p, 'Izin', AppData.totalIzin, kIzin),
        const SizedBox(width: 8),
        _ringkasanSel(p, 'Alpa', AppData.totalAlpa, kAlpa),
      ],
    );
  }

  Widget _ringkasanSel(AppPalette p, String label, int nilai, Color warna) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: warna,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.textCardSupport,
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
                '$nilai',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 22,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  color: p.statusInk(warna),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------- rincian per mata kuliah
  Widget _buildBaris(AppPalette p, MataKuliahAktif mk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mk.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: p.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Pertemuan yang sudah terlaksana dari rencana 16.
              Text(
                '${mk.terlaksana}/$kRencanaTatapMuka',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: p.textChartAxis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _selKategori(p, 'Hadir', mk.hadir, kHadir),
              const SizedBox(width: 8),
              _selKategori(p, 'Sakit', mk.sakit, kSakit),
              const SizedBox(width: 8),
              _selKategori(p, 'Izin', mk.izin, kIzin),
              const SizedBox(width: 8),
              _selKategori(p, 'Alpa', mk.alpa, kAlpa),
            ],
          ),
        ],
      ),
    );
  }

  /// Satu status dengan angkanya sendiri — sengaja tidak digabung dengan
  /// status lain supaya tiap kategori terbaca jelas.
  Widget _selKategori(AppPalette p, String label, int nilai, Color warna) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: p.textCardSupport,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$nilai',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: p.statusInk(warna),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatatan(AppPalette p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 14, color: p.textChartAxis),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Angka adalah jumlah pertemuan. Hadir, sakit, izin, dan alpa '
            'dihitung terpisah. Batas kehadiran minimal setara 12 dari '
            '$kRencanaTatapMuka pertemuan.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: p.textCardSupport,
            ),
          ),
        ),
      ],
    );
  }
}

/// Menggambar garis putus-putus antara [a] dan [b].
///
/// Dipakai grafik IPS di kartu ini dan sparkline IPK di dashboard
/// (`dashboard_screen.dart`), jadi sengaja publik.
void garisPutus(
  Canvas canvas,
  Offset a,
  Offset b,
  Paint paint, {
  double dash = 5,
  double gap = 4,
}) {
  final total = (b - a).distance;
  if (total <= 0) return;
  final arah = (b - a) / total;
  var jalan = 0.0;
  while (jalan < total) {
    final akhir = math.min(jalan + dash, total);
    canvas.drawLine(a + arah * jalan, a + arah * akhir, paint);
    jalan = akhir + gap;
  }
}
