import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:app_kampus/data/supabase_config.dart';

// ============================================================================
// MODEL HASIL QUERY (bentuknya mengikuti view di schema.sql)
// ============================================================================

/// Satu baris `v_ringkasan_akademik`.
class RingkasanAkademik {
  final String nim;
  final String nama;
  final String namaPanggilan;
  final int? semesterKe;
  final double ipk;
  final int sksLulus;
  final int jumlahMkAktif;
  final int sksSemesterIni;
  final num sisaTagihan;

  const RingkasanAkademik({
    required this.nim,
    required this.nama,
    required this.namaPanggilan,
    required this.semesterKe,
    required this.ipk,
    required this.sksLulus,
    required this.jumlahMkAktif,
    required this.sksSemesterIni,
    required this.sisaTagihan,
  });

  factory RingkasanAkademik.fromMap(Map<String, dynamic> m) {
    return RingkasanAkademik(
      nim: (m['nim'] ?? '-').toString(),
      nama: (m['nama'] ?? '-').toString(),
      namaPanggilan: (m['nama_panggilan'] ?? 'Mahasiswa').toString(),
      semesterKe: (m['semester_ke'] as num?)?.toInt(),
      ipk: (m['ipk'] as num?)?.toDouble() ?? 0,
      sksLulus: (m['sks_lulus'] as num?)?.toInt() ?? 0,
      jumlahMkAktif: (m['jumlah_mk_aktif'] as num?)?.toInt() ?? 0,
      sksSemesterIni: (m['sks_semester_ini'] as num?)?.toInt() ?? 0,
      sisaTagihan: (m['sisa_tagihan'] as num?) ?? 0,
    );
  }
}

/// Satu baris `v_ips_periode`.
class IpsPeriode {
  final String periodeNama;
  final int sksDiambil;
  final double ips;

  const IpsPeriode({
    required this.periodeNama,
    required this.sksDiambil,
    required this.ips,
  });

  factory IpsPeriode.fromMap(Map<String, dynamic> m) => IpsPeriode(
    periodeNama: (m['periode_nama'] ?? '-').toString(),
    sksDiambil: (m['sks_diambil'] as num?)?.toInt() ?? 0,
    ips: (m['ips'] as num?)?.toDouble() ?? 0,
  );
}

/// Satu baris `v_rekap_presensi`.
class RekapPresensi {
  final String mkNama;
  final int hadir;
  final int sakit;
  final int izin;
  final int alpa;
  final int terlaksana;
  final int rencana;
  final int persenDariRencana;

  const RekapPresensi({
    required this.mkNama,
    required this.hadir,
    required this.sakit,
    required this.izin,
    required this.alpa,
    required this.terlaksana,
    required this.rencana,
    required this.persenDariRencana,
  });

  factory RekapPresensi.fromMap(Map<String, dynamic> m) => RekapPresensi(
    mkNama: (m['mk_nama'] ?? '-').toString(),
    hadir: (m['hadir'] as num?)?.toInt() ?? 0,
    sakit: (m['sakit'] as num?)?.toInt() ?? 0,
    izin: (m['izin'] as num?)?.toInt() ?? 0,
    alpa: (m['alpa'] as num?)?.toInt() ?? 0,
    terlaksana: (m['pertemuan_terlaksana'] as num?)?.toInt() ?? 0,
    rencana: (m['pertemuan_rencana'] as num?)?.toInt() ?? 16,
    persenDariRencana: (m['persen_dari_rencana'] as num?)?.toInt() ?? 0,
  );
}

/// Satu baris `kelas_kuliah` + relasi `mata_kuliah` dan `dosen`.
class KelasKuliahDb {
  final String kodeKelas;
  final String? ruang;
  final int? hari;
  final String? jamMulai;
  final String? jamSelesai;
  final String? linkMateri;
  final String mkKode;
  final String mkNama;
  final int sks;
  final String? dosenNama;

  const KelasKuliahDb({
    required this.kodeKelas,
    required this.ruang,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.linkMateri,
    required this.mkKode,
    required this.mkNama,
    required this.sks,
    required this.dosenNama,
  });

  factory KelasKuliahDb.fromMap(Map<String, dynamic> m) {
    final mk = (m['mata_kuliah'] as Map?) ?? const {};
    final dosen = (m['dosen'] as Map?) ?? const {};
    return KelasKuliahDb(
      kodeKelas: (m['kode_kelas'] ?? '-').toString(),
      ruang: m['ruang']?.toString(),
      hari: (m['hari'] as num?)?.toInt(),
      jamMulai: m['jam_mulai']?.toString(),
      jamSelesai: m['jam_selesai']?.toString(),
      linkMateri: m['link_materi']?.toString(),
      mkKode: (mk['kode'] ?? '-').toString(),
      mkNama: (mk['nama'] ?? '-').toString(),
      sks: (mk['sks'] as num?)?.toInt() ?? 0,
      dosenNama: dosen['nama']?.toString(),
    );
  }
}

