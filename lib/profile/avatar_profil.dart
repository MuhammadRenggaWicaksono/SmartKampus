import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/data/supabase_service.dart';

/// Avatar profil yang benar-benar bisa diubah.
///
/// Sebelumnya tombol kamera cuma memunculkan SnackBar "Pilih foto dari
/// galeri..." tanpa membuka apa pun. Sekarang:
///   ketuk avatar / tombol kamera -> pilih Galeri atau Kamera -> unggah
///   ke Supabase Storage -> URL-nya disimpan di `profiles.foto_url`.
///
/// Kalau belum login atau Supabase belum terhubung, avatar tetap tampil
/// sebagai inisial (perilaku lama) dan ketukan memberi tahu kenapa.
class AvatarProfil extends StatefulWidget {
  final double ukuran;
  final bool bisaDiubah;

  const AvatarProfil({super.key, this.ukuran = 70, this.bisaDiubah = true});

  @override
  State<AvatarProfil> createState() => _AvatarProfilState();
}

class _AvatarProfilState extends State<AvatarProfil> {
  static const Color _biru = Color(0xFF3B82F6);

  String? _url;
  bool _memuat = false;

  @override
  void initState() {
    super.initState();
    _url = SupabaseService.fotoProfil.value;
    SupabaseService.fotoProfil.addListener(_onFotoBerubah);
    _muat();
  }

  @override
  void dispose() {
    SupabaseService.fotoProfil.removeListener(_onFotoBerubah);
    super.dispose();
  }

  void _onFotoBerubah() {
    if (!mounted) return;
    setState(() => _url = SupabaseService.fotoProfil.value);
  }

  Future<void> _muat() async {
    if (!SupabaseService.siap || !SupabaseService.sudahLogin) return;
    try {
      final profil = await SupabaseService.profil();
      if (!mounted) return;
      // Titipkan ke notifier bersama, bukan cuma ke state lokal, supaya
      // avatar di halaman lain (Dashboard) ikut berubah.
      SupabaseService.fotoProfil.value = profil?.fotoUrl;
    } catch (e) {
      SupabaseService.debugLog('gagal memuat foto profil: $e');
    }
  }

  // ------------------------------------------------------------- aksi user
  Future<void> _bukaPilihan() async {
    if (!widget.bisaDiubah) return;

    if (!SupabaseService.sudahLogin) {
      _pesan(
        SupabaseService.siap
            ? 'Masuk dulu untuk mengubah foto profil.'
            : 'Supabase belum terhubung. Foto profil hanya bisa diubah '
                  'setelah login.',
      );
      return;
    }

    final aksi = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ThemeBuilder(
        builder: (context, p) => Container(
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(
                    color: p.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      Text(
                        'Foto Profil',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: p.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: p.accentText,
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: TextStyle(color: p.textPrimary, fontSize: 14),
                  ),
                  subtitle: Text(
                    'JPG, PNG, atau WEBP · maks 2 MB',
                    style: TextStyle(fontSize: 11, color: p.textSecondary),
                  ),
                  onTap: () => Navigator.pop(context, 'galeri'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_camera_outlined,
                    color: p.accentText,
                  ),
                  title: Text(
                    'Ambil dari Kamera',
                    style: TextStyle(color: p.textPrimary, fontSize: 14),
                  ),
                  onTap: () => Navigator.pop(context, 'kamera'),
                ),
                if (_url != null)
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: p.danger),
                    title: Text(
                      'Hapus Foto',
                      style: TextStyle(color: p.danger, fontSize: 14),
                    ),
                    onTap: () => Navigator.pop(context, 'hapus'),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );

    if (!mounted || aksi == null) return;

    switch (aksi) {
      case 'galeri':
        await _ambil(ImageSource.gallery);
      case 'kamera':
        await _ambil(ImageSource.camera);
      case 'hapus':
        await _hapus();
    }
  }

  Future<void> _ambil(ImageSource sumber) async {
    final namaSumber = sumber == ImageSource.camera ? 'kamera' : 'galeri';

    XFile? berkas;
    try {
      berkas = await ImagePicker().pickImage(
        source: sumber,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 78,
        preferredCameraDevice: CameraDevice.front,
      );
    } catch (e) {
      _galat('Tidak bisa membuka $namaSumber', e);
      return;
    }

    // null = pengguna menekan tombol batal, bukan error.
    if (berkas == null) return;

    setState(() => _memuat = true);
    try {
      final bytes = await berkas.readAsBytes();
      // URL-nya sudah dititipkan ke SupabaseService.fotoProfil oleh service,
      // jadi tidak perlu disimpan di sini.
      await SupabaseService.unggahFotoProfil(
        bytes,
        ekstensi: _ekstensi(berkas.name),
      );
      if (!mounted) return;
      setState(() => _memuat = false);
      _pesan('Foto profil diperbarui.');
    } catch (e) {
      if (!mounted) return;
      _galat('Gagal mengunggah foto', e);
    }
  }

