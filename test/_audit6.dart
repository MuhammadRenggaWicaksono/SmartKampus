import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/screens/dashboard_screen.dart';
import 'package:app_kampus/theme_notifier.dart';

double _lin(double v) {
  v = v / 255.0;
  return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
}

double _lum(Color c) =>
    0.2126 * _lin(c.r * 255) + 0.7152 * _lin(c.g * 255) + 0.0722 * _lin(c.b * 255);

double ratio(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

String hex(Color c) =>
    '#${(c.r * 255).round().toRadixString(16).padLeft(2, '0')}${(c.g * 255).round().toRadixString(16).padLeft(2, '0')}${(c.b * 255).round().toRadixString(16).padLeft(2, '0')}';

void main() {
  testWidgets('audit dashboard', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 1700 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    appThemeNotifier.value = AppThemeMode.light;
    final p = AppPalette(AppThemeMode.light);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DashboardScreen())));
    await tester.pumpAndSettle();

    debugPrint('card=${hex(p.card)} bg=${hex(p.background)} alt=${hex(p.surfaceAlt)}');
    for (final e in find.byType(Text).evaluate()) {
      final w = e.widget as Text;
      final st = w.style ?? const TextStyle();
      final text = (w.data ?? '').replaceAll('\n', ' ');
      if (text.trim().isEmpty) continue;
      final color = st.color ?? p.textPrimary;
      final box = e.renderObject as RenderBox?;
      debugPrint(
        'fs=${(st.fontSize ?? 14).toStringAsFixed(1)} wt=${(st.fontWeight?.value ?? 400)} '
        '${hex(color)} r=${ratio(color, p.card).toStringAsFixed(2)} '
        '${box == null ? "?" : "${box.size.width.toStringAsFixed(0)}x${box.size.height.toStringAsFixed(0)}"} '
        '"${text.length > 30 ? text.substring(0, 30) : text}"',
      );
    }
  });
}
