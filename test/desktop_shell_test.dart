import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/core/main_screen.dart';

/// Cek cepat shell navigasi di dua lebar: bilah bawah di HP, rail samping di
/// Web/laptop. Tes lain hanya memompa MainScreen di 360dp, jadi jalur rail
/// (≥980dp) dan susunan desktop tiap tab sebelumnya tidak pernah tersentuh
/// otomatis — layar merah assertion NavigationRail lolos begitu saja.
void main() {
  void pasangLayar(WidgetTester tester, Size ukuran) {
    tester.view.physicalSize = ukuran;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('HP 360dp: bilah bawah, tanpa rail', (tester) async {
    pasangLayar(tester, const Size(360, 800));

    await tester.pumpWidget(const MaterialApp(home: MainScreen()));
    await tester.pump();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('laptop 1440x900: rail samping, tanpa bilah bawah', (
    tester,
  ) async {
    pasangLayar(tester, const Size(1440, 900));

    await tester.pumpWidget(const MaterialApp(home: MainScreen()));
    await tester.pump();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('laptop: kelima tab bisa dibuka tanpa error', (tester) async {
    pasangLayar(tester, const Size(1440, 900));

    await tester.pumpWidget(const MaterialApp(home: MainScreen()));
    await tester.pump();

    for (final label in ['Akademik', 'Perkuliahan', 'Keuangan', 'Akun']) {
      await tester.tap(find.text(label).first);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull, reason: 'tab $label gagal');
    }

    await tester.tap(find.text('Dashboard').first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('laptop 1024dp (tepat di atas ambang) tetap rail', (
    tester,
  ) async {
    pasangLayar(tester, const Size(1024, 768));

    await tester.pumpWidget(const MaterialApp(home: MainScreen()));
    await tester.pump();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