  Future<void> _hapus() async {
    setState(() => _memuat = true);
    try {
      await SupabaseService.hapusFotoProfil();
      if (!mounted) return;
      setState(() => _memuat = false);
      _pesan('Foto profil dihapus.');
    } catch (e) {
      if (!mounted) return;
      _galat('Gagal menghapus foto', e);
    }
  }

  String _ekstensi(String namaBerkas) {
    final titik = namaBerkas.lastIndexOf('.');
    if (titik == -1 || titik == namaBerkas.length - 1) return 'jpg';
    final ext = namaBerkas.substring(titik + 1).toLowerCase();
    return const ['jpg', 'jpeg', 'png', 'webp'].contains(ext)
        ? (ext == 'jpeg' ? 'jpg' : ext)
        : 'jpg';
  }

  /// Petunjuk yang menyesuaikan dengan kode error dari plugin.
  ///
  /// Penting: galeri di Android TIDAK butuh izin apa pun (memakai Photo
  /// Picker / ACTION_GET_CONTENT). Jadi "tidak ada izin di Pengaturan" itu
  /// NORMAL — bukan penyebab masalah. Jangan lagi menyuruh pengguna
  /// mengecek izin untuk kasus galeri.
  String? _petunjuk(Object e) {
    if (e is MissingPluginException) {
      return 'Plugin kamera/galeri belum terpasang di aplikasi yang sedang '
          'berjalan. Ini terjadi kalau aplikasi belum di-build ulang setelah '
          'plugin ditambahkan, atau APK yang dipasang masih versi lama.\n\n'
          'Coba:\n  flutter clean\n  flutter run';
    }

    if (e is PlatformException) {
      switch (e.code) {
        case 'no_available_camera':
          return 'Perangkat ini tidak punya aplikasi kamera yang bisa '
              'dipanggil. Pakai "Pilih dari Galeri".';
        case 'camera_access_denied':
          return 'Izin kamera ditolak. Buka Pengaturan → Aplikasi → Kampus '
              'Pintar → Izin → Kamera.';
        case 'photo_access_denied':
          return 'Akses galeri ditolak oleh sistem.';
        case 'no_valid_image_uri':
        case 'missing_valid_image_uri':
          return 'Berkas yang dipilih tidak bisa dibaca. Coba pilih foto yang '
              'tersimpan lokal di HP (bukan dari Google Photos / cloud).';
        case 'no_valid_media_uri':
          return 'Media yang dipilih tidak bisa dibaca. Coba foto lain.';
      }
    }
    return null;
  }

  /// Tampilkan error apa adanya, lengkap dengan kode dari plugin, dan
  /// sediakan tombol salin supaya bisa dilaporkan.
  Future<void> _galat(String judul, Object error) async {
    if (!mounted) return;
    setState(() => _memuat = false);

    final detail = error is PlatformException
        ? 'tipe   : PlatformException\n'
              'kode   : ${error.code}\n'
              'pesan  : ${error.message}\n'
              'detail : ${error.details}'
        : error is MissingPluginException
        ? 'tipe   : MissingPluginException\npesan  : ${error.message}'
        : error.toString();

    final petunjuk = _petunjuk(error);

    await showDialog<void>(
      context: context,
      builder: (context) => ThemeBuilder(
        builder: (context, p) => AlertDialog(
          backgroundColor: p.card,
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  judul,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (petunjuk != null) ...[
                  Text(
                    petunjuk,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: p.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    detail,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.45,
                      color: p.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup', style: TextStyle(color: p.textSecondary)),
            ),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '$judul\n$detail'));
                Navigator.pop(context);
                _pesan('Detail error disalin.');
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Salin'),
            ),
          ],
        ),
      ),
    );
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(teks),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --------------------------------------------------------------- render
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => SizedBox(
        width: widget.ukuran,
        height: widget.ukuran,
        child: Stack(
          children: [
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.bisaDiubah ? _bukaPilihan : null,
                  child: _isi(p),
                ),
              ),
            ),

            if (widget.bisaDiubah)
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: p.card,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _memuat ? null : _bukaPilihan,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.camera_alt,
                        size: widget.ukuran * 0.22,
                        color: _biru,
                      ),
                    ),
                  ),
                ),
              ),

            if (_memuat)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _isi(AppPalette p) {
    final url = _url;
    if (url == null) return _inisial();

    return Image.network(
      url,
      width: widget.ukuran,
      height: widget.ukuran,
      fit: BoxFit.cover,
      // Kalau gambar gagal diunduh (offline / berkas dihapus), jatuh balik
      // ke inisial — jangan tampilkan kotak rusak.
      errorBuilder: (_, error, stack) => _inisial(),
      loadingBuilder: (context, child, progres) =>
          progres == null ? child : _inisial(),
    );
  }

  Widget _inisial() {
    return Container(
      width: widget.ukuran,
      height: widget.ukuran,
      alignment: Alignment.center,
      color: _biru,
      child: Text(
        AppData.inisial,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.ukuran * 0.32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
