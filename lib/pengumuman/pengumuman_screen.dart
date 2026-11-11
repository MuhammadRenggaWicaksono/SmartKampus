import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/pengumuman_model.dart';
import 'package:app_kampus/data/pengumuman_store.dart';
import 'package:app_kampus/pengumuman/pengumuman_kartu.dart';

/// Daftar lengkap pengumuman. Dibuka dari tombol "Lihat semua" di dashboard.
class PengumumanScreen extends StatefulWidget {
  const PengumumanScreen({super.key});

  @override
  State<PengumumanScreen> createState() => _PengumumanScreenState();
}

class _PengumumanScreenState extends State<PengumumanScreen> {
  @override
  void initState() {
    super.initState();
    // Halaman ini dibuka dengan sengaja, jadi pakai cache bila masih segar
    // tapi jangan sampai menampilkan data lama tanpa usaha menyegarkan.
    PengumumanStore.muat();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Pengumuman',
              style: TextStyle(color: p.textPrimary, fontSize: 18),
            ),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
          ),
          body: AnimatedBuilder(
            animation: Listenable.merge([
              PengumumanStore.daftar,
              PengumumanStore.memuat,
            ]),
            builder: (context, _) {
              final isi = PengumumanStore.daftar.value;

              if (isi.isEmpty && PengumumanStore.memuat.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (isi.isEmpty) {
                return Center(
                  child: Text(
                    'Belum ada pengumuman.',
                    style: TextStyle(color: p.textSecondary),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                itemCount: isi.length + 1,
                itemBuilder: (context, i) {
                  if (i == isi.length) {
                    return PengumumanStore.dariServer.value
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Contoh — tabel pengumuman di Supabase belum '
                              'terhubung.',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: p.textMuted,
                              ),
                            ),
                          );
                  }
                  final item = isi[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: KartuPengumuman(
                      p: p,
                      pengumuman: item,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PengumumanDetailScreen(pengumuman: item),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Isi lengkap satu pengumuman.
class PengumumanDetailScreen extends StatelessWidget {
  const PengumumanDetailScreen({super.key, required this.pengumuman});

  final Pengumuman pengumuman;

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        final warna = warnaKategori(pengumuman.kategori, p);
        final berlaku = pengumuman.berlakuSampaiLabel;
        final jejak = berlaku == null
            ? pengumuman.waktuLabel
            : '${pengumuman.waktuLabel} • $berlaku';

        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Detail Pengumuman',
                style: TextStyle(color: p.textPrimary, fontSize: 18),
              ),
              backgroundColor: p.card,
              foregroundColor: p.textPrimary,
              iconTheme: IconThemeData(color: p.textPrimary),
              elevation: 0.5,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: p.cardDeco(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ChipKategori(pengumuman.kategoriLabel, warna, p),
                        if (pengumuman.penting) ...[
                          const SizedBox(width: 6),
                          ChipKategori(
                            'PENTING',
                            const Color(0xFFDC2626),
                            p,
                            solid: true,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pengumuman.judul,
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.3,
                        fontWeight: FontWeight.bold,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      jejak,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: p.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: p.divider, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      pengumuman.isi,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.6,
                        color: p.textPrimary,
                      ),
                    ),
                    if (pengumuman.url != null) ...[
                      const SizedBox(height: 18),
                      _tutupTautan(context, p, pengumuman.url!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// pubspec belum punya `url_launcher`, jadi tautan disediakan untuk disalin
  /// (bisa ditekan-lama untuk seleksi) — bukan tombol yang tidak berbuat apa-apa.
  Widget _tutupTautan(BuildContext context, AppPalette p, String url) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.link, size: 18, color: p.accentText),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              url,
              style: TextStyle(fontSize: 12, color: p.accentText),
            ),
          ),
          IconButton(
            tooltip: 'Salin tautan',
            icon: Icon(Icons.copy, size: 18, color: p.textSecondary),
            onPressed: () => _salin(context, url),
          ),
        ],
      ),
    );
  }

  Future<void> _salin(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tautan disalin')));
  }
}