/// Satu baris `profiles`.
class ProfilDb {
  final String id;
  final String? nim;
  final String nama;
  final String namaPanggilan;
  final String role;
  final String status;
  final String? email;
  final String? fotoUrl;

  const ProfilDb({
    required this.id,
    required this.nim,
    required this.nama,
    required this.namaPanggilan,
    required this.role,
    required this.status,
    required this.email,
    this.fotoUrl,
  });

  factory ProfilDb.fromMap(Map<String, dynamic> m) => ProfilDb(
    id: (m['id'] ?? '').toString(),
    nim: m['nim']?.toString(),
    nama: (m['nama'] ?? '-').toString(),
    namaPanggilan: (m['nama_panggilan'] ?? 'Mahasiswa').toString(),
    role: (m['role'] ?? 'mahasiswa').toString(),
    status: (m['status'] ?? 'aktif').toString(),
    email: m['email']?.toString(),
    fotoUrl: (m['foto_url'] as String?)?.trim().isEmpty ?? true
        ? null
        : m['foto_url'] as String,
  );
}

// ============================================================================
// SERVICE
// ============================================================================

/// Pembungkus tipis di atas Supabase.
///
/// Kalau Supabase belum dikonfigurasi, [siap] bernilai false dan aplikasi
/// tetap bisa jalan dengan data dummy (`AppData`) — tidak ada layar yang crash.
class SupabaseService {
  SupabaseService._();

  static bool _siap = false;
  static String? _errorInit;

  /// URL foto profil yang sedang aktif.
  ///
  /// Dipakai bersama oleh avatar di halaman Akun dan Dashboard, supaya
  /// begitu satu avatar berubah, yang lain ikut berubah tanpa perlu
  /// me-reload halaman (keduanya hidup di dalam IndexedStack).
  static final ValueNotifier<String?> fotoProfil = ValueNotifier<String?>(null);

  static bool get siap => _siap;
  static bool get modeDemo => !_siap;
  static String? get errorInit => _errorInit;

