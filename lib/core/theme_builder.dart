import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/theme_notifier.dart';

typedef PaletteBuilder = Widget Function(BuildContext context, AppPalette palette);

/// Membangun ulang widget secara otomatis saat tema global berubah
/// (Light / Dark / LGBT) dan langsung memberikan [AppPalette] yang sesuai.
///
/// Contoh:
/// ```dart
/// return ThemeBuilder(
///   builder: (context, p) => Container(
///     decoration: p.backgroundDecoration,
///     child: Scaffold(
///       backgroundColor: Colors.transparent,
///       appBar: AppBar(
///         title: Text('Judul', style: TextStyle(color: p.textPrimary)),
///         backgroundColor: p.card,
///         iconTheme: IconThemeData(color: p.textPrimary),
///       ),
///       body: const SizedBox(),
///     ),
///   ),
/// );
/// ```
class ThemeBuilder extends StatelessWidget {
  final PaletteBuilder builder;

  const ThemeBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, mode, _) => builder(context, AppPalette(mode)),
    );
  }
}
