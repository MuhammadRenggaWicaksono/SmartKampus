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

  String _subtitle() {
    switch (_mode) {
      case ChartMode.ips:
        final dinilai = AppData.riwayatIps
            .where((s) => s.sudahAdaNilai)
            .toList();
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
    // Isi tab aktif memakai [accentInk], bukan [accent]: `blueAccent`
    // (#2196F3) cuma 3.5:1 di bawah huruf putih, gagal untuk teks 13pt.
    // accentInk = #1565C0 di Light (7.4:1 dengan putih) dan blue.shade300
    // di Dark (12:1 dengan hitam).
    final isi = p.accentInk;
    final tinta = p.isDark ? Colors.black : Colors.white;
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
              color: aktif ? isi : p.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: aktif ? isi : p.border),
            ),
            child: Column(
              children: [
                Icon(ikon, size: 16, color: aktif ? tinta : p.textSecondary),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: aktif ? tinta : p.textChartAxis,
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
        final dinilai = AppData.riwayatIps
            .where((s) => s.sudahAdaNilai)
            .toList();
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
            _legendItem(
              p,
              p.warning,
              'Target ${AppData.targetIps.toStringAsFixed(2)}',
            ),
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
            _legendItem(
              p,
              p.accent,
              '$persen% dari rencana 16x per mata kuliah',
            ),
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

// ===========================================================================
// Alat menggambar teks di atas Canvas
// ===========================================================================

/// Ukuran teks di dalam canvas grafik, dikumpulkan di satu tempat supaya
/// tidak ada lagi `8.5` / `9` / `10` yang tersebar dan tidak konsisten.
///
/// Angka-angka ini sudah dinaikkan dari versi lama (8.5-10 menjadi 12-13):
/// teks di grafik ikut jadi korban pertama karena di dalam canvas tidak ada
/// tema yang bisa menyelamatkannya — fontnya harus cukup besar dari awal.
abstract final class _Fs {
  /// Angka sumbu Y, penanda kuartal.
  static const double sumbu = 12;

  /// Nama mata kuliah, label semester di sumbu X, angka nilai.
  static const double label = 13;

  /// Judul kecil di dalam plot (garis target).
  static const double anotasi = 12;
}

/// Pencatat kotak teks yang sudah digambar di kanvas.
///
/// Semua teks di dalam grafik digambar manual lewat [TextPainter], jadi tidak
/// ada layout engine yang mencegah dua label bertumpuk — ketika ukuran font
/// grafik dinaikkan 9 → 13pt, label nilai di atas titik yang hanya berjarak
/// ±35dp langsung saling menimpa. Setiap teks mendaftarkan kotaknya di sini,
/// dan teks berikutnya hanya digambar kalau kotaknya masih bebas. Lebih baik
/// satu label tidak muncul (angkanya tetap bisa dibaca di legenda) daripada
/// dua label bertumpuk.
class _PapanLabel {
  final List<Rect> _terpakai = <Rect>[];
  static const double _jarak = 3;

  bool bebas(Rect kotak) =>
      !_terpakai.any((t) => t.overlaps(kotak.inflate(_jarak)));

  void pakai(Rect kotak) => _terpakai.add(kotak);
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

// ===========================================================================
// 1. Grafik garis IPS semester 1-8
// ===========================================================================

class _IpsChartPainter extends CustomPainter {
  final List<IpsSemester> data;
  final double target;
  final AppPalette p;

  _IpsChartPainter({required this.data, required this.target, required this.p});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final gayaSumbu = TextStyle(fontSize: _Fs.sumbu, color: p.textChartAxis);
    final gayaNilai = TextStyle(
      fontSize: _Fs.label,
      fontWeight: FontWeight.bold,
      color: p.textPrimary,
    );

    // Tepi plot diturunkan dari ukuran teks, bukan angka tetap lagi. Tepi
    // `atas`/`bawah` 26dp cukup untuk teks 9pt, tapi tidak untuk 13pt: label
    // nilai paling atas jadi digambar di luar area plot, menimpa tab di
    // atasnya. Sekarang tingginya ikut ukuran font.
    final kiri = _tp('4', gayaSumbu).width + 12;
    final atas = _tp('0.00', gayaNilai).height + 12;
    final kanan = 12.0;
    final bawah = _tp('0.00', gayaNilai).height + 10;

    final lebar = size.width - kiri - kanan;
    final tinggi = size.height - atas - bawah;
    if (lebar <= 0 || tinggi <= 0) return;

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

    // grid horizontal + angka sumbu Y
    for (var nilai = 0; nilai <= 4; nilai++) {
      final y = yUntuk(nilai.toDouble());
      canvas.drawLine(Offset(kiri, y), Offset(kiri + lebar, y), garisGrid);
      final tp = _tp('$nilai', gayaSumbu);
      tp.paint(canvas, Offset(kiri - 6 - tp.width, y - tp.height / 2));
    }

    // garis bantu vertikal per semester
    for (var i = 0; i < data.length; i++) {
      final x = xUntuk(i);
      canvas.drawLine(Offset(x, atas), Offset(x, atas + tinggi), garisVertikal);
    }

    final papan = _PapanLabel();

    // garis target
    final yTarget = yUntuk(target);
    garisPutus(
      canvas,
      Offset(kiri, yTarget),
      Offset(kiri + lebar, yTarget),
      Paint()
        ..color = p.warning
        ..strokeWidth = 1.2,
    );
    // Label garis target ditaruh di ujung kanan garis. Sebelumnya di kiri
    // atas — tepat di atas titik semester 1-3, yang nilainya memang mendekati
    // target, jadi label ini menimpa label nilai.
    final tpTarget = _tp(
      'Target ${target.toStringAsFixed(2)}',
      TextStyle(
        fontSize: _Fs.anotasi,
        color: p.statusInk(kSakit),
        fontWeight: FontWeight.bold,
      ),
    );
    final dxTarget = kiri + lebar - tpTarget.width - 2;
    final dyTarget = (yTarget - tpTarget.height - 4).clamp(
      atas,
      atas + tinggi - tpTarget.height,
    );
    tpTarget.paint(canvas, Offset(dxTarget, dyTarget));
    papan.pakai(
      Rect.fromLTWH(dxTarget, dyTarget, tpTarget.width, tpTarget.height),
    );

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
    //
    // Tidak semua label digambar: kalau kotaknya sudah dipakai label lain
    // (atau oleh label target), label itu dilewati. Titiknya sendiri tetap ada.
    for (final (titik, nilai) in semuaTitik) {
      canvas.drawCircle(titik, 5.5, Paint()..color = p.card);
      canvas.drawCircle(titik, 4, Paint()..color = p.accent);

      final tp = _tp(nilai.toStringAsFixed(2), gayaNilai);
      final dx = (titik.dx - tp.width / 2).clamp(kiri, kiri + lebar - tp.width);
      Rect kotak(double y) => Rect.fromLTWH(dx, y, tp.width, tp.height);

      var dy = titik.dy - tp.height - 8;
      // Tidak boleh naik keluar area plot — itu yang dulu menabrak tab mode.
      if (dy < atas) dy = titik.dy + 9;
      if (papan.bebas(kotak(dy))) {
        tp.paint(canvas, Offset(dx, dy));
        papan.pakai(kotak(dy));
        continue;
      }

      final dyBawah = titik.dy + 9;
      if (dyBawah + tp.height <= atas + tinggi && papan.bebas(kotak(dyBawah))) {
        tp.paint(canvas, Offset(dx, dyBawah));
        papan.pakai(kotak(dyBawah));
      }
    }

    // label sumbu X — nomor semester, dijaga tetap di dalam kanvas
    final dasarY = atas + tinggi + 6;
    for (var i = 0; i < data.length; i++) {
      final adaNilai = data[i].sudahAdaNilai;
      final tp = _tp(
        '${data[i].semester}',
        TextStyle(
          fontSize: _Fs.label,
          color: adaNilai ? p.textPrimary : p.textChartAxis,
        ),
      );
      final dx = (xUntuk(i) - tp.width / 2).clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(dx, dasarY));
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
    if (data.isEmpty) return;

    final gayaAngka = TextStyle(
      fontSize: _Fs.label,
      fontWeight: FontWeight.bold,
      color: p.textPrimary,
    );
    final gayaKuartal = TextStyle(fontSize: _Fs.sumbu, color: p.textChartAxis);
    final tpAngka = _tp('16/16', gayaAngka);
    final tpKuartal = _tp('16', gayaKuartal);

    // Kolom angka kanan & ruang penanda kuartal dihitung dari lebar teks
    // aslinya. Dengan lebar tetap (42dp / 40dp), label kuartal '16' di ujung
    // sumbu masuk ke kolom angka begitu fontnya dinaikkan ke 12-13pt.
    final kanan = tpAngka.width + tpKuartal.width / 2 + 14;
    final atas = tpKuartal.height + 8;
    const bawah = 10.0;
    final lebarLabel = math.min(size.width * 0.40, 132.0);
    final xAwal = lebarLabel + 6;
    final lebarBar = size.width - xAwal - kanan;
    if (lebarBar <= 0) return;

    final tinggiIsi = size.height - atas - bawah;
    final tinggiBaris = tinggiIsi / data.length;
    final tinggiBar = math.min(tinggiBaris * 0.52, 13.0);
    final skala = lebarBar / kRencanaTatapMuka;

    // penanda kuartal di sumbu atas
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

    final kuasTrack = Paint()..color = p.surfaceAlt;
    final kuasBar = Paint()..color = p.accent;

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
          fontSize: _Fs.label,
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
