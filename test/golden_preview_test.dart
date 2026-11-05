import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/screens/dashboard_screen.dart';
import 'package:app_kampus/theme_notifier.dart';
import 'package:app_kampus/widgets/statistik_chart.dart';

/// Bukan test asersi — file ini hanya "memotret" tampilan ke dalam
/// test/goldens/ supaya hasil CustomPainter bisa diperiksa secara visual.
/// Jalankan: flutter test --update-goldens test/golden_preview_test.dart
void main() {
  tearDown(() => appThemeNotifier.value = AppThemeMode.light);

  testWidgets('potret grafik (3 mode)', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: SizedBox(width: 360, child: StatistikChart())),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(StatistikChart),
      matchesGoldenFile('goldens/chart_ips.png'),
    );

    await tester.tap(find.text('Tatap Muka'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(StatistikChart),
      matchesGoldenFile('goldens/chart_pertemuan.png'),
    );

    await tester.tap(find.text('Absensi'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(StatistikChart),
      matchesGoldenFile('goldens/chart_absensi.png'),
    );
  });

  testWidgets('potret dashboard (dark)', (tester) async {
    tester.view.physicalSize = const Size(1080, 4200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    appThemeNotifier.value = AppThemeMode.dark;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DashboardScreen())),
    );
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(DashboardScreen),
      matchesGoldenFile('goldens/dashboard_dark.png'),
    );

    await tester.pumpWidget(const SizedBox());
  });
}
