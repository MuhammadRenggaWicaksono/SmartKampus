import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/lms/services/moodle_api_service.dart';

/// Buka tautan di luar aplikasi (browser / penampil berkas bawaan).
///
/// Dipakai untuk berkas `pluginfile.php` (URL-nya sudah ditempeli token) dan
/// untuk modul yang memang harus dibuka di web. Tautan rusak atau tidak ada
/// penampilnya cukup didiamkan, jangan sampai membuat aplikasi berhenti.
Future<void> bukaDiLuar(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // sengaja diam
  }
}

/// Palet warna header kartu mata kuliah.
///
/// Warna dipilih dari id supaya stabil antar-muat dan berbeda satu mata
/// kuliah dengan yang lain.
const List<Color> kWarnaKelas = <Color>[
  Color(0xFF4285F4),
  Color(0xFF0F9D58),
  Color(0xFFF4B400),
  Color(0xFFDB4437),
  Color(0xFF7E57C2),
  Color(0xFF00897B),
  Color(0xFFEF6C00),
  Color(0xFF3949AB),
];

Color warnaKelas(int id) => kWarnaKelas[id.abs() % kWarnaKelas.length];

/// Jenis modul Moodle yang sudah punya tabnya sendiri di detail kelas.
///
/// Tab Materi membuang modul bertipe ini supaya aktivitas seperti "Uji
/// Ketuntasan CPMK" (kuis) tidak muncul dua kali di tempat yang salah.
const Set<String> kJenisPunyaTabSendiri = <String>{'assign', 'quiz', 'forum'};

/// Ikon untuk `modname` Moodle.
IconData ikonModul(String jenis) {
  switch (jenis) {
    case 'resource':
    case 'file':
      return Icons.insert_drive_file_outlined;
    case 'folder':
      return Icons.folder_outlined;
    case 'url':
      return Icons.link;
    case 'assign':
      return Icons.assignment_outlined;
    case 'forum':
      return Icons.forum_outlined;
    case 'quiz':
      return Icons.quiz_outlined;
    case 'page':
      return Icons.description_outlined;
    case 'book':
      return Icons.menu_book_outlined;
    case 'label':
      return Icons.label_outline;
    default:
      return Icons.widgets_outlined;
  }
}

/// Kotak status seragam: memuat / kosong / galat.
class LmsStatus extends StatelessWidget {
  const LmsStatus({
    super.key,
    this.ikon,
    required this.teks,
    this.aksi,
  });

  /// `null` = tampilkan spinner.
  final IconData? ikon;
  final String teks;
  final Widget? aksi;

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: p.cardDeco(radius: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ikon == null)
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              )
            else
              Icon(ikon, size: 38, color: p.textMuted),
            const SizedBox(height: 14),
            Text(
              teks,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: p.textCardSupport),
            ),
            if (aksi != null) ...[const SizedBox(height: 16), aksi!],
          ],
        ),
      ),
    );
  }
}

/// Pemuat data untuk satu tab.
///
/// Menangani tiga keadaan (memuat / galat + tombol coba lagi / data) sekali
/// saja, supaya tiap tab cukup menulis `muat()` dan `bangun()`. Fungsi
/// [segarkan] yang diteruskan ke [bangun] dipakai tab untuk memasang
/// `RefreshIndicator` sendiri.
class LmsTabData<T> extends StatefulWidget {
  const LmsTabData({
    super.key,
    required this.muat,
    required this.bangun,
  });

  final Future<T> Function() muat;
  final Widget Function(
    AppPalette p,
    T data,
    Future<void> Function() segarkan,
  )
  bangun;

  @override
  State<LmsTabData<T>> createState() => _LmsTabDataState<T>();
}

class _LmsTabDataState<T> extends State<LmsTabData<T>> {
  T? _data;
  String? _error;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    if (mounted) {
      setState(() {
        _memuat = _data == null;
        _error = null;
      });
    }
    try {
      final data = await widget.muat();
      if (mounted) {
        setState(() {
          _data = data;
          _memuat = false;
        });
      }
    } on MoodleException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _memuat = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data. Cek koneksi lalu coba lagi.';
          _memuat = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        if (_memuat) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LmsStatus(teks: 'Memuat...'),
          );
        }
        if (_error != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: LmsStatus(
              ikon: Icons.cloud_off,
              teks: _error!,
              aksi: OutlinedButton.icon(
                onPressed: _muat,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba lagi'),
              ),
            ),
          );
        }
        return widget.bangun(p, _data as T, _muat);
      },
    );
  }
}