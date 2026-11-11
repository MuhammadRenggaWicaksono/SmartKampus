import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/profile/avatar_profil.dart';
import 'package:app_kampus/theme_notifier.dart';
import 'package:app_kampus/widgets/pengumuman_section.dart';
import 'package:app_kampus/widgets/statistik_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Dipakai supaya label "BERJALAN" / "30 MENIT LAGI" pada jadwal tidak basi.
  Timer? _tick;
  DateTime _sekarang = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _sekarang = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
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
                    _buildHeader(context, p),
                    const SizedBox(height: 24),
                    _buildJadwalHariIni(p),
                    const SizedBox(height: 24),
                    _buildInfoAkademik(p),
                    const SizedBox(height: 24),
                    const PengumumanSection(),
                    const SizedBox(height: 24),
                    const StatistikChart(),
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
  Widget _buildHeader(BuildContext context, AppPalette p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${AppData.namaPanggilan} 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppData.semesterAktif,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.25,
                  color: p.textCardSupport,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<AppThemeMode>(
          icon: Icon(Icons.palette, color: p.textPrimary),
          color: p.card,
          onSelected: (mode) => appThemeNotifier.value = mode,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: AppThemeMode.light,
              child: Text('☀️ Light Mode'),
            ),
            PopupMenuItem(
              value: AppThemeMode.dark,
              child: Text('🌙 Dark Mode'),
            ),
            PopupMenuItem(
              value: AppThemeMode.lgbt,
              child: Text('🌈 LGBT Mode'),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Avatar inisial — sebelumnya memakai URL via.placeholder.com yang
        // sudah mati, jadi gambarnya kosong / gagal terus.
        // Avatar yang sama dengan halaman Akun — ikut berubah begitu foto
        // profil diganti (lewat SupabaseService.fotoProfil), tapi di sini
        // tidak bisa diketuk.
        const AvatarProfil(ukuran: 50, bisaDiubah: false),
      ],
    );
  }

  // ------------------------------------------------------ jadwal hari ini
  Widget _buildJadwalHariIni(AppPalette p) {
    final jadwal = AppData.jadwalTerdekat(_sekarang);
    final berjalan = AppData.kelasSedangBerjalan(_sekarang);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(),
      child: Column(
        children: [
          // Judul dan ringkasan ditaruh bertingkat, bukan berdampingan.
          // Dulu keduanya satu baris: chip "1 KELAS • 3 SKS" butuh ~190 px,
          // jadi judul cuma kebagian ~45 px dan terpotong jadi "Jadw…".
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  jadwal.hariIni
                      ? 'Jadwal Hari Ini'
                      : 'Jadwal ${jadwal.hari} (berikutnya)',
                  maxLines: 2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    height: 1.2,
                    color: p.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${jadwal.jumlahMk} KELAS • ${jadwal.totalSks} SKS',
                style: TextStyle(
                  color: p.accentInk,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (jadwal.kosong)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(
                    Icons.beach_access_outlined,
                    size: 40,
                    color: p.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada kelas hari ini 🎉',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.3,
                      color: p.textCardSupport,
                    ),
                  ),
                ],
              ),
            )
          else
            ...jadwal.kelas.map(
              (kelas) => Padding(
                padding: EdgeInsets.only(
                  bottom: kelas == jadwal.kelas.last ? 0 : 10,
                ),
                child: _buildJadwalItem(
                  p,
                  kelas,
                  disorot: berjalan != null && berjalan.kode == kelas.kode,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJadwalItem(
    AppPalette p,
    KelasKuliah kelas, {
    required bool disorot,
  }) {
    final status = _statusKelas(kelas, p);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.isi.withValues(alpha: 0.06),
        border: Border.all(
          color: status.isi.withValues(alpha: disorot ? 0.70 : 0.28),
          width: disorot ? 1.6 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: status.isi,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  kelas.jamMulai,
                  style: TextStyle(
                    color: _teksDiAtasIsi(p),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  kelas.jamSelesai,
                  style: TextStyle(
                    color: _teksDiAtasIsi(p).withValues(alpha: 0.92),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kelas.nama,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${kelas.ruang} • ${kelas.dosen}',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    color: p.textCardSupport,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: status.isi.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: status.isi,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Warna huruf di atas isian pil jam yang berwarna penuh.
  ///
  /// Light Mode: isiannya pekat, jadi hurufnya putih. Dark Mode: isiannya
  /// sengaja terang (`statusInk` versi gelap), jadi hurufnya hitam — putih di
  /// atas hijau/kuning terang hanya ~2.3:1.
  Color _teksDiAtasIsi(AppPalette p) => p.isDark ? Colors.black : Colors.white;

  /// Label status + isian pil untuk satu sesi kuliah.
  ///
  /// `isi` = versi aman dari warna mentah (lihat [AppPalette.statusInk]) —
  /// dipakai sebagai latar pil jam, garis tepi, dan huruf label status.
  ({String label, Color isi}) _statusKelas(KelasKuliah kelas, AppPalette p) {
    Color isi(Color mentah) => p.statusInk(mentah);

    if (kelas.sedangBerjalan(_sekarang)) {
      return (label: 'BERJALAN', isi: isi(kHadir));
    }

    if (kelas.belumMulai(_sekarang)) {
      final sisa = kelas.menitMulai - (_sekarang.hour * 60 + _sekarang.minute);
      if (sisa <= 60) {
        return (label: '$sisa MENIT LAGI', isi: isi(kSakit));
      }
      return (
        label: '${sisa ~/ 60} JAM ${sisa % 60} MENIT LAGI',
        isi: p.accentInk,
      );
    }

    return (label: 'SELESAI', isi: p.textMuted);
  }

  // ------------------------------------------------------- kartu akademik
  /// IPK / SKS / TAGIHAN — versi "bento".
  ///
  /// Dulu tiga baris seragam: label sama, angka sama besar, jadi tidak ada
  /// tangga yang menuntun mata. Sekarang IPK jadi kepala (angka 40pt +
  /// sparkline IPS), sedangkan SKS dan TAGIHAN turun jadi dua sel pendukung di
  /// kanan. Tinggi kedua kolom disamakan oleh [IntrinsicHeight] supaya kolom
  /// kanan tidak menggantung bila isinya lebih pendek.
  Widget _buildInfoAkademik(AppPalette p) {
    return Container(
      decoration: p.cardDeco(),
      padding: const EdgeInsets.all(12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 108, child: _buildHeroIpk(p)),
            const SizedBox(width: 10),
            // Sengaja tanpa Expanded di dalam: anak ber-flex menyumbang 0 pada
            // pengukuran intrinsik, jadi tinggi sel tidak ikut terhitung dan
            // isinya bisa meluber keluar kotak.
            Expanded(
              flex: 92,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSelSks(p),
                  const SizedBox(height: 10),
                  _buildSelTagihan(p),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Isian sel kartu akademik — `surfaceAlt`, bukan `card`, supaya kartunya
  /// terbaca sebagai satu blok berisi tiga kotak, bukan tiga kartu kecil.
  BoxDecoration _decoSel(AppPalette p) => BoxDecoration(
    color: p.surfaceAlt,
    borderRadius: BorderRadius.circular(13),
  );

  /// Label mikro di dalam sel (IPK / SKS DIAMBIL / TAGIHAN).
  TextStyle _gayaCap(AppPalette p) => TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.9,
    height: 1.15,
    color: p.textCardLabel,
  );

  /// Sel kiri: IPK sebagai kepala.
  Widget _buildHeroIpk(AppPalette p) {
    final dinilai = AppData.riwayatIps.where((s) => s.sudahAdaNilai).toList();
    final selisih = AppData.selisihTargetIps;
    final diAtas = selisih >= 0;

    return Container(
      decoration: _decoSel(p),
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IPK', style: _gayaCap(p)),
          const SizedBox(height: 3),
          // FittedBox: angka 40pt tetap utuh walau ukuran teks sistem
          // diperbesar — lebar sel ini cuma ~128dp.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppData.ipk.toStringAsFixed(2),
              maxLines: 1,
              style: TextStyle(
                fontSize: 40,
                height: 1.05,
                letterSpacing: -1.6,
                fontWeight: FontWeight.w800,
                color: p.textPrimary,
              ),
            ),
          ),
          Text(
            'dari 4.00',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.2,
              color: p.textCardSupport,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 34,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparkIpsPainter(data: dinilai, p: p),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Target ${AppData.targetIps.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: p.textChartAxis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${diAtas ? '+' : '-'}${selisih.abs().toStringAsFixed(2)}',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: p.statusInk(diAtas ? kHadir : kAlpa),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelSks(AppPalette p) {
    return Container(
      decoration: _decoSel(p),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SKS DIAMBIL', style: _gayaCap(p)),
          const SizedBox(height: 4),
          // "116 / 144" sebagai satu teks utuh: di kolom sempit, potongan
          // "/144" dengan gaya berbeda lebih gampang terpotong.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppData.labelSksTotal,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                height: 1.1,
                letterSpacing: -0.4,
                fontWeight: FontWeight.w800,
                color: p.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'sisa ${AppData.sksSisa} SKS',
            maxLines: 1,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.2,
              color: p.textCardSupport,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: AppData.rasioSks.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: p.card,
              valueColor: AlwaysStoppedAnimation<Color>(p.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelTagihan(AppPalette p) {
    final lunas = AppData.tagihanLunas;
    final tinta = p.statusInk(lunas ? kHadir : kAlpa);

    return Container(
      decoration: _decoSel(p),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TAGIHAN', style: _gayaCap(p)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppData.statusTagihan,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                height: 1.1,
                letterSpacing: -0.4,
                fontWeight: FontWeight.w800,
                color: tinta,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${AppData.persenTerbayar}% dibayar',
            maxLines: 1,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.2,
              color: p.textCardSupport,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: tinta.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              lunas ? 'LUNAS' : 'BELUM LUNAS',
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: tinta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sparkline IPS di kepala kartu akademik: garis nilai 4 semester + garis
/// putus-putus [AppData.targetIps] sebagai pembanding.
///
/// Rentang Y dikunci ke data + target, bukan 0-4. Dengan nilai 3.58-3.76,
/// skala 0-4 bikin keempat titik menempel jadi satu garis datar di atas.
class _SparkIpsPainter extends CustomPainter {
  const _SparkIpsPainter({required this.data, required this.p});

  final List<IpsSemester> data;
  final AppPalette p;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2 || size.height <= 0 || size.width <= 0) return;

    final nilai = data.map((s) => s.ips!).toList();
    final semua = [AppData.targetIps, ...nilai];
    final bawah = (semua.reduce(math.min) - 0.15).clamp(0.0, 4.0);
    final atas = (semua.reduce(math.max) + 0.15).clamp(bawah + 0.2, 4.0);
    final rentang = atas - bawah;

    double y(double v) => size.height - ((v - bawah) / rentang) * size.height;
    double x(int i) => size.width * i / (data.length - 1);

    garisPutus(
      canvas,
      Offset(0, y(AppData.targetIps)),
      Offset(size.width, y(AppData.targetIps)),
      Paint()
        ..color = p.textChartAxis
        ..strokeWidth = 1,
    );

    final jalur = Path()..moveTo(x(0), y(nilai[0]));
    for (var i = 1; i < nilai.length; i++) {
      jalur.lineTo(x(i), y(nilai[i]));
    }
    canvas.drawPath(
      jalur,
      Paint()
        ..color = p.accent
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < nilai.length; i++) {
      final titik = Offset(x(i), y(nilai[i]));
      canvas.drawCircle(titik, 3.4, Paint()..color = p.surfaceAlt);
      canvas.drawCircle(titik, 2.4, Paint()..color = p.accent);
    }
  }

  @override
  bool shouldRepaint(_SparkIpsPainter old) =>
      old.p.mode != p.mode || old.data.length != data.length;
}
