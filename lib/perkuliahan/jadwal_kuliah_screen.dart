import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/data/jadwal_data.dart';

/// Warna identitas tiap hari — konstanta pekat, bukan bagian dari tema.
///
/// Gunanya menandai hari, bukan menyampaikan status, jadi maknanya tetap di
/// ketiga mode. Semuanya lolos kontras 4.5:1 terhadap huruf putih, sehingga pil
/// hari terbaca sama di Light, Dark, maupun LGBT.
const List<Color> kHariWarna = <Color>[
  Color(0xFF2563EB), // Senin  — biru
  Color(0xFF0F766E), // Selasa — teal
  Color(0xFF7C3AED), // Rabu   — ungu
  Color(0xFFB45309), // Kamis  — amber tua
  Color(0xFFBE123C), // Jumat  — rose
  Color(0xFF0369A1), // Sabtu  — biru laut
  Color(0xFF4D7C0F), // Minggu — olive
];

Color _warnaHari(int hari) =>
    kHariWarna[(hari - 1).clamp(0, kHariWarna.length - 1)];

/// Warna hari untuk teks di atas kartu. Di mode gelap warna pekat itu terlalu
/// gelap buat huruf 12-15pt, jadi dicerahkan dulu.
Color _tinta(AppPalette p, Color warna) =>
    p.isDark ? Color.lerp(warna, Colors.white, 0.45)! : warna;

/// Tiga huruf pertama nama hari, buat kotak penanda di kepala seksi.
String _singkat(String nama) =>
    nama.length <= 3 ? nama.toUpperCase() : nama.substring(0, 3).toUpperCase();

class JadwalKuliahScreen extends StatefulWidget {
  const JadwalKuliahScreen({super.key});

  @override
  State<JadwalKuliahScreen> createState() => _JadwalKuliahScreenState();
}

class _JadwalKuliahScreenState extends State<JadwalKuliahScreen> {
  bool _memuat = true;
  HasilJadwal? _hasil;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    if (!_memuat) setState(() => _memuat = true);
    final hasil = await JadwalData.muat();
    if (!mounted) return;
    setState(() {
      _hasil = hasil;
      _memuat = false;
    });
  }

  void _unduhJadwal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengunduh jadwal dalam format PDF...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _bukaTautan(BarisJadwal kelas) {
    final tautan = kelas.tautan;
    if (tautan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tautan materi ${kelas.namaMk} ada, tapi alamatnya '
            'belum tersimpan di database',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: tautan));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tautan materi ${kelas.namaMk} disalin:\n$tautan',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        final hasil = _hasil;
        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Jadwal Kuliah',
                style: TextStyle(color: p.textPrimary, fontSize: 18),
              ),
              backgroundColor: p.card,
              foregroundColor: p.textPrimary,
              iconTheme: IconThemeData(color: p.textPrimary),
              elevation: 0.5,
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, color: p.textPrimary),
                  tooltip: 'Muat ulang jadwal',
                  onPressed: _memuat ? null : _muat,
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  tooltip: 'Download Jadwal PDF',
                  onPressed: _unduhJadwal,
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                if (hasil != null) _kepala(p, hasil),
                if (_memuat && hasil != null)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: hasil == null
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _muat,
                          child: hasil.kosong
                              ? _kosong(p, hasil)
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    14,
                                    16,
                                    24,
                                  ),
                                  itemCount: hasil.hari.length,
                                  itemBuilder: (context, index) =>
                                      _seksiHari(p, hasil.hari[index]),
                                ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Kepala layar: periode aktif, ringkasan isi, dan dari mana datanya datang.
  Widget _kepala(AppPalette p, HasilJadwal hasil) {
    final warnaSumber = hasil.dariDatabase ? p.success : p.warning;
    return Container(
      width: double.infinity,
      color: p.card,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEMESTER AKTIF',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: p.textCardLabel,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppData.semesterAktif,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: warnaSumber.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  hasil.dariDatabase ? 'DATABASE' : 'DATA LOKAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: warnaSumber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              _chip(p, Icons.event_note_outlined, '${hasil.totalKelas} kelas'),
              const SizedBox(width: 8),
              _chip(p, Icons.school_outlined, '${hasil.totalSks} SKS'),
            ],
          ),
          if (!hasil.dariDatabase) ...[
            const SizedBox(height: 9),
            Text(
              hasil.catatan == null
                  ? 'Menampilkan jadwal bawaan aplikasi.'
                  : 'Menampilkan jadwal bawaan aplikasi — ${hasil.catatan}.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.3,
                color: p.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(AppPalette p, IconData ikon, String teks) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: p.chipBackground,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      children: [
        Icon(ikon, size: 13, color: p.textSecondary),
        const SizedBox(width: 5),
        Text(
          teks,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ],
    ),
  );

  /// Satu hari = satu kartu berkepala warna sendiri.
  ///
  /// Sebelumnya semua hari memakai kartu biru yang sama, jadi batas antar hari
  /// hilang begitu daftarnya panjang. Sekarang tiap hari punya warna identitas
  /// yang dipakai di kepala seksi, tulang baris, dan pil "HARI INI".
  Widget _seksiHari(AppPalette p, HariJadwal hari) {
    final warna = _warnaHari(hari.hari);
    final hariIni = AppData.namaHariDari(DateTime.now()) == hari.nama;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: p.cardDeco(radius: 14, borderColor: p.border),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: p.isDark ? 0.20 : 0.09),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: warna,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _singkat(hari.nama),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hari.nama.toUpperCase(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: p.textPrimary,
                    ),
                  ),
                ),
                if (hariIni)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: warna,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'HARI INI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                Text(
                  '${hari.kelas.length} · ${hari.totalSks} SKS',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < hari.kelas.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: p.divider),
            _barisKelas(p, hari.kelas[i], warna),
          ],
        ],
      ),
    );
  }

  Widget _barisKelas(AppPalette p, BarisJadwal kelas, Color warna) {
    final tinta = _tinta(p, warna);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tulang warna hari: tetap kelihatan walau kepalanya sudah tergulung.
          Container(width: 3, color: warna),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kelas.jamMulai,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: tinta,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          kelas.jamSelesai,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                            color: p.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kelas.namaMk,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.room_outlined,
                              size: 14,
                              color: p.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                kelas.ruang,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: p.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: p.chipBackground,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${kelas.kodeMk} · ${kelas.sks} SKS',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: p.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: p.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                kelas.dosen,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.25,
                                  color: p.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (kelas.adaTautan)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => _bukaTautan(kelas),
                              icon: const Icon(Icons.link, size: 15),
                              label: const Text('Tautan materi'),
                              style: TextButton.styleFrom(
                                foregroundColor: p.success,
                                minimumSize: const Size(0, 32),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Keadaan kosong tetap bisa ditarik-turun untuk memuat ulang, jadi isinya
  /// scrollable, bukan Center biasa.
  Widget _kosong(AppPalette p, HasilJadwal hasil) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      children: [
        Icon(Icons.event_busy_outlined, size: 44, color: p.textMuted),
        const SizedBox(height: 14),
        Text(
          'Belum ada jadwal kuliah',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hasil.catatan == null
              ? 'Isi tabel kelas_kuliah untuk periode aktif, lalu muat ulang.'
              : 'Isi tabel kelas_kuliah untuk periode aktif (${hasil.catatan}), '
                    'lalu muat ulang.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, height: 1.4, color: p.textSecondary),
        ),
        const SizedBox(height: 18),
        Center(
          child: ElevatedButton.icon(
            onPressed: _muat,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Muat ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: p.accentInk,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
