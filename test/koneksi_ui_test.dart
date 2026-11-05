import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/auth/login_screen.dart';
import 'package:app_kampus/core/diagnostik_screen.dart';
import 'package:app_kampus/data/supabase_config.dart';
import 'package:app_kampus/theme_notifier.dart';

/// Test ini ada karena satu bug lolos ke HP:
///   type 'int' is not a subtype of type 'double' of 'radius'
/// Penyebabnya parameter `dynamic p` di LoginScreen, yang mematikan
/// konversi literal int -> double saat memanggil `p.cardDeco(radius: 20)`.
/// Sekarang setiap layar koneksi wajib dirender di test, di ketiga tema.
void _pasangLayar(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  tearDown(() => appThemeNotifier.value = AppThemeMode.light);

  group('LoginScreen', () {
    testWidgets('render bersih di 3 tema (tidak ada error tipe)', (
      tester,
    ) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      for (final mode in AppThemeMode.values) {
        appThemeNotifier.value = mode;
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          tester.takeException(),
          isNull,
          reason: 'LoginScreen gagal dirender di tema $mode',
        );
      }
    });

    testWidgets('menampilkan kolom Email + Password dan tombol Masuk', (
      tester,
    ) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Masuk Mode Demo (data dummy)'), findsOneWidget);
      // Pemberitahuan hanya muncul kalau kredensial belum diisi.
      if (!SupabaseConfig.terkonfigurasi) {
        expect(
          find.textContaining('Supabase belum dikonfigurasi'),
          findsOneWidget,
        );
      }
    });

    testWidgets('menolak submit kalau kolom kosong', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      await tester.tap(find.text('Masuk'));
      await tester.pump();

      expect(find.text('Email dan password wajib diisi.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('menolak email tanpa @', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(0), '2411044');
      await tester.enterText(find.byType(TextFormField).at(1), 'rahasia');
      await tester.tap(find.text('Masuk'));
      await tester.pump();

      expect(find.text('Format email belum benar.'), findsOneWidget);
    });

    testWidgets('email valid tapi Supabase mati -> diarahkan ke Mode Demo', (
      tester,
    ) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'rengga@kampus.ac.id',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'rahasia');
      await tester.tap(find.text('Masuk'));
      await tester.pump();

      expect(
        find.textContaining('Supabase belum terhubung'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('DiagnostikScreen', () {
    testWidgets('jalan dalam mode demo tanpa exception', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: DiagnostikScreen()));
      // initState memakai addPostFrameCallback, jadi butuh dua pump
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Diagnostik Supabase'), findsOneWidget);
      expect(find.text('Konfigurasi'), findsOneWidget);
      expect(find.text('Inisialisasi client'), findsOneWidget);
      expect(find.text('Sesi login'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('render bersih di 3 tema', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: DiagnostikScreen()));
      await tester.pumpAndSettle();

      for (final mode in AppThemeMode.values) {
        appThemeNotifier.value = mode;
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      }
    });
  });
}