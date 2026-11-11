import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_kampus/theme_notifier.dart';

/// Palet warna terpusat untuk seluruh aplikasi.
///
/// Semua layar WAJIB mengambil warna dari sini. Jangan hardcode
/// `Colors.white` / `Color(0xFFF8F9FA)` lagi — itu penyebab Dark Mode
/// dan LGBT Mode rusak di sebagian halaman (teks hitam di atas latar gelap,
/// kartu putih nyala di mode gelap, dsb.).
class AppPalette {
  final AppThemeMode mode;
  const AppPalette(this.mode);

  static const List<Color> rainbow = <Color>[
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  bool get isDark => mode == AppThemeMode.dark;
  bool get isLgbt => mode == AppThemeMode.lgbt;

  // ---------------------------------------------------------------- latar
  Color get background =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
  Color get surface => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get surfaceAlt =>
      isDark ? const Color(0xFF262626) : const Color(0xFFF1F5F9);

  /// Warna kartu. Di LGBT Mode jadi putih transparan (glassmorphism).
  Color get card => isLgbt ? Colors.white.withValues(alpha: 0.85) : surface;

  // ----------------------------------------------------------------- teks
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1E293B);
  Color get textStrong => isDark ? Colors.white : Colors.black87;

  /// Teks pendukung standar: keterangan jadwal, subjudul kartu, baris riwayat.
  /// 5.45:1 di atas kartu putih, 4.97:1 di atas `surfaceAlt` (#F1F5F9).
  Color get textSecondary =>
      isDark ? Colors.grey.shade400 : const Color(0xFF5B6B7F);

  /// Satu tingkat lebih pudar dari [textSecondary] — untuk label kecil
  /// (9-11pt) yang memang sekunder, seperti label sumbu grafik dan keterangan
  /// jam. Tetap 5.14:1 di atas kartu putih dan 4.70:1 di atas `surfaceAlt`,
  /// jadi tidak pernah jatuh di bawah ambang 4.5:1.
  ///
  /// Sebelumnya `grey.shade500` (#9E9E9E) = 2.7:1 — itu penyebab teks
  /// dashboard tampak "menyatu" dengan latar di mata minus.
  Color get textMuted =>
      isDark ? Colors.grey.shade400 : const Color(0xFF5F6F82);

  /// Teks pendukung di dalam kartu: subjudul, keterangan jadwal, legenda
  /// grafik, baris riwayat.
  ///
  /// Sejak [textSecondary] dinaikkan, getter ini setara dengannya — disimpan
  /// supaya layar yang sudah memakainya tidak ikut berubah.
  Color get textCardSupport =>
      isDark ? Colors.grey.shade400 : const Color(0xFF5B6B7F);

  /// Label mikro di kartu KPI (IPK / SKS / TAGIHAN) dan label tab grafik —
  /// satu tingkat lebih tegas dari [textCardSupport]: 10.4:1 di atas kartu
  /// putih, 9.5:1 di atas `surfaceAlt`.
  Color get textCardLabel =>
      isDark ? Colors.grey.shade200 : const Color(0xFF334155);

  /// Label sumbu & angka di dalam grafik (10-11pt, digambar lewat
  /// [TextPainter] oleh `statistik_chart.dart`).
  ///
  /// [textMuted] (#5F6F82) memang lolos 4.5:1, tapi huruf segitu kecil di
  /// kanvas butuh margin lebih — 6.1:1 di atas kartu putih dan 5.5:1 di atas
  /// `surfaceAlt`, tanpa jadi sekuat angka utama.
  Color get textChartAxis =>
      isDark ? const Color(0xFFB0BEC5) : const Color(0xFF55637A);

  // -------------------------------------------------------- garis & isian
  Color get border => isDark ? Colors.grey.shade800 : Colors.grey.shade200;
  Color get divider => isDark ? Colors.grey.shade800 : Colors.grey.shade200;
  Color get inputFill =>
      isDark ? const Color(0xFF262626) : Colors.grey.shade100;
  Color get chipBackground =>
      isDark ? Colors.grey.shade800 : Colors.grey.shade100;

