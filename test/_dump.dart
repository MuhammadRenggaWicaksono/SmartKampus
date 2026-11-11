import 'package:flutter/material.dart';
import 'package:app_kampus/theme_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/screens/dashboard_screen.dart';

double _lum(Color c) {
  double f(double v) => v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) * ((v + 0.055) / 1.055) * ((v + 0.055) / 1.055);
  return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
}
double _cr(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  testWidgets('dump dashboard texts', (tester) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 60));

    final p = AppPalette(AppThemeMode.light);
    for (final e in find.byType(Text).evaluate()) {
      final w = e.widget as Text;
      final st = w.style;
      final r = tester.getRect(find.byWidget(w));
      final col = st?.color ?? p.textPrimary;
      final bg = _cr(col, p.card) > _cr(col, p.background) ? p.card : p.background;
      debugPrint('TXT "${w.data}" y=${r.top.toStringAsFixed(0)} fs=${st?.fontSize} wt=${st?.fontWeight?.value} '
          'cr=${_cr(col, bg).toStringAsFixed(2)} h=${r.height.toStringAsFixed(1)}');
    }
  });
}
