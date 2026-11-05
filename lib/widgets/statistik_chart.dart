import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';

enum ChartMode { ips, pertemuan, absensi }

/// Kartu statistik akademik dengan 3 tampilan grafik yang bisa diganti
/// lewat tombol tepat di atas grafik:
///   - IPS 1-8          (grafik garis)
///   - Tatap Muka       (progress rencana 16x pertemuan per mata kuliah)
///   - Absensi          (komposisi hadir / sakit / izin / alpa)
///
/// Semua digambar manual pakai CustomPainter — tidak perlu package tambahan.
class StatistikChart extends StatefulWidget {
  const StatistikChart({super.key});

  @override
  State<StatistikChart> createState() => _StatistikChartState();
}

class _StatistikChartState extends State<StatistikChart> {
  ChartMode _mode = ChartMode.ips;

  void _pilih(ChartMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
  }

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
              const SizedBox(height: 14),
              _buildTabs(p),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: SizedBox(
                  key: ValueKey<ChartMode>(_mode),
                  height: 250,
                  width: double.infinity,
                  child: CustomPaint(painter: _painterUntuk(p)),
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

  CustomPainter _painterUntuk(AppPalette p) {
    switch (_mode) {
      case ChartMode.ips:
        return _IpsChartPainter(
          data: AppData.riwayatIps,
          target: AppData.targetIps,
          p: p,
        );
      case ChartMode.pertemuan:
        return _PertemuanChartPainter(data: AppData.mataKuliahAktif, p: p);
      case ChartMode.absensi:
        return _AbsensiChartPainter(data: AppData.mataKuliahAktif, p: p);
    }
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
                  fontSize: 16,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _subtitle(),
                style: TextStyle(fontSize: 11.5, color: p.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _subtitle() {
    switch (_mode) {
      case ChartMode.ips:
        final dinilai =
            AppData.riwayatIps.where((s) => s.sudahAdaNilai).toList();
        return 'IPS ${dinilai.length} semester dari 8 · target '
            '${AppData.targetIps.toStringAsFixed(2)}';
      case ChartMode.pertemuan:
        return 'Rencana ${kRencanaTatapMuka}x tatap muka per mata kuliah · '
            '${AppData.totalPertemuanTerlaksana}/${AppData.totalPertemuanRencana} terlaksana';
      case ChartMode.absensi:
        return 'Kehadiran ${AppData.persenKehadiran}% · '
            '${AppData.totalAbsen} kali tidak hadir dari ${AppData.totalPertemuanTerlaksana} pertemuan';
    }
  }

  // ------------------------------------------------------------ tab tombol
  Widget _buildTabs(AppPalette p) {
    return Row(
      children: [
        _buildTab(p, ChartMode.ips, 'IPS 1-8', Icons.show_chart),
        const SizedBox(width: 8),
        _buildTab(p, ChartMode.pertemuan, 'Tatap Muka', Icons.event_available),
        const SizedBox(width: 8),
        _buildTab(p, ChartMode.absensi, 'Absensi', Icons.fact_check_outlined),
      ],
    );
  }

  Widget _buildTab(AppPalette p, ChartMode mode, String label, IconData ikon) {
    final aktif = _mode == mode;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _pilih(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
            decoration: BoxDecoration(
              color: aktif ? p.accent : p.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: aktif ? p.accent : p.border),
            ),
            child: Column(
              children: [
                Icon(
                  ikon,
                  size: 16,
                  color: aktif ? Colors.white : p.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: aktif ? Colors.white : p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- legenda
  Widget _buildLegend(AppPalette p) {
    switch (_mode) {
      case ChartMode.ips:
        final dinilai =
            AppData.riwayatIps.where((s) => s.sudahAdaNilai).toList();
        final tertinggi = dinilai.isEmpty
            ? null
            : dinilai.reduce((a, b) => a.ips! >= b.ips! ? a : b);
        final terendah = dinilai.isEmpty
            ? null
            : dinilai.reduce((a, b) => a.ips! <= b.ips! ? a : b);
        final sisa = AppData.riwayatIps.length - dinilai.length;

        return Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            if (tertinggi != null)
              _legendItem(
                p,
                p.success,
                'Tertinggi ${tertinggi.ips!.toStringAsFixed(2)} (Sem ${tertinggi.semester})',
              ),
            if (terendah != null)
              _legendItem(
                p,
                p.warning,
                'Terendah ${terendah.ips!.toStringAsFixed(2)} (Sem ${terendah.semester})',
              ),
            if (sisa > 0)
              _legendItem(p, p.textMuted, '$sisa semester belum dirilis'),
          ],
        );

      case ChartMode.pertemuan:
        final persen = AppData.totalPertemuanRencana == 0
            ? 0
            : ((AppData.totalPertemuanTerlaksana /
                        AppData.totalPertemuanRencana) *
                    100)
                .round();
        return Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _legendItem(p, p.accent, '$persen% dari rencana 16x per mata kuliah'),
            _legendItem(p, p.textMuted, 'Sisa pertemuan sampai UAS'),
          ],
        );

      case ChartMode.absensi:
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
            style: TextStyle(fontSize: 11, color: p.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Helper menggambar teks di atas Canvas
// ===========================================================================

TextPainter _tp(String teks, TextStyle gaya, {double? maxWidth}) {
  final tp = TextPainter(
    text: TextSpan(text: teks, style: gaya),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  );
  tp.layout(maxWidth: maxWidth ?? double.infinity);
  return tp;
}

void _garisPutus(
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

// ===========================================================================
// 1. Grafik garis IPS semester 1-8
// ===========================================================================

class _IpsChartPainter extends CustomPainter {
  final List<IpsSemester> data;
  final double target;
  final AppPalette p;

  _IpsChartPainter({
    required this.data,
    required this.target,
    required this.p,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const kiri = 28.0;
    const kanan = 14.0;
    const atas = 26.0;
    const bawah = 26.0;

    final lebar = size.width - kiri - kanan;
    final tinggi = size.height - atas - bawah;
    if (lebar <= 0 || tinggi <= 0 || data.isEmpty) return;

    const maksY = 4.0;

    double xUntuk(int i) => data.length <= 1
        ? kiri + lebar / 2
        : kiri + lebar * i / (data.length - 1);
    double yUntuk(double nilai) => atas + tinggi - (nilai / maksY) * tinggi;

    final garisGrid = Paint()
      ..color = p.border
      ..strokeWidth = 1;
    final garisVertikal = Paint()
      ..color = p.border.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    final gayaLabel = TextStyle(fontSize: 9, color: p.textMuted);

    // grid horizontal + angka sumbu Y
    for (var nilai = 0; nilai <= 4; nilai++) {
      final y = yUntuk(nilai.toDouble());
      canvas.drawLine(Offset(kiri, y), Offset(kiri + lebar, y), garisGrid);
      final tp = _tp('$nilai', gayaLabel);
      tp.paint(canvas, Offset(kiri - 6 - tp.width, y - tp.height / 2));
    }

    // garis bantu vertikal per semester
    for (var i = 0; i < data.length; i++) {
      final x = xUntuk(i);
      canvas.drawLine(Offset(x, atas), Offset(x, atas + tinggi), garisVertikal);
    }

    // garis target
    final yTarget = yUntuk(target);
    _garisPutus(
      canvas,
      Offset(kiri, yTarget),
      Offset(kiri + lebar, yTarget),
      Paint()
        ..color = p.warning
        ..strokeWidth = 1.2,
    );
    final tpTarget = _tp(
      'Target ${target.toStringAsFixed(2)}',
      TextStyle(fontSize: 9, color: p.warning, fontWeight: FontWeight.bold),
    );
    tpTarget.paint(canvas, Offset(kiri + 4, yTarget - tpTarget.height - 2));

    // kumpulkan titik per rentetan (biar tetap benar kalau ada semester
    // yang belum bernilai di tengah)
    final rentetan = <List<Offset>>[];
    var jalanan = <Offset>[];
    final semuaTitik = <(Offset, double)>[];
    for (var i = 0; i < data.length; i++) {
      final nilai = data[i].ips;
      if (nilai == null) {
        if (jalanan.isNotEmpty) {
          rentetan.add(jalanan);
          jalanan = <Offset>[];
        }
        continue;
      }
      final titik = Offset(xUntuk(i), yUntuk(nilai));
      jalanan.add(titik);
      semuaTitik.add((titik, nilai));
    }
    if (jalanan.isNotEmpty) rentetan.add(jalanan);

    // area di bawah garis (hanya rentetan pertama)
    if (rentetan.isNotEmpty && rentetan.first.length >= 2) {
      final dasar = atas + tinggi;
      final area = Path()..moveTo(rentetan.first.first.dx, dasar);
      for (final t in rentetan.first) {
        area.lineTo(t.dx, t.dy);
      }
      area
        ..lineTo(rentetan.first.last.dx, dasar)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              p.accent.withValues(alpha: 0.28),
              p.accent.withValues(alpha: 0.02),
            ],
          ).createShader(Rect.fromLTWH(kiri, atas, lebar, tinggi)),
      );
    }

    // garis
    final kuas = Paint()
      ..color = p.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final r in rentetan) {
      if (r.length < 2) continue;
      final path = Path()..moveTo(r.first.dx, r.first.dy);
      for (var i = 1; i < r.length; i++) {
        path.lineTo(r[i].dx, r[i].dy);
      }
      canvas.drawPath(path, kuas);
    }

    // titik + label nilai
    for (final (titik, nilai) in semuaTitik) {
      canvas.drawCircle(titik, 5.5, Paint()..color = p.card);
      canvas.drawCircle(titik, 4, Paint()..color = p.accent);
      final tp = _tp(
        nilai.toStringAsFixed(2),
        TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: p.textPrimary,
        ),
      );
      var dy = titik.dy - tp.height - 8;
      if (dy < atas - 20) dy = titik.dy + 8;
      // Jaga label tetap di dalam area plot supaya tidak menabrak
      // angka sumbu Y di kiri.
      final dx = (titik.dx - tp.width / 2).clamp(kiri, kiri + lebar - tp.width);
      tp.paint(canvas, Offset(dx, dy));
    }

    // label sumbu X
    final dasarY = atas + tinggi + 6;
    for (var i = 0; i < data.length; i++) {
      final adaNilai = data[i].sudahAdaNilai;
      final tp = _tp(
        '${data[i].semester}',
        TextStyle(
          fontSize: 10,
          fontWeight: adaNilai ? FontWeight.bold : FontWeight.normal,
          color: adaNilai ? p.textPrimary : p.textMuted,
        ),
      );
      tp.paint(canvas, Offset(xUntuk(i) - tp.width / 2, dasarY));
    }
  }

  @override
  bool shouldRepaint(_IpsChartPainter old) =>
      old.data != data || old.target != target || old.p.mode != p.mode;
}

// ===========================================================================
// 2. Grafik batang rencana tatap muka (16x per mata kuliah)
// ===========================================================================

class _PertemuanChartPainter extends CustomPainter {
  final List<MataKuliahAktif> data;
  final AppPalette p;

  _PertemuanChartPainter({required this.data, required this.p});

  @override
  void paint(Canvas canvas, Size size) {
    const atas = 18.0;
    const bawah = 10.0;
    const kanan = 42.0;

    if (data.isEmpty) return;

    final lebarLabel = math.min(size.width * 0.40, 132.0);
    final xAwal = lebarLabel + 6;
    final lebarBar = size.width - xAwal - kanan;
    if (lebarBar <= 0) return;

    final tinggiIsi = size.height - atas - bawah;
    final tinggiBaris = tinggiIsi / data.length;
    final tinggiBar = math.min(tinggiBaris * 0.52, 13.0);
    final skala = lebarBar / kRencanaTatapMuka;

    // penanda kuartal di sumbu atas
    final gayaKuartal = TextStyle(fontSize: 8.5, color: p.textMuted);
    for (final kuartal in <int>[4, 8, 12, 16]) {
      final x = xAwal + skala * kuartal;
      canvas.drawLine(
        Offset(x, atas - 6),
        Offset(x, atas + tinggiIsi),
        Paint()
          ..color = p.border.withValues(alpha: 0.45)
          ..strokeWidth = 1,
      );
      final tp = _tp('$kuartal', gayaKuartal);
      tp.paint(canvas, Offset(x - tp.width / 2, atas - 16));
    }

    final kuasTrack = Paint()..color = p.surfaceAlt;
    final kuasBar = Paint()..color = p.accent;

    for (var i = 0; i < data.length; i++) {
      final mk = data[i];
      final tengah = atas + tinggiBaris * i + tinggiBaris / 2;
      final y = tengah - tinggiBar / 2;

      final tpNama = _tp(
        mk.nama,
        TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        maxWidth: lebarLabel,
      );
      tpNama.paint(canvas, Offset(0, tengah - tpNama.height / 2));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(xAwal, y, lebarBar, tinggiBar),
          Radius.circular(tinggiBar / 2),
        ),
        kuasTrack,
      );

      final lebarIsi = skala * mk.terlaksana;
      if (lebarIsi > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(xAwal, y, math.max(lebarIsi, tinggiBar), tinggiBar),
            Radius.circular(tinggiBar / 2),
          ),
          kuasBar,
        );
      }

      final tpNilai = _tp(
        '${mk.terlaksana}/$kRencanaTatapMuka',
        TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: p.textPrimary,
        ),
      );
      tpNilai.paint(
        canvas,
        Offset(size.width - tpNilai.width, tengah - tpNilai.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_PertemuanChartPainter old) =>
      old.data != data || old.p.mode != p.mode;
}

// ===========================================================================
// 3. Grafik absensi (hadir / sakit / izin / alpa)
// ===========================================================================

class _AbsensiChartPainter extends CustomPainter {
  final List<MataKuliahAktif> data;
  final AppPalette p;

  _AbsensiChartPainter({required this.data, required this.p});

  @override
  void paint(Canvas canvas, Size size) {
    const atas = 18.0;
    const bawah = 10.0;
    const kanan = 40.0;

    if (data.isEmpty) return;

    final lebarLabel = math.min(size.width * 0.38, 126.0);
    final xAwal = lebarLabel + 6;
    final lebarBar = size.width - xAwal - kanan;
    if (lebarBar <= 0) return;

    final tinggiIsi = size.height - atas - bawah;
    final tinggiBaris = tinggiIsi / data.length;
    final tinggiBar = math.min(tinggiBaris * 0.52, 13.0);
    final skala = lebarBar / kRencanaTatapMuka;

    final gayaKuartal = TextStyle(fontSize: 8.5, color: p.textMuted);
    for (final kuartal in <int>[4, 8, 12, 16]) {
      final x = xAwal + skala * kuartal;
      canvas.drawLine(
        Offset(x, atas - 6),
        Offset(x, atas + tinggiIsi),
        Paint()
          ..color = p.border.withValues(alpha: 0.45)
          ..strokeWidth = 1,
      );
      final tp = _tp('$kuartal', gayaKuartal);
      tp.paint(canvas, Offset(x - tp.width / 2, atas - 16));
    }

    for (var i = 0; i < data.length; i++) {
      final mk = data[i];
      final tengah = atas + tinggiBaris * i + tinggiBaris / 2;
      final y = tengah - tinggiBar / 2;

      final tpNama = _tp(
        mk.nama,
        TextStyle(
          fontSize: 10,
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
          fontSize: 10,
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
