import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/data/supabase_config.dart';
import 'package:app_kampus/data/supabase_service.dart';

void main() {
  group('SupabaseConfig', () {
    test('aturan terkonfigurasi', () {
      // Nilainya bisa berubah tergantung apakah developer sudah mengisi
      // supabase_config.dart. Yang diuji adalah ATURANNYA, bukan nilai
      // sesaatnya — supaya test tidak merah hanya karena kredensial diisi.
      final url = SupabaseConfig.url.trim();
      final key = SupabaseConfig.anonKey.trim();

      if (SupabaseConfig.terkonfigurasi) {
        expect(url, startsWith('https://'));
        expect(url.contains('GANTI'), isFalse);
        expect(key.isEmpty, isFalse);
        expect(key.contains('GANTI'), isFalse);
      } else {
        final adaPlaceholder =
            url.contains('GANTI') || key.contains('GANTI');
        final adaKosong = url.isEmpty || key.isEmpty;
        expect(adaPlaceholder || adaKosong, isTrue);
      }
    });

    test('nama view/tabel tidak kosong', () {
      expect(SupabaseConfig.vRingkasan, 'v_ringkasan_akademik');
      expect(SupabaseConfig.vIps, 'v_ips_periode');
      expect(SupabaseConfig.vPresensi, 'v_rekap_presensi');
      expect(SupabaseConfig.tProfil, 'profiles');
    });
  });

  group('SupabaseService tanpa koneksi (mode demo)', () {
    test('siap == false dan modeDemo == true sebelum init', () {
      expect(SupabaseService.siap, isFalse);
      expect(SupabaseService.modeDemo, isTrue);
      expect(SupabaseService.sudahLogin, isFalse);
      expect(SupabaseService.user, isNull);
      expect(SupabaseService.sesi, isNull);
    });

    test('semua query mengembalikan kosong, tidak melempar exception', () async {
      // Ini penting: layar tidak boleh crash kalau Supabase belum diisi.
      expect(await SupabaseService.profil(), isNull);
      expect(await SupabaseService.ringkasan(), isNull);
      expect(await SupabaseService.daftarIps(), isEmpty);
      expect(await SupabaseService.daftarPresensi(), isEmpty);
      expect(await SupabaseService.daftarKelasAktif(), isEmpty);
      expect(await SupabaseService.hitungProfilTerlihat(), 0);
    });

    test('masuk() menolak dengan pesan, bukan exception', () async {
      final pesan = await SupabaseService.masuk(
        email: 'a@b.c',
        password: 'x',
      );
      expect(pesan, isNotNull);
    });

    test('keluar() tidak melempar saat belum terhubung', () async {
      await SupabaseService.keluar();
    });
  });

  group('Mapping hasil query', () {
    test('RingkasanAkademik dari map numeric campuran', () {
      // PostgREST mengirim numeric sebagai JSON number: 3.67 -> double,
      // 0 -> int. Pemetaan harus tahan dua-duanya.
      final r = RingkasanAkademik.fromMap({
        'mahasiswa_id': '3f1c0e6a-0000-4000-8000-000000000000',
        'nim': '2411044',
        'nama': 'Muhammad Rengga Wicaksono',
        'nama_panggilan': 'Rengga',
        'semester_ke': 5,
        'ipk': 3.67,
        'sks_lulus': 93,
        'jumlah_mk_aktif': 8,
        'sks_semester_ini': 23,
        'sisa_tagihan': 0,
      });

      expect(r.nim, '2411044');
      expect(r.namaPanggilan, 'Rengga');
      expect(r.semesterKe, 5);
      expect(r.ipk, 3.67);
      expect(r.sksLulus, 93);
      expect(r.jumlahMkAktif, 8);
      expect(r.sksSemesterIni, 23);
      expect(r.sisaTagihan, 0);
    });

    test('RingkasanAkademik tahan nilai null / ipk bulat', () {
      final r = RingkasanAkademik.fromMap(<String, dynamic>{
        'ipk': 4, // numeric 4.00 bisa datang sebagai int
        'sisa_tagihan': 9000000.5,
      });

      expect(r.ipk, 4.0);
      expect(r.sisaTagihan, 9000000.5);
      expect(r.nim, '-');
      expect(r.semesterKe, isNull);
      expect(r.sksLulus, 0);
    });

    test('IpsPeriode dari map', () {
      final i = IpsPeriode.fromMap({
        'periode_nama': 'Semester Ganjil 2024/2025',
        'sks_diambil': 23,
        'ips': 3.66,
      });
      expect(i.periodeNama, 'Semester Ganjil 2024/2025');
      expect(i.sksDiambil, 23);
      expect(i.ips, 3.66);
    });

    test('RekapPresensi dari map', () {
      final p = RekapPresensi.fromMap({
        'mk_nama': 'JARINGAN NIRKABEL',
        'hadir': 9,
        'sakit': 1,
        'izin': 0,
        'alpa': 0,
        'pertemuan_terlaksana': 10,
        'pertemuan_rencana': 16,
        'persen_dari_rencana': 56,
      });
      expect(p.mkNama, 'JARINGAN NIRKABEL');
      expect(p.hadir + p.sakit + p.izin + p.alpa, p.terlaksana);
      expect(p.rencana, 16);
      expect(p.persenDariRencana, 56);
    });

    test('KelasKuliahDb membaca relasi bersarang (mata_kuliah, dosen)', () {
      final k = KelasKuliahDb.fromMap({
        'kode_kelas': 'IFB5A',
        'ruang': 'LAB D (FIKOM)',
        'hari': 1,
        'jam_mulai': '08:00:00',
        'jam_selesai': '10:30:00',
        'link_materi': null,
        'mata_kuliah': {'kode': '111500', 'nama': 'SISTEM MANAJEMEN BASIS DATA', 'sks': 3},
        'dosen': {'nama': 'NASRUDDIN BIN IDRIS'},
      });

      expect(k.kodeKelas, 'IFB5A');
      expect(k.mkNama, 'SISTEM MANAJEMEN BASIS DATA');
      expect(k.sks, 3);
      expect(k.dosenNama, 'NASRUDDIN BIN IDRIS');
      expect(k.hari, 1);
      expect(k.linkMateri, isNull);
    });

    test('KelasKuliahDb tahan relasi null', () {
      final k = KelasKuliahDb.fromMap({'kode_kelas': 'IFB4B'});
      expect(k.kodeKelas, 'IFB4B');
      expect(k.mkNama, '-');
      expect(k.sks, 0);
      expect(k.dosenNama, isNull);
    });
  });
}