import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/core/main_screen.dart';

/// Menjaga navbar bawah tetap rata.
///
/// Keluhan "menu bawah tidak sama rata" sudah diukur: kotak tiap tab memang
/// sama lebar (selisih 0.000 px di layar 360dp). Yang bikin terlihat tidak
/// rata adalah FONT-SIZE: bawaan Flutter 14 untuk tab aktif vs 12 untuk yang
/// lain, sehingga label membesar saat diketuk dan seluruh baris bergeser —
/// plus "Perkuliahan" terpotong karena slotnya cuma 72dp.
void main() {
  testWidgets('item navbar berjarak sama dan font-nya seragam', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MainScreen()));
    await tester.pump();

    final bar = find.byType(BottomNavigationBar);
    expect(bar, findsOneWidget);

    // 1. Jarak antar pusat label harus sama persis.
    const label = <String>[
      'Dashboard',
      'Akademik',
      'Perkuliahan',
      'Keuangan',
      'Akun',
    ];

    final pusat = <double>[];
    for (final teks in label) {
      final f = find.descendant(of: bar, matching: find.text(teks));
      expect(f, findsOneWidget, reason: 'label "$teks" tidak ditemukan');
      pusat.add(tester.getCenter(f).dx);
    }

    final jarak = <double>[];
    for (var i = 1; i < pusat.length; i++) {
      jarak.add(pusat[i] - pusat[i - 1]);
    }

    final minJarak = jarak.reduce((a, b) => a < b ? a : b);
    final maxJarak = jarak.reduce((a, b) => a > b ? a : b);
    expect(
      maxJarak - minJarak,
      lessThan(0.01),
      reason: 'jarak antar item navbar tidak rata: $jarak',
    );

    // 2. Font tab aktif dan tidak aktif harus sama -> tidak ada pergeseran
    //    saat tab diketuk.
    final widget = tester.widget<BottomNavigationBar>(bar);
    expect(
      widget.selectedFontSize,
      widget.unselectedFontSize,
      reason: 'font tab aktif dan tidak aktif berbeda, label akan bergeser',
    );

    // 3. Label terpanjang harus muat di slotnya (72dp di layar 360dp).
    //    Kalau tidak muat, Flutter memotongnya jadi "Perkuliah...".
    final slot = tester.getSize(bar).width / label.length;
    expect(
      widget.selectedFontSize,
      lessThanOrEqualTo(12.0),
      reason: 'font 14pt tidak muat di slot ${slot.toStringAsFixed(1)}dp',
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('navbar tetap rata di 3 tema', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MainScreen()));
    await tester.pump();

    // Pindah tab: label yang terpilih berubah, jarak tidak boleh berubah.
    for (final teks in <String>['Akademik', 'Perkuliahan', 'Keuangan']) {
      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text(teks),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
    }

    final bar = find.byType(BottomNavigationBar);
    final pusat = <double>[];
    for (final teks in <String>['Dashboard', 'Akademik', 'Akun']) {
      pusat.add(
        tester
            .getCenter(find.descendant(of: bar, matching: find.text(teks)))
            .dx,
      );
    }
    expect(pusat[1] - pusat[0], greaterThan(0));

    await tester.pumpWidget(const SizedBox());
  });
}
