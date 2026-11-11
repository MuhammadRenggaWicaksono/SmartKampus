import 'package:flutter/material.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/data/pengumuman_model.dart';

/// Warna identitas per kategori pengumuman.
///
/// Kategori di database tidak punya CHECK constraint, jadi nilai yang tidak
/// dikenal jatuh ke warna aksen tema — bukan crash, bukan chip kosong.
Color warnaKategori(String kategori, AppPalette p) => switch (kategori) {
  'akademik' => Colors.blue,
  'keuangan' => const Color(0xFF16A34A),
  'kemahasiswaan' => Colors.purple,
  'skripsi' => Colors.teal,
  'darurat' => const Color(0xFFDC2626),
  _ => p.accentText,
};

/// Chip kecil: label kategori, atau penanda PENTING ([solid] = true).
///
/// Warna mentah di atas sengaja TIDAK dipakai sebagai warna huruf: `blue`
/// mentah cuma 3.12:1 di kartu putih, dan 9.5pt adalah ukuran yang paling
/// gampang hilang. Teks selalu lewat [AppPalette.chipInk], yang mengembalikan
/// versi pekat (Light) / terang (Dark) yang lolos ≥4.6:1 di latar chip.
class ChipKategori extends StatelessWidget {
  const ChipKategori(
    this.teks,
    this.warna,
    this.p, {
    super.key,
    this.solid = false,
  });

  final String teks;
  final Color warna;
  final AppPalette p;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final tinta = p.chipInk(warna);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: solid ? tinta : warna.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        teks,
        maxLines: 1,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: solid ? p.onChipInk : tinta,
        ),
      ),
    );
  }
}

/// Kartu satu pengumuman.
///
/// [onTap] sengaja dilempar dari luar (bukan `Navigator.push` di dalam) supaya
/// kartu ini bisa dipakai dashboard maupun halaman daftar tanpa saling
/// mengimpor layar.
class KartuPengumuman extends StatelessWidget {
  const KartuPengumuman({
    super.key,
    required this.p,
    required this.pengumuman,
    required this.onTap,
  });

  final AppPalette p;
  final Pengumuman pengumuman;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final warna = warnaKategori(pengumuman.kategori, p);

    return Container(
      decoration: p.cardDeco(
        radius: 12,
        borderColor: pengumuman.penting
            ? warna.withValues(alpha: 0.45)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                    const Spacer(),
                    Flexible(
                      child: Text(
                        pengumuman.waktuLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: p.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pengumuman.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pengumuman.isi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}