  // --------------------------------------------------------------- aksen
  Color get accent => isLgbt ? Colors.purpleAccent : Colors.blueAccent;
  Color get accentText => isLgbt ? Colors.purpleAccent : Colors.blue.shade700;

  /// Aksen untuk **teks** 10-12pt di atas kartu (bukan untuk latar/ikon besar).
  ///
  /// [accent] (`blueAccent` = #2196F3) hanya 3.1:1 di atas kartu putih — aman
  /// sebagai garis atau latar pil, gagal sebagai teks. `blue.shade700` (#1976D2)
  /// sudah dipakai sebagian layar, tapi di atas `surfaceAlt` (#F1F5F9) tinggal
  /// 4.2:1. Warna ini memberi 5.8:1 di atas kartu putih dan 5.3:1 di atas
  /// surfaceAlt pada Light Mode, tanpa mengubah [accent] itu sendiri.
  Color get accentInk => isLgbt
      ? Colors.purple.shade700
      : (isDark ? Colors.blue.shade300 : const Color(0xFF1565C0));
  Color get sectionTitle =>
      isDark ? Colors.blue.shade300 : Colors.blue.shade700;

  // -------------------------------------------------------------- status
  Color get danger => isDark ? Colors.red.shade300 : Colors.red.shade700;
  Color get success => isDark ? Colors.greenAccent : Colors.green.shade700;
  Color get warning => isDark ? Colors.orange.shade300 : Colors.orange.shade800;

  // ----------------------------------------------------------- navigasi
  // Dipakai bilah navbar bawah (lib/core/main_screen.dart).
  //
  // Warna tab sengaja TIDAK memakai `accent`/`textSecondary`: `accent`
  // (blueAccent / purpleAccent) terlalu terang untuk teks 12.5pt di atas
  // kartu putih, sedangkan `textSecondary` (#94A3B8) terlalu pudar sehingga
  // tab yang tidak aktif nyaris tidak terlihat.

  /// Ikon & label tab yang sedang aktif.
  Color get navSelected => isLgbt
      ? Colors.purple.shade700
      : (isDark ? Colors.blue.shade300 : Colors.blue.shade800);

  /// Ikon & label tab yang tidak aktif. Lebih gelap dari [textSecondary]
  /// supaya tetap terbaca sebagai elemen yang bisa diketuk.
  Color get navUnselected =>
      isDark ? Colors.grey.shade400 : const Color(0xFF5B6B7F);

  /// Latar pil di belakang ikon tab aktif.
  Color get navPill => navSelected.withValues(alpha: 0.15);

  /// Latar bilah navigasi bawah.
  Color get navSurface =>
      isLgbt ? Colors.white.withValues(alpha: 0.92) : surface;

  /// Garis pemisah tipis di atas bilah navigasi.
  Color get navBorder => isDark ? Colors.grey.shade800 : Colors.grey.shade300;

  /// Bayangan yang dipakai bilah navigasi untuk "mengambang" di atas isi
  /// layar, supaya tidak menyatu dengan latar halaman.
  Color get navShadow => Colors.black.withValues(alpha: isDark ? 0.45 : 0.10);

  Color get shadow => Colors.black.withValues(alpha: isDark ? 0.40 : 0.05);

  // ------------------------------------------------------ warna status
  /// Versi **teks** dari warna status semantik (hijau hadir, dst).
  ///
  /// [warna] mentah biasanya terlalu terang untuk dipakai sebagai teks 10-13pt
  /// di atas kartu putih (mis. #22C55E hanya 2.3:1). Getter ini mengembalikan
  /// versi pekat (Light Mode) / terang (Dark Mode) yang aman sebagai teks dan
  /// tetap aman saat diletakkan di atas pil tipis warna yang sama.
  Color statusInk(Color warna) {
    final pasangan = _inkStatus[warna.toARGB32()];
    if (pasangan != null) return isDark ? pasangan.diGelap : pasangan.diTerang;

    var hasil = warna;
    final lawan = isDark ? Colors.white : Colors.black;
    for (var i = 0; i < 24 && _rasio(hasil, surface) < 4.6; i++) {
      hasil = Color.lerp(hasil, lawan, 0.06)!;
    }
    return hasil;
  }

