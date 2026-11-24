import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/akademik/kp_screen.dart';
import 'package:app_kampus/akademik/tambah_kp_screen.dart';
import 'package:app_kampus/theme_notifier.dart';

/// Potret layar Kerja Praktik (halaman KP & form DATA KP) ke test/goldens/
/// supaya bisa diperiksa secara visual.
/// Jalankan: flutter test --update-goldens test/golden_preview_kp_test.dart
void main() {
  tearDown(() => appThemeNotifier.value = AppThemeMode.light);

  Future<void> potret(WidgetTester tester, Widget layar, String nama) async {
    await expectLater(
      find.byType(layar.runtimeType),
      matchesGoldenFile('goldens/$nama.png'),
    );
  }

  testWidgets('potret halaman Kerja Praktik', (tester) async {
    tester.view.physicalSize = const Size(1080, 5400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    appThemeNotifier.value = AppThemeMode.light;
    await tester.pumpWidget(const MaterialApp(home: KpScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await potret(tester, const KpScreen(), 'kp_light');

    appThemeNotifier.value = AppThemeMode.dark;
    await tester.pump(const Duration(milliseconds: 300));
    await potret(tester, const KpScreen(), 'kp_dark');
  });

  testWidgets('potret form DATA KP', (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TambahKpScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await potret(tester, const TambahKpScreen(), 'tambah_kp');
  });
}
