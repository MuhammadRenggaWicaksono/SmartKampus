import 'app_data.dart';
import 'supabase_service.dart';

/// Satu sesi kuliah pada jadwal mingguan, bentuknya sudah seragam.
///
/// Datanya bisa datang dari `public.kelas_kuliah` (lewat
/// [SupabaseService.daftarKelasAktif]) atau dari [AppData.jadwalMingguan] saat
/// aplikasi jalan tanpa Supabase. Dua bentuk itu disamakan di sini supaya layar
/// jadwal tidak perlu tahu asalnya — dan supaya tidak ada lagi salinan jadwal
/// yang ditulis ulang di dalam widget.
class BarisJadwal {
  /// 1 = Senin ... 7 = Minggu, sama dengan kolom `hari` di `kelas_kuliah`.
  final int hari;
  final String jamMulai; // "08:00"
  final String jamSelesai; // "10:30"
  final String kodeMk; // "111500"
  final String namaMk;
  final int sks;
  final String ruang;
  final String dosen;

  /// Isi kolom `link_materi`. Null di jadwal bawaan karena yang tersimpan
  /// di sana cuma penanda "ada link", bukan alamatnya.
  final String? tautan;

  /// Penanda terpisah dari [tautan]: jadwal bawaan tahu ada link, tapi tidak
  /// tahu alamatnya.
  final bool adaTautan;

  const BarisJadwal({
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kodeMk,
    required this.namaMk,
    required this.sks,
    required this.ruang,
    required this.dosen,
    this.tautan,
    this.adaTautan = false,
  });

  String get namaHari => AppData.namaHari[hari - 1];

  String get rentangJam => '$jamMulai - $jamSelesai';

  int get menitMulai => _menit(jamMulai);

  /// Pemanggilnya sudah menyaring baris tanpa `hari`/`jam_mulai`, jadi
  /// keduanya aman di-`!`.
  factory BarisJadwal.dariDb(KelasKuliahDb k) {
    final tautan = (k.linkMateri ?? '').trim();
    return BarisJadwal(
      hari: k.hari!,
      jamMulai: _potongJam(k.jamMulai),
      jamSelesai: _potongJam(k.jamSelesai),
      kodeMk: _isi(k.mkKode, '-'),
      namaMk: _isi(k.mkNama, '(tanpa nama)'),
      sks: k.sks,
      ruang: _isi(k.ruang, '-'),
      dosen: _isi(k.dosenNama, 'Belum ditetapkan'),
      tautan: tautan.isEmpty ? null : tautan,
      adaTautan: tautan.isNotEmpty,
    );
  }

  factory BarisJadwal.dariLokal(int hari, KelasKuliah k) => BarisJadwal(
    hari: hari,
    jamMulai: k.jamMulai,
    jamSelesai: k.jamSelesai,
    kodeMk: _isi(k.kode, '-'),
    namaMk: _isi(k.nama, '(tanpa nama)'),
    sks: k.sks,
    ruang: _isi(k.ruang, '-'),
    dosen: _isi(k.dosen, 'Belum ditetapkan'),
    adaTautan: k.adaLink,
  );
}

/// Jadwal satu hari yang sudah terkelompok dan terurut.
class HariJadwal {
  final int hari;
  final List<BarisJadwal> kelas;

  const HariJadwal({required this.hari, required this.kelas});

  String get nama => AppData.namaHari[hari - 1];

  int get totalSks => kelas.fold(0, (total, k) => total + k.sks);
}

/// Hasil satu kali pemuatan jadwal, lengkap dengan asal datanya.
///
/// Layar perlu [dariDatabase] supaya bisa jujur menuliskan sumbernya,
/// bukan menampilkan jadwal bawaan seolah-olah datang dari server.
class HasilJadwal {
  final List<HariJadwal> hari;
  final bool dariDatabase;

