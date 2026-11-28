import 'package:flutter/material.dart';

import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/lms/providers/lms_session.dart';
import 'package:app_kampus/lms/screens/lms_home_screen.dart';
import 'package:app_kampus/lms/screens/lms_login_screen.dart';

/// Gerbang LMS: membaca token tersimpan, lalu menampilkan beranda daftar kelas
/// kalau sudah login, atau halaman login kalau belum.
///
/// Ini titik masuk yang dibuka dari menu Perkuliahan (menggantikan tombol
/// Presensi lama). Presensi mahasiswa sendiri tetap ada di Dashboard.
class LmsEntryScreen extends StatefulWidget {
  const LmsEntryScreen({super.key});

  @override
  State<LmsEntryScreen> createState() => _LmsEntryScreenState();
}

class _LmsEntryScreenState extends State<LmsEntryScreen> {
  @override
  void initState() {
    super.initState();
    if (!lmsSession.siap) {
      WidgetsBinding.instance.addPostFrameCallback((_) => lmsSession.muat());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        return ListenableBuilder(
          listenable: lmsSession,
          builder: (context, _) {
            if (!lmsSession.siap) {
              return Container(
                decoration: p.backgroundDecoration,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: CircularProgressIndicator(color: p.accent),
                  ),
                ),
              );
            }
            return lmsSession.sudahMasuk
                ? const LmsHomeScreen()
                : const LmsLoginScreen();
          },
        );
      },
    );
  }
}
