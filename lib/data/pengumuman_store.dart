import 'package:flutter/foundation.dart';

import 'package:app_kampus/data/pengumuman_model.dart';
import 'package:app_kampus/data/supabase_service.dart';

/// Sumber data feed pengumuman untuk dashboard.
///
/// Tiga keadaan yang harus tetap kelihatan wajar, karena tabel `pengumuman`
/// di Supabase bisa saja belum ada saat aplikasi dijalankan:
///
/// 1. **Server** — query berhasil, isinya dari Supabase (badge tidak muncul).
/// 2. **Server kosong** — tabelnya ada tapi belum ada baris: tampilkan
///    "belum ada pengumuman", jangan diisi karangan.
/// 3. **Gagal / belum terhubung** — tabel belum dibuat, sedang offline, atau
///    RLS menolak: pakai [contoh] dan tandai [dariServer] = false supaya UI
///    bisa memberi catatan kecil bahwa isinya contoh.
///
/// Bedanya penting: memalsukan data server sebagai data sungguhan membuat
/// orang mengira pengumuman UKT-nya benar-benar terbit.
class PengumumanStore {
  PengumumanStore._();

  /// Daftar yang sudah siap tampil (sudah disaring dari yang kedaluwarsa).
  static final ValueNotifier<List<Pengumuman>> daftar =
      ValueNotifier<List<Pengumuman>>(const <Pengumuman>[]);

  /// true selama permintaan pertama masih berjalan.
  static final ValueNotifier<bool> memuat = ValueNotifier<bool>(false);

  /// true kalau isi [daftar] berasal dari Supabase.
  static final ValueNotifier<bool> dariServer = ValueNotifier<bool>(false);

  static DateTime? _terakhirMuat;
  static bool _sedangMuat = false;

  /// Umur cache. Dashboard ikut dibangun ulang setiap tab berpindah, jadi
  /// tanpa ini tiap kembali ke Dashboard akan menembak Supabase lagi.
  static const Duration _umurCache = Duration(minutes: 5);

  static Future<void> muat({bool paksa = false}) async {
    if (_sedangMuat) return;
    if (!paksa &&
        _terakhirMuat != null &&
        DateTime.now().difference(_terakhirMuat!) < _umurCache) {
      return;
    }

    _sedangMuat = true;
    if (daftar.value.isEmpty) memuat.value = true;

    // Mode demo / belum login: query pasti kosong, jadi tidak perlu ditembak.
    // Langsung data contoh, dan tandai sebagai contoh.
    if (!SupabaseService.siap || !SupabaseService.sudahLogin) {
      daftar.value = _siapkan(contoh);
      dariServer.value = false;
      _selesaiMuat();
      return;
    }

    try {
      final hasil = await SupabaseService.daftarPengumuman(batas: 30);
      daftar.value = _siapkan(hasil);
      dariServer.value = true;
    } catch (e) {
      // Tabel belum dibuat (PostgrestException 42P01), offline, atau RLS
      // menolak. Semuanya berakhir sama: pakai data contoh.
      SupabaseService.debugLog('pengumuman gagal dimuat: $e');
      if (daftar.value.isEmpty) {
        daftar.value = _siapkan(contoh);
        dariServer.value = false;
      }
    } finally {
      _selesaiMuat();
    }
  }

  static void _selesaiMuat() {
    _sedangMuat = false;
    memuat.value = false;
    _terakhirMuat = DateTime.now();
  }

  /// Buang yang belum terbit / sudah lewat, lalu urutkan.
  static List<Pengumuman> _siapkan(List<Pengumuman> isi) {
    final bersih = isi.where((p) => p.aktif).toList();
    bersih.sort(Pengumuman.banding);
    return bersih;
  }

  /// Isi cadangan saat Supabase belum bisa dipakai.
  ///
  /// Tanggalnya sengaja relatif terhadap hari ini supaya label "Kemarin" /
  /// "3 hari lalu" di kartu tetap masuk akal kapan pun aplikasi dijalankan.
  static List<Pengumuman> get contoh {
    final kini = DateTime.now();
    DateTime mundur(int hari) => kini.subtract(Duration(days: hari));
    DateTime maju(int hari) => kini.add(Duration(days: hari));

    return <Pengumuman>[
      Pengumuman(
        id: 'contoh-1',
        judul: 'Batas Pembayaran UKT Semester Ganjil 2026/2027',
        isi:
            'Pembayaran UKT gelombang akhir ditutup 20 November 2026. '
            'Mahasiswa yang belum melunasi tidak dapat mengikuti UAS.',
        kategori: 'keuangan',
        url: null,
        tanggalMulai: mundur(5),
        tanggalSelesai: maju(10),
        penting: true,
      ),
      Pengumuman(
        id: 'contoh-2',
        judul: 'Masa Perubahan KRS: 10 – 14 November 2026',
        isi:
            'Perubahan KRS dibuka terbatas lima hari dan wajib disetujui '
            'dosen pembimbing akademik.',
        kategori: 'akademik',
        url: null,
        tanggalMulai: kini,
        tanggalSelesai: maju(4),
        penting: true,
      ),
      Pengumuman(
        id: 'contoh-3',
        judul: 'Pendaftaran Beasiswa Prestasi Akademik 2026',
        isi:
            'Dibuka sampai 30 November 2026. Syarat: IPK minimal 3.25 dan '
            'tidak sedang menerima beasiswa lain.',
        kategori: 'kemahasiswaan',
        url: null,
        tanggalMulai: mundur(9),
        tanggalSelesai: maju(20),
        penting: false,
      ),
      Pengumuman(
        id: 'contoh-4',
        judul: 'Pemeliharaan Jaringan Kampus — WiFi dan SIAKAD',
        isi:
            'Sabtu pukul 22.00–04.00 WIB jaringan kampus dan SIAKAD dimatikan '
            'untuk pemeliharaan rutin.',
        kategori: 'darurat',
        url: null,
        tanggalMulai: mundur(2),
        tanggalSelesai: maju(6),
        penting: false,
      ),
    ];
  }
}