  /// Alasan jatuh ke jadwal bawaan, kalau memang jatuh.
  final String? catatan;

  const HasilJadwal({
    required this.hari,
    required this.dariDatabase,
    this.catatan,
  });

  bool get kosong => hari.isEmpty;

  int get totalKelas => hari.fold(0, (total, h) => total + h.kelas.length);

  int get totalSks => hari.fold(0, (total, h) => total + h.totalSks);
}

class JadwalData {
  const JadwalData._();

  /// Baca jadwal dari database. Kalau database kosong atau aplikasi sedang
  /// jalan tanpa Supabase, pakai [AppData.jadwalMingguan] dan bilang terus
  /// terang lewat [HasilJadwal.catatan].
  static Future<HasilJadwal> muat() async {
    String? catatan;

    if (!SupabaseService.siap || !SupabaseService.sudahLogin) {
      catatan = 'Supabase belum tersambung';
    } else {
      try {
        final rows = await SupabaseService.daftarKelasAktif();
        final baris = <BarisJadwal>[];
        for (final k in rows) {
          final hari = k.hari;
          if (hari == null || hari < 1 || hari > 7) continue;
          if ((k.jamMulai ?? '').trim().isEmpty) continue;
          baris.add(BarisJadwal.dariDb(k));
        }
        if (baris.isNotEmpty) {
          return HasilJadwal(hari: kelompokkan(baris), dariDatabase: true);
        }
        catatan = 'kelas_kuliah belum diisi';
      } catch (_) {
        catatan = 'gagal membaca kelas_kuliah';
      }
    }

    return HasilJadwal(
      hari: kelompokkan(dariLokal()),
      dariDatabase: false,
      catatan: catatan,
    );
  }

  /// Jadwal bawaan aplikasi dalam bentuk [BarisJadwal].
  static List<BarisJadwal> dariLokal() {
    final hasil = <BarisJadwal>[];
    AppData.jadwalMingguan.forEach((nama, kelas) {
      final indeks = AppData.namaHari.indexOf(nama);
      if (indeks < 0) return;
      for (final k in kelas) {
        hasil.add(BarisJadwal.dariLokal(indeks + 1, k));
      }
    });
    return hasil;
  }

  /// Kelompokkan per hari, urut hari lalu jam — supaya urutan tampil tidak
  /// bergantung pada urutan baris yang dikirim PostgREST.
  static List<HariJadwal> kelompokkan(List<BarisJadwal> baris) {
    final perHari = <int, List<BarisJadwal>>{};
    for (final b in baris) {
      perHari.putIfAbsent(b.hari, () => <BarisJadwal>[]).add(b);
    }
    final hari = perHari.keys.toList()..sort();
    return hari
        .map(
          (h) => HariJadwal(
            hari: h,
            kelas: perHari[h]!
              ..sort((a, b) => a.menitMulai.compareTo(b.menitMulai)),
          ),
        )
        .toList();
  }
}

int _menit(String jam) {
  final bagian = jam.split(':');
  if (bagian.length < 2) return 0;
  final jamKe = int.tryParse(bagian[0].trim()) ?? 0;
  final menitKe = int.tryParse(
    bagian[1].length > 2 ? bagian[1].substring(0, 2) : bagian[1].trim(),
  );
  return jamKe * 60 + (menitKe ?? 0);
}

/// `'08:00:00'` (tipe `time` Postgres) jadi `'08:00'`. Nilai asing dibiarkan
/// apa adanya, dan yang kosong jadi `'--:--'` supaya kolomnya tidak bolong.
String _potongJam(String? mentah) {
  final teks = (mentah ?? '').trim();
  if (teks.length > 5 && teks[2] == ':') return teks.substring(0, 5);
  return teks.isEmpty ? '--:--' : teks;
}

String _isi(String? nilai, String bawaan) {
  final teks = (nilai ?? '').trim();
  return teks.isEmpty ? bawaan : teks;
}
