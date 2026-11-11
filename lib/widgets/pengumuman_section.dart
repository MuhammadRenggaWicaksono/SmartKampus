import 'package:flutter/material.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/pengumuman_store.dart';
import 'package:app_kampus/pengumuman/pengumuman_kartu.dart';
import 'package:app_kampus/pengumuman/pengumuman_screen.dart';

/// Blok "Pengumuman" di dashboard — pengganti grid "Menu Cepat".
///
/// Kenapa menggantikan: keempat isi Menu Cepat (Jadwal, KRS, KHS, Presensi)
/// semuanya sudah bisa dicapai dari tab bawah, jadi blok itu tidak menambah
/// satu pun informasi baru — hanya menghabiskan ±192dp tinggi layar (≈26% di
/// layar 360×740). Pengumuman tidak bisa dicapai dari mana pun, dan isinya
/// berubah menurut waktu: itu yang pantas menempati beranda.
class PengumumanSection extends StatefulWidget {
  const PengumumanSection({super.key, this.maks = 3});

  /// Jumlah kartu yang tampil di dashboard. Sisanya lewat "Lihat semua".
  final int maks;

  @override
  State<PengumumanSection> createState() => _PengumumanSectionState();
}

class _PengumumanSectionState extends State<PengumumanSection> {
  @override
  void initState() {
    super.initState();
    // Aman dipanggil berkali-kali: store punya cache 5 menit dan penjaga
    // supaya tidak ada dua permintaan berjalan bersamaan.
    PengumumanStore.muat();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => AnimatedBuilder(
        animation: Listenable.merge([
          PengumumanStore.daftar,
          PengumumanStore.memuat,
        ]),
        builder: (context, _) {
          final semua = PengumumanStore.daftar.value;
          final isi = semua.take(widget.maks).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pengumuman',
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        color: p.textPrimary,
                      ),
                    ),
                  ),
                  if (semua.length > widget.maks) _lihatSemua(context, p),
                ],
              ),
              const SizedBox(height: 12),
              if (isi.isEmpty && PengumumanStore.memuat.value)
                ..._placeholder(p)
              else if (isi.isEmpty)
                Text(
                  'Belum ada pengumuman.',
                  style: TextStyle(fontSize: 12.5, color: p.textSecondary),
                )
              else
                ...isi.map(
                  (item) => Padding(
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
                  ),
                ),
              if (isi.isNotEmpty && !PengumumanStore.dariServer.value)
                _catatanContoh(p),
            ],
          );
        },
      ),
    );
  }

  Widget _lihatSemua(BuildContext context, AppPalette p) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PengumumanScreen()),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lihat semua',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: p.accentText,
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: p.accentText),
          ],
        ),
      ),
    );
  }

  /// Kerangka sementara selagi memuat, supaya dashboard tidak melompat saat
  /// kartu asli muncul.
  List<Widget> _placeholder(AppPalette p) {
    return List<Widget>.generate(
      2,
      (_) => Container(
        height: 78,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: p.cardDeco(radius: 12, elevated: false),
      ),
    );
  }

  /// Jujur soal sumber data: kalau isinya contoh, jangan diam.
  Widget _catatanContoh(AppPalette p) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 13, color: p.textMuted),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              'Contoh — tabel pengumuman di Supabase belum terhubung.',
              style: TextStyle(fontSize: 10.5, color: p.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}