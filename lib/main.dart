import 'package:flutter/material.dart';
import 'package:app_kampus/auth/login_screen.dart';
import 'package:app_kampus/core/main_screen.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Menyambung ke Supabase kalau lib/data/supabase_config.dart sudah diisi.
  // Kalau belum, aplikasi tetap jalan memakai data dummy (mode demo) dan
  // tidak ada layar yang crash — lihat halaman Diagnostik Supabase.
  final error = await SupabaseService.init();
  if (error != null) SupabaseService.debugLog('init: $error');

  runApp(const KampusPintarApp());
}

class KampusPintarApp extends StatelessWidget {
  const KampusPintarApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema dasar ikut berubah mengikuti tema global yang dipilih pengguna.
    // Sebelumnya `isLgbt` tidak diperhitungkan di sini.
    return ThemeBuilder(
      builder: (context, p) => MaterialApp(
        title: 'Kampus Pintar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: p.background,
          brightness: p.isDark ? Brightness.dark : Brightness.light,
        ),
        // Kalau sesi Supabase masih tersimpan, langsung masuk tanpa login ulang.
        home: SupabaseService.sudahLogin
            ? const MainScreen()
            : const LoginScreen(),
      ),
    );
  }
}
