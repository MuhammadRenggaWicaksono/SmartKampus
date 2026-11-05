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
  Color get textSecondary =>
      isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8);
  Color get textMuted => isDark ? Colors.grey.shade500 : Colors.grey.shade500;

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
  Color get sectionTitle => isDark ? Colors.blue.shade300 : Colors.blue.shade700;

  // -------------------------------------------------------------- status
  Color get danger => isDark ? Colors.red.shade300 : Colors.red.shade700;
  Color get success => isDark ? Colors.greenAccent : Colors.green.shade700;
  Color get warning => isDark ? Colors.orange.shade300 : Colors.orange.shade800;

  Color get shadow => Colors.black.withValues(alpha: isDark ? 0.40 : 0.05);

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
          ? [BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 4))]
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
