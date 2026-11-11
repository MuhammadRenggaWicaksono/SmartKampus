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
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

String hex(Color c) =>
    '#${(c.r * 255).round().toRadixString(16).padLeft(2, '0')}${(c.g * 255).round().toRadixString(16).padLeft(2, '0')}${(c.b * 255).round().toRadixString(16).padLeft(2, '0')}';

void main() {
  for (final mode in [AppThemeMode.light, AppThemeMode.dark]) {
    testWidgets('audit ${mode.name}', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 1900 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      appThemeNotifier.value = mode;
      final p = AppPalette(mode);
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DashboardScreen())));
      await tester.pumpAndSettle();

      debugPrint('=== ${mode.name.toUpperCase()} card=${hex(p.card)}');
      var minR = 99.0;
      String worst = '';
      for (final e in find.byType(Text).evaluate()) {
        final w = e.widget as Text;
        final st = w.style ?? const TextStyle();
        final text = (w.data ?? '').replaceAll('\n', ' ');
        if (text.trim().isEmpty) continue;
        if (st.color == Colors.white || st.color == Colors.black) continue;
        final color = st.color ?? p.textPrimary;
        final box = e.renderObject as RenderBox?;
        final r = ratio(color, p.card);
        if (r < minR) { minR = r; worst = text; }
        final lines = box == null ? 1 : (box.size.height / ((st.fontSize ?? 14) * (st.height ?? 1.2))).round();
        final flag = r < 4.5 ? '  <<< LOW' : '';
        debugPrint(
          'fs=${(st.fontSize ?? 14).toStringAsFixed(1)} ${hex(color)} r=${r.toStringAsFixed(2)} '
          'w=${box?.size.width.round()} lines=$lines "${text.length > 28 ? text.substring(0, 28) : text}"$flag',
        );
      }
      debugPrint('MIN=${minR.toStringAsFixed(2)} ($worst)');
    });
  }
}
