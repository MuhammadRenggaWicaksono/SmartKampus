/// Konfigurasi koneksi Supabase.
///
/// CUKUP ISI DUA NILAI DI BAWAH, ambil dari:
///   Supabase Dashboard -> Project Settings -> API
///     * Project URL          -> tempel ke `url`
///     * anon / public key    -> tempel ke `anonKey`
///
/// JANGAN pernah menempel `service_role` key di sini. Key itu melewati semua
/// RLS dan kalau ikut ter-build ke APK, seluruh database bisa dibaca orang lain.
/// Yang dipakai aplikasi selalu `anon` / `public`.
///
/// Alternatif tanpa mengubah file (lebih rapi untuk repo publik):
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mfcyhscxwwadxcbyugxj.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_LnrNE0yFasEYLwBv_n8TPQ_vGIMjRKj',
  );

  /// true kalau dua nilai di atas sudah diisi.
  static bool get terkonfigurasi {
    final u = url.trim();
    final k = anonKey.trim();
    if (u.isEmpty || k.isEmpty) return false;
    if (u.contains('GANTI') || k.contains('GANTI')) return false;
    if (!u.startsWith('https://')) return false;
    return true;
  }

  /// Nama view/tabel dipakai di beberapa tempat, dikumpulkan di sini
  /// supaya kalau nanti di-rename, cuma satu tempat yang diubah.
  static const String vRingkasan = 'v_ringkasan_akademik';
  static const String vIps = 'v_ips_periode';
  static const String vIpk = 'v_ipk_mahasiswa';
  static const String vPresensi = 'v_rekap_presensi';
  static const String vPertemuan = 'v_progres_pertemuan';
  static const String tProfil = 'profiles';
  static const String tKelas = 'kelas_kuliah';
  static const String tPengumuman = 'pengumuman';
  static const String bucketFoto = 'foto-profil';
}