  /// Dipanggil sekali dari main(). Mengembalikan pesan error atau null.
  static Future<String?> init() async {
    if (!SupabaseConfig.terkonfigurasi) {
      _errorInit =
          'URL/anon key Supabase belum diisi di '
          'lib/data/supabase_config.dart';
      return _errorInit;
    }
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        // `publishableKey` menerima key lama (`anon` JWT) maupun key baru
        // (`sb_publishable_...`) — di paket, keduanya jadi `effectiveKey`.
        publishableKey: SupabaseConfig.anonKey,
      );
      _siap = true;
      _errorInit = null;
      return null;
    } catch (e) {
      _errorInit = e.toString();
      return _errorInit;
    }
  }

  static SupabaseClient get _c => Supabase.instance.client;

  static Session? get sesi => _siap ? _c.auth.currentSession : null;
  static User? get user => _siap ? _c.auth.currentUser : null;
  static bool get sudahLogin => sesi != null;

  // ------------------------------------------------------------------ AUTH
  static Future<String?> masuk({
    required String email,
    required String password,
  }) async {
    if (!_siap) return 'Supabase belum terhubung.';
    try {
      final res = await _c.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.session == null) {
        return 'Email belum dikonfirmasi. Buka tautan verifikasi di kotak masuk.';
      }
      return null;
    } on AuthException catch (e) {
      return _pesanAuth(e);
    } catch (e) {
      return e.toString();
    }
  }

  static Future<void> keluar() async {
    if (_siap) await _c.auth.signOut();
    // Kosongkan supaya user berikutnya tidak melihat foto milik user sebelumnya.
    fotoProfil.value = null;
  }

  static String _pesanAuth(AuthException e) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'Email atau password salah.';
    }
    if (m.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek kotak masuk dulu.';
    }
    if (m.contains('too many') || m.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    }
    if (m.contains('failed to fetch') || m.contains('socket')) {
      return 'Tidak bisa menghubungi server. Periksa koneksi internet.';
    }
    return e.message;
  }

  // ---------------------------------------------------------------- QUERY
  static Future<ProfilDb?> profil() async {
    final uid = user?.id;
    if (!_siap || uid == null) return null;
    final row = await _c
        .from(SupabaseConfig.tProfil)
        .select()
        .eq('id', uid)
        .maybeSingle();
    return row == null ? null : ProfilDb.fromMap(row);
  }

  // ------------------------------------------------------- FOTO PROFIL
  /// Unggah foto profil ke Storage, lalu simpan URL-nya di `profiles.foto_url`.
  ///
  /// Satu berkas per user: `<uid>/avatar.<ext>`, dengan `upsert: true`
  /// sehingga unggahan berikutnya menimpa yang lama (tidak menumpuk sampah).
  /// Mengembalikan URL siap pakai untuk `Image.network`.
  static Future<String> unggahFotoProfil(
    Uint8List bytes, {
    String ekstensi = 'jpg',
  }) async {
    if (!_siap) throw StateError('Supabase belum terhubung.');
    final uid = user?.id;
    if (uid == null) throw StateError('Belum login.');

    final ext = ekstensi.toLowerCase();
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final path = '$uid/avatar.$ext';

    await _c.storage
        .from(SupabaseConfig.bucketFoto)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    // Penanda versi di URL supaya gambar lama tidak tertahan di cache
    // Image.network (URL berubah => dianggap gambar baru).
    final dasar = _c.storage.from(SupabaseConfig.bucketFoto).getPublicUrl(path);
    final url = '$dasar?v=${DateTime.now().millisecondsSinceEpoch}';

    await _c
        .from(SupabaseConfig.tProfil)
        .update({'foto_url': url})
        .eq('id', uid);

    debugLog('foto profil tersimpan: $path');
    fotoProfil.value = url;
    return url;
  }

  /// Hapus foto profil: kosongkan kolomnya dan buang berkas di Storage.
  /// Penghapusan berkas bersifat "best effort" — kalau berkasnya memang
  /// tidak ada (mis. dulu unggah PNG), kegagalan itu diabaikan.
  static Future<void> hapusFotoProfil() async {
    if (!_siap) throw StateError('Supabase belum terhubung.');
    final uid = user?.id;
    if (uid == null) throw StateError('Belum login.');

    await _c
        .from(SupabaseConfig.tProfil)
        .update({'foto_url': null})
        .eq('id', uid);

    for (final ext in const ['jpg', 'png', 'webp']) {
      try {
        await _c.storage.from(SupabaseConfig.bucketFoto).remove([
          '$uid/avatar.$ext',
        ]);
      } catch (_) {
        // berkas dengan ekstensi ini tidak ada — abaikan
      }
    }

    debugLog('foto profil dihapus');
    fotoProfil.value = null;
  }

  static Future<RingkasanAkademik?> ringkasan() async {
    if (!_siap || !sudahLogin) return null;
    final rows = await _c.from(SupabaseConfig.vRingkasan).select().limit(1);
    if (rows.isEmpty) return null;
    return RingkasanAkademik.fromMap(rows.first);
  }

  static Future<List<IpsPeriode>> daftarIps() async {
    if (!_siap || !sudahLogin) return const [];
    final rows = await _c
        .from(SupabaseConfig.vIps)
        .select()
        .order('periode_nama', ascending: true);
    return rows.map(IpsPeriode.fromMap).toList();
  }

  static Future<List<RekapPresensi>> daftarPresensi() async {
    if (!_siap || !sudahLogin) return const [];
    final rows = await _c
        .from(SupabaseConfig.vPresensi)
        .select()
        .order('mk_nama', ascending: true);
    return rows.map(RekapPresensi.fromMap).toList();
  }

  /// Seluruh kelas pada periode yang aktif, lengkap dengan nama mata kuliah
  /// dan dosen (PostgREST mengikuti foreign key di schema).
  static Future<List<KelasKuliahDb>> daftarKelasAktif() async {
    if (!_siap || !sudahLogin) return const [];
    final rows = await _c
        .from(SupabaseConfig.tKelas)
        .select(
          'kode_kelas, ruang, hari, jam_mulai, jam_selesai, link_materi, '
          'mata_kuliah(kode, nama, sks), dosen(nama)',
        )
        .eq('is_aktif', true)
        .order('hari', ascending: true)
        .order('jam_mulai', ascending: true);
    return rows.map(KelasKuliahDb.fromMap).toList();
  }

  /// Berapa banyak baris `profiles` yang bisa dilihat user ini.
  /// Harus 1 (cuma dirinya). Kalau lebih, policy RLS-nya bocor.
  static Future<int> hitungProfilTerlihat() async {
    if (!_siap || !sudahLogin) return 0;
    final rows = await _c.from(SupabaseConfig.tProfil).select('id');
    return rows.length;
  }

  /// Cek ringan: apakah user bisa menyentuh tabel sama sekali.
  static Future<void> cekKoneksi() async {
    if (!_siap) throw StateError('Supabase belum diinisialisasi');
    await _c.from(SupabaseConfig.tProfil).select('id').limit(1);
  }

  static void debugLog(String pesan) {
    if (kDebugMode) debugPrint('[supabase] $pesan');
  }
}