  /// Tinta untuk label chip: warna mentah digelapkan (Light) / diterangkan
  /// (Dark) sampai lolos ≥4.6:1 di atas latar chip itu sendiri — yaitu warna
  /// mentah yang sama pada alpha 0.14 di atas [card].
  ///
  /// [statusInk] tidak dipakai di sini karena peta tintanya cuma mengenal lima
  /// warna semantik; chip kategori memakai warna bebas (biru akademik, ungu
  /// kemahasiswaan, dst) dan latarnya bukan kartu polos.
  Color chipInk(Color warna) {
    final latar = Color.alphaBlend(warna.withValues(alpha: 0.14), card);
    final lawan = isDark ? Colors.white : Colors.black;
    var hasil = warna;
    for (var i = 0; i < 30 && _rasio(hasil, latar) < 4.6; i++) {
      hasil = Color.lerp(hasil, lawan, 0.07)!;
    }
    return hasil;
  }

  /// Huruf di atas isian chip yang penuh warna ([chipInk]).
  Color get onChipInk => isDark ? Colors.black : Colors.white;

  /// Rasio kontras WCAG antara dua warna (1.0 - 21.0).
  static double _rasio(Color a, Color b) {
    final la = _luminansi(a);
    final lb = _luminansi(b);
    final terang = la > lb ? la : lb;
    final gelap = la > lb ? lb : la;
    return (terang + 0.05) / (gelap + 0.05);
  }

  static double _luminansi(Color c) {
    double saluran(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * saluran(c.r) +
        0.7152 * saluran(c.g) +
        0.0722 * saluran(c.b);
  }

  /// Pasangan warna tinta untuk setiap warna status mentah di bawah.
  static const Map<int, ({Color diTerang, Color diGelap})> _inkStatus = {
    0xFF22C55E: (diTerang: Color(0xFF157438), diGelap: Color(0xFF22C55E)),
    0xFFF59E0B: (diTerang: Color(0xFF905D0B), diGelap: Color(0xFFF59E0B)),
    0xFF3B82F6: (diTerang: Color(0xFF2D62B9), diGelap: Color(0xFF72A5F6)),
    0xFFEF4444: (diTerang: Color(0xFFB43434), diGelap: Color(0xFFF37D7D)),
    0xFF9E9E9E: (diTerang: Color(0xFF656565), diGelap: Color(0xFFAAAAAA)),
  };

  /// Gaya ikon status bar supaya jam/baterai tetap kebaca.
  SystemUiOverlayStyle get overlay =>
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

  /// Latar layar: gradient pelangi untuk LGBT Mode, solid untuk lainnya.
  BoxDecoration get backgroundDecoration => isLgbt
      ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: rainbow,
          ),
        )
      : BoxDecoration(color: background);

  /// Dekorasi kartu standar.
  BoxDecoration cardDeco({
    double radius = 16,
    Color? borderColor,
    bool elevated = true,
  }) {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(radius),
      border: borderColor == null ? null : Border.all(color: borderColor),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: shadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}

// Warna semantik presensi. Sengaja konstanta, bukan bagian dari tema, karena
// maknanya tetap: hijau = hadir, dan seterusnya. Kontrasnya aman di latar
// terang maupun gelap.
const Color kHadir = Color(0xFF22C55E);
const Color kSakit = Color(0xFFF59E0B);
const Color kIzin = Color(0xFF3B82F6);
const Color kAlpa = Color(0xFFEF4444);
