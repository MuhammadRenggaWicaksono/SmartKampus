import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/akademik/skripsi_screen.dart';
import 'package:app_kampus/akademik/tambah_judul_skripsi_screen.dart';
import 'package:app_kampus/screens/akademik_screen.dart';
import 'package:app_kampus/theme_notifier.dart';

/// Potret layar baru (menu Akademik, Skripsi, form judul) ke
/// test/goldens/ supaya bisa diperiksa secara visual.
/// Jalankan: flutter test --update-goldens test/golden_preview_skripsi_test.dart
void main() {
  tearDown(() => appThemeNotifier.value = AppThemeMode.light);

  Future<void> potret(
    WidgetTester tester,
    Widget layar,
    String nama,
  ) async {
    await expectLater(find.byType(layar.runtimeType), matchesGoldenFile('goldens/$nama.png'));
  }

  testWidgets('potret menu Akademik (light & dark)', (tester) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    appThemeNotifier.value = AppThemeMode.light;
    await tester.pumpWidget(const MaterialApp(home: AkademikScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await potret(tester, const AkademikScreen(), 'akademik_light');

    appThemeNotifier.value = AppThemeMode.dark;
    await tester.pump(const Duration(milliseconds: 300));
    await potret(tester, const AkademikScreen(), 'akademik_dark');
  });

  testWidgets('potret halaman Skripsi', (tester) async {
    tester.view.physicalSize = const Size(1080, 4200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    appThemeNotifier.value = AppThemeMode.light;
    await tester.pumpWidget(const MaterialApp(home: SkripsiScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await potret(tester, const SkripsiScreen(), 'skripsi_light');

    appThemeNotifier.value = AppThemeMode.dark;
    await tester.pump(const Duration(milliseconds: 300));
    await potret(tester, const SkripsiScreen(), 'skripsi_dark');
  });

  testWidgets('potret form tambah judul skripsi', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: TambahJudulSkripsiScreen()),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await potret(
      tester,
      const TambahJudulSkripsiScreen(),
      'tambah_judul_skripsi',
    );
  });
}
