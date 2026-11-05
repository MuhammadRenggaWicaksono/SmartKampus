import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/data/supabase_service.dart';
import 'package:app_kampus/profile/avatar_profil.dart';
import 'package:app_kampus/theme_notifier.dart';

/// Regresi untuk bug "tombol kamera cuma memunculkan popup".
/// Di test ini Supabase tidak terhubung, jadi avatar wajib jatuh ke inisial
/// dan setiap ketukan harus memberi penjelasan — bukan diam saja.
void _pasangLayar(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  tearDown(() {
    appThemeNotifier.value = AppThemeMode.light;
    SupabaseService.fotoProfil.value = null;
  });

  Future<void> pumpAvatar(WidgetTester tester, {double ukuran = 70}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: AvatarProfil(ukuran: ukuran)),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('menampilkan inisial saat belum login', (tester) async {
    _pasangLayar(tester);
    await pumpAvatar(tester);

    expect(find.text(AppData.inisial), findsWidgets);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ketuk ikon kamera memberi penjelasan, bukan diam', (
    tester,
  ) async {
    _pasangLayar(tester);
    await pumpAvatar(tester);

    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pump();

    // Pesannya bisa "Masuk dulu..." atau "Supabase belum terhubung...",
    // tergantung mana yang belum siap. Yang penting ADA umpan balik.
    expect(find.byType(SnackBar), findsOneWidget);
    // dan bottom sheet pemilih foto tidak boleh terbuka
    expect(find.text('Pilih dari Galeri'), findsNothing);
  });

  testWidgets('ketuk bagian avatar juga memicu aksi yang sama', (
    tester,
  ) async {
    _pasangLayar(tester);
    await pumpAvatar(tester);

    await tester.tap(find.text(AppData.inisial).first);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('bisaDiubah: false membuat avatar pasif', (tester) async {
    _pasangLayar(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AvatarProfil(ukuran: 50, bisaDiubah: false)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.camera_alt), findsNothing);

    final inkwell = tester.widget<InkWell>(find.byType(InkWell));
    expect(inkwell.onTap, isNull);
  });

  testWidgets('render bersih di 3 tema', (tester) async {
    _pasangLayar(tester);
    await pumpAvatar(tester);

    for (final mode in AppThemeMode.values) {
      appThemeNotifier.value = mode;
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('foto baru langsung menyebar ke avatar di layar lain', (
    tester,
  ) async {
    _pasangLayar(tester);

    // Meniru MainScreen: Dashboard dan Akun hidup bersamaan di IndexedStack.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AvatarProfil(ukuran: 50, bisaDiubah: false), // "Dashboard"
              AvatarProfil(ukuran: 70), // "Akun"
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    // Belum ada foto: dua-duanya masih inisial.
    expect(find.byType(Image), findsNothing);

    // Inilah yang terjadi setelah unggah berhasil di tab Akun.
    SupabaseService.fotoProfil.value = 'https://contoh.test/foto.jpg?v=1';
    await tester.pump();

    // Tanpa restart, KEDUA avatar harus ikut berubah.
    expect(
      find.byType(Image),
      findsNWidgets(2),
      reason: 'foto hanya berubah di satu avatar — bug IndexedStack',
    );

    // Dan saat foto dihapus, keduanya kembali ke inisial.
    SupabaseService.fotoProfil.value = null;
    await tester.pump();
    expect(find.byType(Image), findsNothing);
  });
}