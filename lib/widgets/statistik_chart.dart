import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';

enum ChartMode { absensi }

/// Kartu statistik akademik dengan grafik absensi saja.
///
/// Grafik digambar manual pakai CustomPainter — tanpa package tambahan.
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
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                width: double.infinity,
                child: CustomPaint(
                  painter: _AbsensiChartPainter(
                    data: AppData.mataKuliahAktif,
                    p: p,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildLegend(p),
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
                _subtitle(),
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

  String _subtitle() =>
      'Kehadiran ${AppData.persenKehadiran}% · '
      '${AppData.totalAbsen} kali tidak hadir dari '
      '${AppData.totalPertemuanTerlaksana} pertemuan';

  Widget _buildLegend(AppPalette p) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _legendItem(p, kHadir, 'Hadir ${AppData.totalHadir}'),
        _legendItem(p, kSakit, 'Sakit ${AppData.totalSakit}'),
        _legendItem(p, kIzin, 'Izin ${AppData.totalIzin}'),
        _legendItem(p, kAlpa, 'Alpa ${AppData.totalAlpa}'),
      ],
    );
  }

  Widget _legendItem(AppPalette p, Color warna, String teks) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        // Flexible + ellipsis supaya teks legenda panjang tidak pernah
        // membuat RenderFlex overflow di layar sempit.
        Flexible(
          child: Text(
            teks,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: p.textCardSupport,
            ),
          ),
        ),
      ],
    );
  }
}

// Ukuran teks pada label grafik absensi.
abstract final class _Fs {
  static const double sumbu = 12;
  static const double label = 13;
}

TextPainter _tp(String teks, TextStyle gaya, {double? maxWidth}) {
  final tp = TextPainter(
    text: TextSpan(text: teks, style: gaya),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '...',
  );
  tp.layout(maxWidth: maxWidth ?? double.infinity);
  return tp;
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

class _AbsensiChartPainter extends CustomPainter {
  final List<MataKuliahAktif> data;
  final AppPalette p;

  _AbsensiChartPainter({required this.data, required this.p});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final gayaAngka = TextStyle(
      fontSize: _Fs.label,
      fontWeight: FontWeight.bold,
      color: p.textPrimary,
    );
    final gayaKuartal = TextStyle(fontSize: _Fs.sumbu, color: p.textChartAxis);
    final tpAngka = _tp('100%', gayaAngka);
    final tpKuartal = _tp('16', gayaKuartal);

    // Kolom angka kanan & ruang penanda kuartal dihitung dari lebar teks
    // aslinya. Dengan lebar tetap (42dp / 40dp), label kuartal '16' di ujung
    // sumbu masuk ke kolom angka begitu fontnya dinaikkan ke 12-13pt.
    final kanan = tpAngka.width + tpKuartal.width / 2 + 12;
    final atas = tpKuartal.height + 8;
    const bawah = 10.0;
    final lebarLabel = math.min(size.width * 0.38, 126.0);
    final xAwal = lebarLabel + 6;
    final lebarBar = size.width - xAwal - kanan;
    if (lebarBar <= 0) return;

    final tinggiIsi = size.height - atas - bawah;
    if (tinggiIsi <= 0) return;
    final tinggiBaris = tinggiIsi / data.length;
    final tinggiBar = math.min(tinggiBaris * 0.52, 13.0);
    final skala = lebarBar / kRencanaTatapMuka;

    for (final kuartal in <int>[4, 8, 12, 16]) {
      final x = xAwal + skala * kuartal;
      canvas.drawLine(
        Offset(x, atas - 4),
        Offset(x, atas + tinggiIsi),
        Paint()
          ..color = p.border.withValues(alpha: 0.45)
          ..strokeWidth = 1,
      );
      final tp = _tp('$kuartal', gayaKuartal);
      tp.paint(canvas, Offset(x - tp.width / 2, atas - tpKuartal.height - 2));
    }

    for (var i = 0; i < data.length; i++) {
      final mk = data[i];
      final tengah = atas + tinggiBaris * i + tinggiBaris / 2;
      final y = tengah - tinggiBar / 2;

      final tpNama = _tp(
        mk.nama,
        TextStyle(
          fontSize: _Fs.label,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        maxWidth: lebarLabel,
      );
      tpNama.paint(canvas, Offset(0, tengah - tpNama.height / 2));

      final jalur = RRect.fromRectAndRadius(
        Rect.fromLTWH(xAwal, y, lebarBar, tinggiBar),
        Radius.circular(tinggiBar / 2),
      );
      canvas.drawRRect(jalur, Paint()..color = p.surfaceAlt);

      canvas.save();
      canvas.clipRRect(jalur);
      var x = xAwal;
      final segmen = <(Color, int)>[
        (kHadir, mk.hadir),
        (kSakit, mk.sakit),
        (kIzin, mk.izin),
        (kAlpa, mk.alpa),
      ];
      for (final (warna, jumlah) in segmen) {
        if (jumlah <= 0) continue;
        final lebarSegmen = skala * jumlah;
        canvas.drawRect(
          Rect.fromLTWH(x, y, lebarSegmen, tinggiBar),
          Paint()..color = warna,
        );
        x += lebarSegmen;
      }
      canvas.restore();

      final tpNilai = _tp(
        '${mk.persenHadir}%',
        TextStyle(
          fontSize: _Fs.label,
          fontWeight: FontWeight.bold,
          color: mk.persenHadir >= 75 ? p.textPrimary : p.danger,
        ),
      );
      tpNilai.paint(
        canvas,
        Offset(size.width - tpNilai.width, tengah - tpNilai.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_AbsensiChartPainter old) =>
      old.data != data || old.p.mode != p.mode;
}
