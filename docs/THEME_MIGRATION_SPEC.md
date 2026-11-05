# Spesifikasi Migrasi Tema — SmartKampus

## Masalah

Tema global aplikasi diatur oleh `ValueNotifier<AppThemeMode> appThemeNotifier`
(`lib/theme_notifier.dart`, enum `AppThemeMode { light, dark, lgbt }`).

Banyak layar masih **hardcode warna terang** (`Colors.white`, `Color(0xFFF8F9FA)`,
`Color(0xFFF3F4F6)`, `Colors.black87`) sehingga **Dark Mode dan LGBT Mode rusak**:
kartu putih menyala di latar gelap, teks hitam tidak terbaca, AppBar putih polos.

Sudah dibuat palet terpusat yang **wajib** dipakai. Jangan hardcode warna tema lagi.

## API yang tersedia (sudah ada di repo — JANGAN diubah)

### `lib/core/app_palette.dart`

```dart
class AppPalette {
  const AppPalette(AppThemeMode mode);

  bool get isDark;
  bool get isLgbt;

  // latar
  Color get background;      // 0xFF121212 (dark) / 0xFFF8F9FA
  Color get surface;         // 0xFF1E1E1E (dark) / Colors.white
  Color get surfaceAlt;      // 0xFF262626 (dark) / 0xFFF1F5F9
  Color get card;            // putih 85% kalau LGBT, selain itu = surface

  // teks
  Color get textPrimary;     // putih (dark) / 0xFF1E293B
  Color get textStrong;      // putih (dark) / black87
  Color get textSecondary;   // grey400 (dark) / 0xFF94A3B8
  Color get textMuted;

  // garis & isian
  Color get border;
  Color get divider;
  Color get inputFill;
  Color get chipBackground;

  // aksen
  Color get accent;
  Color get accentText;
  Color get sectionTitle;

  // status
  Color get danger;
  Color get success;
  Color get warning;

  Color get shadow;
  SystemUiOverlayStyle get overlay;

  /// gradient pelangi kalau LGBT, solid kalau tidak
  BoxDecoration get backgroundDecoration;

  BoxDecoration cardDeco({
    double radius = 16,
    Color? borderColor,
    bool elevated = true,
  });
}
```

### `lib/core/theme_builder.dart`

```dart
typedef PaletteBuilder = Widget Function(BuildContext context, AppPalette palette);

class ThemeBuilder extends StatelessWidget {
  const ThemeBuilder({super.key, required PaletteBuilder builder});
}
```

`ThemeBuilder` otomatis rebuild saat tema global berubah.

## Pola wajib untuk setiap layar

```dart
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';

@override
Widget build(BuildContext context) {
  return ThemeBuilder(
    builder: (context, p) => Container(
      decoration: p.backgroundDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Judul', style: TextStyle(color: p.textPrimary, fontSize: 18)),
          backgroundColor: p.card,
          foregroundColor: p.textPrimary,
          iconTheme: IconThemeData(color: p.textPrimary),
          elevation: 0.5,
        ),
        body: const SizedBox(), // ganti semua warna hardcode memakai p.<getter>
      ),
    ),
  );
}
```

Kalau layar butuh state (`StatefulWidget`), pola tetap sama — `ThemeBuilder` ditaruh
di dalam `build()`.

## Aturan penggantian warna

| Sebelum | Sesudah |
|---|---|
| `Scaffold(backgroundColor: const Color(0xFFF8F9FA))` | pola `Container(decoration: p.backgroundDecoration)` + `Scaffold(backgroundColor: Colors.transparent)` |
| AppBar `backgroundColor: Colors.white` | `p.card` |
| AppBar `foregroundColor` / `iconTheme: Colors.black` | `p.textPrimary` |
| Card/Container `color: Colors.white` | `p.card` (atau `p.cardDeco(radius: X)`) |
| Text `Colors.black87` / `Colors.black` | `p.textPrimary` |
| Text `Colors.grey` / `Colors.grey.shade600` | `p.textSecondary` |
| TextField `fillColor: Colors.grey.shade100` | `p.inputFill` |
| Border/outline `Colors.grey.shade300` | `p.border` |
| Divider `Colors.grey.shade200` | `p.divider` |
| Chip/badge bg `Colors.grey.shade100/50` | `p.chipBackground` |
| Icon abu-abu | `p.textSecondary` |
| `Colors.green.shade50` / `Colors.red.shade50` sebagai latar badge | `Colors.green.withValues(alpha: 0.15)` (atau red/orange) supaya tetap terlihat di mode gelap |
| `withOpacity(x)` (deprecated) | `withValues(alpha: x)` |

Warna **brand/aksen** boleh dibiarkan: `Colors.blue`, `Colors.red`, `Colors.orange`,
`Colors.green`, `Colors.teal`, `Colors.purple` — untuk ikon, tombol, dan aksen visual.
Tapi kalau warna itu dipakai sebagai **warna teks di atas kartu**, ganti ke
`p.danger` / `p.success` / `p.warning` / `p.accent` / `p.accentText` agar kontrasnya
aman di latar gelap.

## Larangan

- JANGAN mengubah logika bisnis, nama variabel publik, struktur widget, teks yang
  tampil, atau nama file.
- JANGAN menghapus fitur atau isi konten. Semua teks dan item harus tetap ada.
- JANGAN menyentuh file selain yang ditugaskan.
- JANGAN menambah dependency di `pubspec.yaml`.
- JANGAN memakai package selain `flutter/material` (dan `flutter/services` kalau
  butuh `SystemUiOverlayStyle`).
- Hapus `import` yang jadi tidak terpakai (mis. `theme_notifier.dart` kalau sudah
  tidak dipakai) supaya tidak ada `unused_import`.

## Verifikasi

```bash
cd /d/Project/GitHub/SmartKampus && /c/sdk/flutter/bin/dart analyze <file-yang-kamu-ubah>
```

Pastikan **tidak ada** error/warning baru dari file yang kamu ubah.

Jangan jalankan `flutter analyze` atau `flutter build` — ada proses lain yang
berjalan paralel dan bisa bentrok lock. Pakai `dart analyze` saja.

File lain mungkin sedang diedit bersamaan oleh proses lain: **abaikan error yang
berasal dari file di luar tugasmu**, cukup laporkan.
