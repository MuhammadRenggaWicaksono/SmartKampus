import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/supabase_config.dart';
import 'package:app_kampus/data/supabase_service.dart';

/// Satu baris hasil pemeriksaan.
class CekHasil {
  final String nama;
  final bool ok;
  final String detail;
  final bool peringatan;

  const CekHasil({
    required this.nama,
    required this.ok,
    required this.detail,
    this.peringatan = false,
  });
}

/// Halaman uji koneksi Supabase.
///
/// Tujuannya satu: membuktikan bahwa aplikasi benar-benar bisa membaca data
/// dari database kampus, bukan cuma "kelihatannya sudah tersambung".
/// Setiap pemeriksaan berdiri sendiri, jadi satu yang gagal tidak
/// menyembunyikan yang lain. Tombol "Salin laporan" menghasilkan teks yang
/// bisa langsung ditempel ke chat kalau ada yang merah.
class DiagnostikScreen extends StatefulWidget {
  const DiagnostikScreen({super.key});

  @override
  State<DiagnostikScreen> createState() => _DiagnostikScreenState();
}

class _DiagnostikScreenState extends State<DiagnostikScreen> {
  bool _memuat = false;
  List<CekHasil> _hasil = const [];
  String _laporan = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jalankan());
  }

  Future<void> _jalankan() async {
    setState(() {
      _memuat = true;
      _hasil = const [];
    });

    final hasil = <CekHasil>[];

    // 1. konfigurasi
    hasil.add(
      CekHasil(
        nama: 'Konfigurasi',
        ok: SupabaseConfig.terkonfigurasi,
        detail: SupabaseConfig.terkonfigurasi
            ? SupabaseConfig.url
            : 'URL/anon key belum diisi di lib/data/supabase_config.dart',
      ),
    );

    // 2. client
    hasil.add(
      CekHasil(
        nama: 'Inisialisasi client',
        ok: SupabaseService.siap,
        detail: SupabaseService.siap
            ? 'Supabase.initialize() berhasil'
            : (SupabaseService.errorInit ?? 'belum dijalankan'),
      ),
    );

    // 3. sesi
    final user = SupabaseService.user;
    hasil.add(
      CekHasil(
        nama: 'Sesi login',
        ok: user != null,
        detail: user == null
            ? 'Belum login. Masuk dulu lewat halaman Login.'
            : '${user.email ?? '(tanpa email)'}  ·  ${user.id}',
      ),
    );

    if (SupabaseService.siap && user != null) {
      // 4. koneksi mentah
      try {
        await SupabaseService.cekKoneksi();
        hasil.add(
          const CekHasil(
            nama: 'Koneksi ke database',
            ok: true,
            detail: 'Tabel public.profiles bisa dibaca',
          ),
        );
      } catch (e) {
        hasil.add(
          CekHasil(nama: 'Koneksi ke database', ok: false, detail: _ringkas(e)),
        );
      }

      // 5. profil + uji RLS
      try {
        final profil = await SupabaseService.profil();
        hasil.add(
          CekHasil(
            nama: 'Profil mahasiswa',
            ok: profil != null,
            detail: profil == null
                ? 'Baris profiles untuk user ini tidak ada. '
                      'Jalankan seed.sql BAGIAN 10 (daftarkan_mahasiswa).'
                : 'NIM ${profil.nim ?? '-'} · ${profil.nama} · '
                      'role ${profil.role} · ${profil.status}',
          ),
        );

        final terlihat = await SupabaseService.hitungProfilTerlihat();
        hasil.add(
          CekHasil(
            nama: 'Policy RLS profiles',
            ok: terlihat == 1,
            peringatan: terlihat == 0,
            detail: terlihat == 1
                ? 'Hanya 1 baris terlihat (benar)'
                : terlihat == 0
                ? 'Tidak ada baris terlihat. Cek policy profiles_baca.'
                : '$terlihat baris terlihat — RLS BOCOR, '
                      'seharusnya cuma 1 (milik sendiri).',
          ),
        );
      } catch (e) {
        hasil.add(
          CekHasil(nama: 'Profil mahasiswa', ok: false, detail: _ringkas(e)),
        );
      }

      // 6. ringkasan akademik
      try {
        final r = await SupabaseService.ringkasan();
        hasil.add(
          CekHasil(
            nama: 'View v_ringkasan_akademik',
            ok: r != null,
            detail: r == null
                ? 'Tidak ada baris. Pastikan KRS semester aktif ada.'
                : 'IPK ${r.ipk} · SKS lulus ${r.sksLulus} · '
                      'SKS semester ini ${r.sksSemesterIni} · '
                      '${r.jumlahMkAktif} mata kuliah · '
                      'sisa tagihan ${r.sisaTagihan}',
          ),
        );
      } catch (e) {
        hasil.add(
          CekHasil(
            nama: 'View v_ringkasan_akademik',
            ok: false,
            detail: _ringkas(e),
          ),
        );
      }

      // 7. IPS per semester
      try {
        final daftar = await SupabaseService.daftarIps();
        final ips = daftar.map((e) => '${e.periodeNama}: ${e.ips}').join(' | ');
        hasil.add(
          CekHasil(
            nama: 'View v_ips_periode',
            ok: daftar.isNotEmpty,
            detail: daftar.isEmpty ? 'Belum ada nilai yang masuk' : ips,
          ),
        );
      } catch (e) {
        hasil.add(
          CekHasil(nama: 'View v_ips_periode', ok: false, detail: _ringkas(e)),
        );
      }

      // 8. presensi
      try {
        final daftar = await SupabaseService.daftarPresensi();
        final hadir = daftar.fold<int>(0, (a, b) => a + b.hadir);
        final sabtu = daftar.fold<int>(
          0,
          (a, b) => a + b.sakit + b.izin + b.alpa,
        );
        hasil.add(
          CekHasil(
            nama: 'View v_rekap_presensi',
            ok: daftar.isNotEmpty,
            detail: daftar.isEmpty
                ? 'Belum ada presensi tercatat'
                : '${daftar.length} mata kuliah · hadir $hadir · '
                      'tidak hadir $sabtu',
          ),
        );
      } catch (e) {
        hasil.add(
          CekHasil(
            nama: 'View v_rekap_presensi',
            ok: false,
            detail: _ringkas(e),
          ),
        );
      }

      // 9. kelas aktif + relasi (uji foreign key PostgREST)
      try {
        final kelas = await SupabaseService.daftarKelasAktif();
        hasil.add(
          CekHasil(
            nama: 'Kelas aktif + relasi mata kuliah',
            ok: kelas.isNotEmpty,
            detail: kelas.isEmpty
                ? 'Tidak ada kelas dengan is_aktif = true'
                : '${kelas.length} kelas · contoh: '
                      '${kelas.first.mkNama} (${kelas.first.sks} SKS, '
                      '${kelas.first.dosenNama ?? 'dosen belum diisi'})',
          ),
        );
      } catch (e) {
        hasil.add(
          CekHasil(
            nama: 'Kelas aktif + relasi mata kuliah',
            ok: false,
            detail: _ringkas(e),
          ),
        );
      }
    }

    final laporan = _susunLaporan(hasil);
    if (!mounted) return;
    setState(() {
      _hasil = hasil;
      _laporan = laporan;
      _memuat = false;
    });
  }

  String _ringkas(Object e) {
    final s = e.toString();
    return s.length > 400 ? '${s.substring(0, 400)}…' : s;
  }

  String _susunLaporan(List<CekHasil> hasil) {
    final b = StringBuffer();
    b.writeln('=== Diagnostik Supabase SmartKampus ===');
    b.writeln('URL       : ${SupabaseConfig.url}');
    b.writeln('Client    : ${SupabaseService.siap ? "siap" : "belum siap"}');
    b.writeln('Sesi      : ${SupabaseService.user?.email ?? "belum login"}');
    b.writeln('');
    for (final h in hasil) {
      final tanda = h.ok ? 'OK' : (h.peringatan ? 'PERHATIAN' : 'GAGAL');
      b.writeln('[$tanda] ${h.nama}: ${h.detail}');
    }
    return b.toString();
  }

  void _salin() {
    if (_laporan.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _laporan));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Laporan disalin. Tempel ke chat kalau ada yang merah.',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
              'Diagnostik Supabase',
              style: TextStyle(color: p.textPrimary, fontSize: 18),
            ),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
            actions: [
              IconButton(
                tooltip: 'Salin laporan',
                icon: Icon(Icons.copy_all, color: p.accentText),
                onPressed: _laporan.isEmpty ? null : _salin,
              ),
              IconButton(
                tooltip: 'Ulangi',
                icon: Icon(Icons.refresh, color: p.accentText),
                onPressed: _memuat ? null : _jalankan,
              ),
            ],
          ),
          body: _memuat
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: p.accent),
                      const SizedBox(height: 16),
                      Text(
                        'Memeriksa koneksi…',
                        style: TextStyle(color: p.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildKesimpulan(p),
                    const SizedBox(height: 16),
                    ..._hasil.map((h) => _buildBaris(p, h)),
                    const SizedBox(height: 20),
                    Text(
                      'Catatan: halaman ini hanya membaca. Tidak ada data yang '
                      'diubah di database.',
                      style: TextStyle(fontSize: 11, color: p.textMuted),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildKesimpulan(AppPalette p) {
    final gagal = _hasil.where((h) => !h.ok && !h.peringatan).length;
    final perhatian = _hasil.where((h) => h.peringatan).length;
    final semuaOk = _hasil.isNotEmpty && gagal == 0 && perhatian == 0;

    final Color warna;
    final IconData ikon;
    final String judul;
    final String pesan;

    if (_hasil.isEmpty) {
      warna = p.textMuted;
      ikon = Icons.hourglass_empty;
      judul = 'Belum diperiksa';
      pesan = 'Tekan tombol ulangi di kanan atas.';
    } else if (semuaOk) {
      warna = kHadir;
      ikon = Icons.check_circle;
      judul = 'Tersambung';
      pesan =
          'Semua ${_hasil.length} pemeriksaan lolos. Data di aplikasi '
          'sekarang datang dari Supabase, bukan dummy.';
    } else if (gagal > 0) {
      warna = kAlpa;
      ikon = Icons.error;
      judul = '$gagal pemeriksaan gagal';
      pesan = 'Lihat baris merah di bawah, lalu salin laporan.';
    } else {
      warna = kSakit;
      ikon = Icons.warning_amber_rounded;
      judul = '$perhatian perlu perhatian';
      pesan = 'Koneksi jalan, tapi ada data yang belum lengkap.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warna.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: warna, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: warna,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pesan,
                  style: TextStyle(fontSize: 12, color: p.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaris(AppPalette p, CekHasil h) {
    final warna = h.ok ? kHadir : (h.peringatan ? kSakit : kAlpa);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: p.cardDeco(radius: 12, borderColor: p.border),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              h.ok
                  ? Icons.check_circle_outline
                  : (h.peringatan
                        ? Icons.warning_amber_rounded
                        : Icons.cancel_outlined),
              size: 18,
              color: warna,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.nama,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  h.detail,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
