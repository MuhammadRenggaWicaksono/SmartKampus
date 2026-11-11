import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/theme_notifier.dart';

double _lin(double v) { v = v * 255 / 255; return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble(); }
double _lum(Color c) => 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b);
double ratio(Color a, Color b) { final la = _lum(a), lb = _lum(b); return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05); }
String hex(Color c) => '#${(c.r*255).round().toRadixString(16).padLeft(2,'0')}${(c.g*255).round().toRadixString(16).padLeft(2,'0')}${(c.b*255).round().toRadixString(16).padLeft(2,'0')}';
Color over(Color fg, Color bg) => Color.alphaBlend(fg, bg);

void main() {
  test('chip contrast', () {
    for (final mode in [AppThemeMode.light, AppThemeMode.dark]) {
      final p = AppPalette(mode);
      final raw = <String, Color>{
        'akademik': Colors.blue,
        'keuangan': const Color(0xFF16A34A),
        'darurat': const Color(0xFFDC2626),
        'kemahasiswaan': Colors.purple,
      };
      debugPrint('=== ${mode.name.toUpperCase()}  card=${hex(p.card)}');
      for (final e in raw.entries) {
        final tinta = p.chipInk(e.value);
        final tint = over(e.value.withValues(alpha: 0.14), p.card);
        debugPrint('  ${e.key.padRight(14)} tint=${hex(tint)} ink=${hex(tinta)} -> ${ratio(tinta, tint).toStringAsFixed(2)}');
      }
      final pe = p.chipInk(const Color(0xFFDC2626));
      debugPrint("  PENTING solid  bg=${hex(pe)} ink=${hex(p.onChipInk)} -> ${ratio(p.onChipInk, pe).toStringAsFixed(2)}");
    }
  });
}
