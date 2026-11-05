-- ============================================================================
-- SmartKampus — Data Awal (seed)
-- ----------------------------------------------------------------------------
-- BAGIAN 2 dari 2. Jalankan schema.sql DULU, baru file ini.
-- Aman dijalankan berulang (semua pakai on conflict do nothing).
--
-- Isinya disusun supaya cocok dengan data dummy yang sekarang ada di aplikasi
-- (lib/data/app_data.dart & lib/data/skripsi_store.dart):
--   5 periode akademik, 8 dosen, 42 mata kuliah, 8 kelas semester aktif,
--   6 tahapan skripsi, KRS 5 semester, presensi 16 pertemuan, 4 tagihan lunas.
--
-- PENTING — baca sebelum menjalankan bagian 12:
--   Seed mahasiswa butuh user auth yang sudah ada. Buat dulu di
--   Supabase Dashboard -> Authentication -> Users -> Add user
--   (email + password), lalu jalankan perintah di BAGIAN 12 berikut ini.
-- ============================================================================


-- ============================================================================
-- BAGIAN 1 — PROGRAM STUDI
-- ============================================================================

insert into public.program_studi (kode, nama, fakultas, jenjang)
values
  ('IF', 'S1 Informatika', 'Fakultas Ilmu Komputer', 'S1'),
  ('SI', 'S1 Sistem Informasi', 'Fakultas Ilmu Komputer', 'S1')
on conflict (kode) do update
  set nama = excluded.nama,
      fakultas = excluded.fakultas,
      jenjang = excluded.jenjang;


-- ============================================================================
-- BAGIAN 2 — PERIODE AKADEMIK
-- ============================================================================

-- Pastikan tidak ada dua periode aktif (ada unique partial index untuk ini).
update public.periode_akademik set is_aktif = false where is_aktif;

insert into public.periode_akademik (
  kode, nama, tahun_akademik, jenis, tanggal_mulai, tanggal_selesai,
  krs_dibuka, krs_ditutup, ukt_jatuh_tempo, is_aktif
)
values
  ('2024/2025-GANJIL', 'Semester Ganjil 2024/2025', '2024/2025', 'ganjil',
   date '2024-09-02', date '2025-01-31', date '2024-08-19', date '2024-09-06',
   date '2024-09-20', false),
  ('2024/2025-GENAP', 'Semester Genap 2024/2025', '2024/2025', 'genap',
   date '2025-02-10', date '2025-06-30', date '2025-01-27', date '2025-02-14',
   date '2025-02-28', false),
  ('2025/2026-GANJIL', 'Semester Ganjil 2025/2026', '2025/2026', 'ganjil',
   date '2025-09-01', date '2026-01-30', date '2025-08-18', date '2025-09-05',
   date '2025-09-19', false),
  ('2025/2026-GENAP', 'Semester Genap 2025/2026', '2025/2026', 'genap',
   date '2026-02-09', date '2026-06-26', date '2026-01-26', date '2026-02-13',
   date '2026-02-27', false),
  ('2026/2027-GANJIL', 'Semester Ganjil 2026/2027', '2026/2027', 'ganjil',
   date '2026-09-07', date '2027-01-29', date '2026-08-24', date '2026-09-11',
   date '2026-09-25', true)
on conflict (kode) do update
  set nama = excluded.nama,
      tahun_akademik = excluded.tahun_akademik,
      jenis = excluded.jenis,
      tanggal_mulai = excluded.tanggal_mulai,
      tanggal_selesai = excluded.tanggal_selesai,
      krs_dibuka = excluded.krs_dibuka,
      krs_ditutup = excluded.krs_ditutup,
      ukt_jatuh_tempo = excluded.ukt_jatuh_tempo,
      is_aktif = excluded.is_aktif;


-- ============================================================================
-- BAGIAN 3 — DOSEN
-- ============================================================================

insert into public.dosen (nidn, nama, gelar_belakang, email)
values
  ('1001', 'NASRUDDIN BIN IDRIS', 'S.Kom., M.Kom.', 'nasruddin@kampus.ac.id'),
  ('1002', 'HERUZULKIFLI ROWA', 'S.Kom, M.Kom', 'heruzulkifli@kampus.ac.id'),
  ('1003', 'ISTIA BUDI', 'S.T., M.M.', 'istia@kampus.ac.id'),
  ('1004', 'ISA ROSITA', 'S.Kom., M.Cs.', 'isa@kampus.ac.id'),
  ('1005', 'MUHAMMAD SAFI''I', 'S.Kom., M.Kom.', 'safii@kampus.ac.id'),
  ('1006', 'WISNU HERA PAMUNGKAS', 'S.T.P., M.Eng', 'wisnu@kampus.ac.id'),
  ('1007', 'PRAMUDYA PRIMA INSAN', 'S.Kom., M.Kom.', 'pramudya@kampus.ac.id'),
  ('1008', 'YUSUF WIBISONO', 'S.E., M.T.I.', 'yusuf@kampus.ac.id')
on conflict (nidn) do update
  set nama = excluded.nama,
      gelar_belakang = excluded.gelar_belakang,
      email = excluded.email;


-- ============================================================================
-- BAGIAN 4 — MATA KULIAH (42 mata kuliah, semester 1-5)
-- ============================================================================

insert into public.mata_kuliah (kode, nama, sks, semester_ke, program_studi_id, is_praktikum)
select v.kode, v.nama, v.sks, v.semester_ke,
       (select id from public.program_studi where kode = 'IF'),
       v.sks >= 3 and v.nama ilike any (array['%PEMROGRAMAN%', '%PRAKTIKUM%', '%BASIS DATA%'])
from (values
  -- semester 1
  ('110100', 'ALGORITMA DAN PEMROGRAMAN', 3, 1),
  ('000100', 'BAHASA INDONESIA', 2, 1),
  ('110300', 'BAHASA INGGRIS', 3, 1),
  ('110401', 'ETIKA PROFESI', 2, 1),
  ('110501', 'INTERAKSI MANUSIA DAN KOMPUTER', 3, 1),
  ('110800', 'LOGIKA INFORMATIKA', 3, 1),
  ('110900', 'MATEMATIKA I', 2, 1),
  ('000400', 'PANCASILA', 2, 1),
  ('001000', 'TEKNOLOGI INFORMASI', 3, 1),
  -- semester 2
  ('111700', 'ALJABAR LINIER DAN MATRIKS', 2, 2),
  ('112400', 'KOMUNIKASI DATA', 3, 2),
  ('112600', 'MATEMATIKA II', 2, 2),
  ('113100', 'PEMROGRAMAN JAVA', 3, 2),
  ('113200', 'PEMROGRAMAN VISUAL', 3, 2),
  ('000700', 'PENDIDIKAN KEWARGANEGARAAN', 2, 2),
  ('113400', 'PERANGKAT KERAS KOMPUTER', 3, 2),
  ('113700', 'SISTEM DIGITAL', 3, 2),
  ('114100', 'STRUKTUR DATA', 3, 2),
  -- semester 3
  ('110200', 'ANALISIS DESAIN BERORIENTASI OBJEK', 3, 3),
  ('010100', 'JARINGAN KOMPUTER', 3, 3),
  ('010500', 'PEMROGRAMAN WEB', 3, 3),
  ('000500', 'PENDIDIKAN AGAMA', 2, 3),
  ('000600', 'PENDIDIKAN ANTI KORUPSI', 2, 3),
  ('010600', 'SISTEM BASIS DATA', 3, 3),
  ('010700', 'SISTEM OPERASI', 3, 3),
  ('001200', 'WIRAUSAHA BERBASIS TEKNOLOGI', 4, 3),
  -- semester 4
  ('111800', 'ARSITEKTUR DAN ORGANISASI KOMPUTER', 3, 4),
  ('000200', 'BAHASA INGGRIS BISNIS', 3, 4),
  ('111900', 'GRAFIKA KOMPUTER', 3, 4),
  ('112000', 'INTERNET OF THINGS', 3, 4),
  ('112200', 'KECERDASAN BUATAN', 3, 4),
  ('112700', 'METODE NUMERIK', 2, 4),
  ('010400', 'METODOLOGI PENELITIAN', 3, 4),
  ('113600', 'REKAYASA PERANGKAT LUNAK', 3, 4),
  -- semester 5 (semester aktif)
  ('110600', 'JARINGAN NIRKABEL', 3, 5),
  ('111000', 'PEMROGRAMAN APLIKASI BERGERAK', 3, 5),
  ('111100', 'PENALARAN KOMPUTER', 3, 5),
  ('000800', 'PENULISAN DAN PUBLIKASI ILMIAH', 2, 5),
  ('111300', 'ROBOTIKA', 3, 5),
  ('111400', 'SIMULASI DAN GAME KOMPUTER', 3, 5),
  ('111500', 'SISTEM MANAJEMEN BASIS DATA', 3, 5),
  ('111600', 'TEKNOLOGI APLIKASI BERGERAK', 3, 5)
) as v(kode, nama, sks, semester_ke)
on conflict (kode) do update
  set nama = excluded.nama,
      sks = excluded.sks,
      semester_ke = excluded.semester_ke;


-- ============================================================================
-- BAGIAN 5 — KELAS KULIAH
-- ============================================================================

-- 5a. Periode 1-4: hanya kode kelas (jadwal & dosen belum diisi).
insert into public.kelas_kuliah (mata_kuliah_id, periode_id, kode_kelas, is_aktif)
select mk.id, pa.id, v.kode_kelas, false
from (values
  ('2024/2025-GANJIL', '110100', 'IFB1B'), ('2024/2025-GANJIL', '000100', 'IFB1B'),
  ('2024/2025-GANJIL', '110300', 'IFB1B'), ('2024/2025-GANJIL', '110401', 'IFB1B'),
  ('2024/2025-GANJIL', '110501', 'IFB1B'), ('2024/2025-GANJIL', '110800', 'IFB1B'),
  ('2024/2025-GANJIL', '110900', 'IFB1B'), ('2024/2025-GANJIL', '000400', 'IFB1B'),
  ('2024/2025-GANJIL', '001000', 'IFB1B'),
  ('2024/2025-GENAP', '111700', 'IFB2B'), ('2024/2025-GENAP', '112400', 'IFB2B'),
  ('2024/2025-GENAP', '112600', 'IFB2B'), ('2024/2025-GENAP', '113100', 'IFB2B'),
  ('2024/2025-GENAP', '113200', 'IFB2B'), ('2024/2025-GENAP', '000700', 'IFB2A'),
  ('2024/2025-GENAP', '113400', 'IFB2B'), ('2024/2025-GENAP', '113700', 'IFB2B'),
  ('2024/2025-GENAP', '114100', 'IFB2B'),
  ('2025/2026-GANJIL', '110200', 'IFB3J'), ('2025/2026-GANJIL', '010100', 'IFB3J'),
  ('2025/2026-GANJIL', '010500', 'IFB3J'), ('2025/2026-GANJIL', '000500', 'IFB3J'),
  ('2025/2026-GANJIL', '000600', 'IFB3J'), ('2025/2026-GANJIL', '010600', 'IFB3J'),
  ('2025/2026-GANJIL', '010700', 'IFB3J'), ('2025/2026-GANJIL', '001200', 'IFB3J'),
  ('2025/2026-GENAP', '111800', 'IFB4B'), ('2025/2026-GENAP', '000200', 'IFB4B'),
  ('2025/2026-GENAP', '111900', 'IFB4B'), ('2025/2026-GENAP', '112000', 'IFB4B'),
  ('2025/2026-GENAP', '112200', 'IFB4B'), ('2025/2026-GENAP', '112700', 'IFB4B'),
  ('2025/2026-GENAP', '010400', 'IFB4B'), ('2025/2026-GENAP', '113600', 'IFB4B')
) as v(periode_kode, mk_kode, kode_kelas)
join public.mata_kuliah mk on mk.kode = v.mk_kode
join public.periode_akademik pa on pa.kode = v.periode_kode
on conflict (mata_kuliah_id, periode_id, kode_kelas) do nothing;

-- 5b. Periode aktif: lengkap dengan dosen, ruang, dan jadwal mingguan.
insert into public.kelas_kuliah (
  mata_kuliah_id, periode_id, dosen_id, kode_kelas, ruang,
  hari, jam_mulai, jam_selesai, link_materi, is_aktif
)
select
  mk.id,
  pa.id,
  d.id,
  v.kode_kelas,
  v.ruang,
  v.hari::smallint,
  v.jam_mulai::time,
  v.jam_selesai::time,
  v.link_materi,
  true
from (values
  ('111500', 'NASRUDDIN BIN IDRIS',      'IFB5A', 'LAB D (FIKOM)',      1, '08:00', '10:30', 'https://kuliah.kampus.ac.id/111500'),
  ('111400', 'HERUZULKIFLI ROWA',        'IFB5A', 'LAB A (FIKOM)',      1, '10:30', '13:00', null),
  ('111600', 'ISTIA BUDI',               'IFB5A', 'LAB B (FIKOM)',      1, '13:00', '15:30', null),
  ('111100', 'ISA ROSITA',               'IFB5A', 'A201',               2, '13:00', '15:30', null),
  ('111300', 'MUHAMMAD SAFI''I',         'IFB5J', 'LAB ROBOTIK (FIKOM)',3, '19:00', '20:30', null),
  ('110600', 'WISNU HERA PAMUNGKAS',     'IFB5A', 'LAB JARINGAN (FIKOM)',4, '08:00', '10:30', null),
  ('111000', 'PRAMUDYA PRIMA INSAN',     'IFB5A', 'LAB A (FIKOM)',      4, '13:00', '15:30', null),
  ('000800', 'YUSUF WIBISONO',           'IFB5A', 'A202',               5, '08:00', '09:40', 'https://kuliah.kampus.ac.id/000800')
) as v(mk_kode, dosen_nama, kode_kelas, ruang, hari, jam_mulai, jam_selesai, link_materi)
join public.mata_kuliah mk on mk.kode = v.mk_kode
join public.periode_akademik pa on pa.kode = '2026/2027-GANJIL'
left join public.dosen d on d.nama = v.dosen_nama
on conflict (mata_kuliah_id, periode_id, kode_kelas) do update
  set dosen_id = excluded.dosen_id,
      ruang = excluded.ruang,
      hari = excluded.hari,
      jam_mulai = excluded.jam_mulai,
      jam_selesai = excluded.jam_selesai,
      link_materi = excluded.link_materi,
      is_aktif = true;


-- ============================================================================
-- BAGIAN 6 — KALENDER AKADEMIK
-- ============================================================================

delete from public.kalender_akademik where periode_id in (
  select id from public.periode_akademik where kode = '2026/2027-GANJIL'
);

insert into public.kalender_akademik (periode_id, nama_kegiatan, deskripsi, tanggal_mulai, tanggal_selesai, is_penting)
select pa.id, v.nama, v.deskripsi, v.mulai, v.selesai, v.penting
from (values
  ('Pengisian KRS', 'Pengisian KRS semester ganjil', date '2026-08-24', date '2026-09-11', true),
  ('Awal Perkuliahan', 'Kuliah perdana semester ganjil', date '2026-09-07', null, false),
  ('Ujian Tengah Semester', 'UTS seluruh mata kuliah', date '2026-10-26', date '2026-11-06', true),
  ('Batas Pembayaran UKT', 'Batas akhir pembayaran UKT semester ganjil', date '2026-09-25', null, true),
  ('Ujian Akhir Semester', 'UAS seluruh mata kuliah', date '2027-01-11', date '2027-01-22', true),
  ('Pengumuman Nilai', 'Nilai dirilis di portal akademik', date '2027-01-29', null, false)
) as v(nama, deskripsi, mulai, selesai, penting)
cross join public.periode_akademik pa
where pa.kode = '2026/2027-GANJIL';


-- ============================================================================
-- BAGIAN 7 — TAHAPAN SKRIPSI
-- ============================================================================

insert into public.tahapan_skripsi (urutan, nama, keterangan)
values
  (1, 'Pengajuan Judul', 'Ajukan judul beserta link berkas pendukung'),
  (2, 'Verifikasi & ACC Judul', 'Judul diverifikasi oleh Program Studi'),
  (3, 'Penetapan Pembimbing', 'Dosen pembimbing 1 dan 2 ditetapkan'),
  (4, 'Bimbingan & Proposal', 'Minimal 8 kali bimbingan tercatat'),
  (5, 'Seminar Proposal', 'Presentasi proposal di depan penguji'),
  (6, 'Sidang Skripsi', 'Ujian akhir dan revisi naskah')
on conflict (urutan) do update
  set nama = excluded.nama,
      keterangan = excluded.keterangan;


-- ============================================================================
-- BAGIAN 8 — PENGUMUMAN
-- ============================================================================

delete from public.pengumuman where kategori = 'seed';

insert into public.pengumuman (judul, isi, kategori, tanggal_mulai, is_penting)
values
  ('Jadwal Ujian Tengah Semester Ganjil 2026/2027',
   'UTS dilaksanakan 26 Oktober - 6 November 2026. Cek jadwal per mata kuliah di menu Perkuliahan > Jadwal Ujian.',
   'seed', date '2026-10-20', true),
  ('Pendaftaran Beasiswa Prestasi Akademik',
   'Pendaftaran dibuka sampai 30 November 2026. Syarat: IPK minimal 3.25 dan tidak sedang menerima beasiswa lain.',
   'seed', date '2026-11-01', false);


-- ============================================================================
-- BAGIAN 9 — FUNGSI PENDAFTARAN MAHASISWA
-- ============================================================================

create or replace function public.daftarkan_mahasiswa(
  p_email     text,
  p_nim       text,
  p_nama      text,
  p_panggilan text default 'Mahasiswa'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  select u.id into v_id from auth.users u where u.email = p_email;

  if v_id is null then
    raise notice 'User % belum ada. Buat dulu di Authentication > Users.', p_email;
    return null;
  end if;

  insert into public.profiles (
    id, email, nim, nama, nama_panggilan, program_studi_id,
    angkatan, semester_ke, role, status
  )
  values (
    v_id, p_email, p_nim, p_nama, p_panggilan,
    (select id from public.program_studi where kode = 'IF'),
    2024, 5, 'mahasiswa', 'aktif'
  )
  on conflict (id) do update
    set nim = excluded.nim,
        nama = excluded.nama,
        nama_panggilan = excluded.nama_panggilan,
        semester_ke = excluded.semester_ke;

  return v_id;
end;
$$;

-- Fungsi ini hanya untuk dipakai dari SQL Editor, bukan dari aplikasi.
revoke all on function public.daftarkan_mahasiswa(text, text, text, text)
  from public, anon, authenticated;


-- ============================================================================
-- BAGIAN 10 — JALANKAN SEKALI SAJA
-- ============================================================================
-- 1) Buat user di Authentication -> Users (email + password), misal
--    rengga@kampus.ac.id
-- 2) Jalankan baris di bawah (ganti email & nama sesuai kebutuhan).
--    Kalau user dibuat dari Dashboard tanpa metadata, trigger
--    handle_new_user tidak punya nim/nama, jadi fungsi ini yang mengisinya.
-- ----------------------------------------------------------------------------

select public.daftarkan_mahasiswa(
  'rengga@kampus.ac.id',
  '2411044',
  'Muhammad Rengga Wicaksono',
  'Rengga'
) as mahasiswa_id;


-- ============================================================================
-- BAGIAN 11 — BIODATA KELUARGA & KRS
-- ============================================================================
-- Data di bawah hanya terisi kalau profil NIM 2411044 sudah ada.
-- Kalau profil belum ada, perintah ini menghasilkan 0 baris (bukan error).

insert into public.biodata_keluarga (
  mahasiswa_id, nama_ayah, pekerjaan_ayah, nama_ibu, pekerjaan_ibu,
  penghasilan_ortu, no_hp_ortu, alamat_ortu
)
select p.id, 'Bapak Wicaksono', 'Karyawan Swasta', 'Ibu Wicaksono', 'Ibu Rumah Tangga',
       'Rp 5.000.000 - Rp 10.000.000', '081234567890', 'Surabaya, Jawa Timur'
from public.profiles p
where p.nim = '2411044'
on conflict (mahasiswa_id) do nothing;

-- KRS semester lampau: sudah disetujui.
insert into public.krs (mahasiswa_id, periode_id, status, tanggal_pengajuan, tanggal_verifikasi)
select p.id, pa.id, 'disetujui', pa.tanggal_mulai, pa.tanggal_mulai + 7
from public.profiles p
cross join public.periode_akademik pa
where p.nim = '2411044'
  and pa.kode <> '2026/2027-GANJIL'
on conflict (mahasiswa_id, periode_id) do nothing;

-- KRS semester berjalan: masih menunggu verifikasi dosen PA.
insert into public.krs (mahasiswa_id, periode_id, status, tanggal_pengajuan, catatan)
select p.id, pa.id, 'diajukan', now() - interval '3 days', 'Menunggu verifikasi dosen PA'
from public.profiles p
cross join public.periode_akademik pa
where p.nim = '2411044' and pa.kode = '2026/2027-GANJIL'
on conflict (mahasiswa_id, periode_id) do nothing;

-- Isi detail: seluruh kelas pada periode tersebut masuk ke KRS periode itu.
insert into public.krs_detail (krs_id, kelas_id)
select k.id, kk.id
from public.krs k
join public.profiles p on p.id = k.mahasiswa_id
join public.kelas_kuliah kk on kk.periode_id = k.periode_id
where p.nim = '2411044'
on conflict (krs_id, kelas_id) do nothing;

-- Trigger krs_detail_hitung_sks sudah menjaga kolom sks_diambil.


-- ============================================================================
-- BAGIAN 12 — NILAI
-- ============================================================================

-- 12a. Semester 1 (2024/2025 Ganjil) — ini data ASLI dari KHS di aplikasi.
insert into public.nilai (mahasiswa_id, kelas_id, nilai_huruf)
select p.id, kk.id, v.nilai
from (values
  ('110100', 'A'), ('000100', 'A-'), ('110300', 'B'), ('110401', 'A'),
  ('110501', 'A'), ('110800', 'A-'), ('110900', 'B'), ('000400', 'B+'),
  ('001000', 'A')
) as v(mk_kode, nilai)
join public.mata_kuliah mk on mk.kode = v.mk_kode
join public.periode_akademik pa on pa.kode = '2024/2025-GANJIL'
join public.kelas_kuliah kk on kk.mata_kuliah_id = mk.id and kk.periode_id = pa.id
join public.profiles p on p.nim = '2411044'
on conflict (mahasiswa_id, kelas_id) do nothing;

-- 12b. Semester 2-4 — CONTOH HASIL BANGKITAN, BUKAN data asli.
--      Dibuat supaya grafik IPS 1-8 ada isinya. Ganti dengan nilai asli
--      dari BAAK sebelum dipakai serius.
insert into public.nilai (mahasiswa_id, kelas_id, nilai_huruf)
select
  p.id,
  kk.id,
  case (length(mk.nama) % 3)
    when 0 then 'A'
    when 1 then 'A-'
    else 'B+'
  end
from public.profiles p
join public.kelas_kuliah kk on true
join public.periode_akademik pa on pa.id = kk.periode_id
  and pa.kode in ('2024/2025-GENAP', '2025/2026-GANJIL', '2025/2026-GENAP')
join public.mata_kuliah mk on mk.id = kk.mata_kuliah_id
where p.nim = '2411044'
on conflict (mahasiswa_id, kelas_id) do nothing;


-- ============================================================================
-- BAGIAN 13 — PERTEMUAN & PRESENSI SEMESTER AKTIF
-- ============================================================================

-- 13a. Rencana 16 pertemuan untuk setiap kelas semester aktif.
insert into public.pertemuan_kuliah (kelas_id, pertemuan_ke, tanggal, is_terlaksana)
select
  kk.id,
  g.pertemuan_ke,
  pa.tanggal_mulai + ((g.pertemuan_ke - 1) * 7),
  g.pertemuan_ke <= coalesce(t.jumlah, 0)
from public.kelas_kuliah kk
join public.periode_akademik pa on pa.id = kk.periode_id and pa.is_aktif
join public.mata_kuliah mk on mk.id = kk.mata_kuliah_id
left join (values
  ('110600', 10), ('111000', 10), ('111100', 9), ('000800', 9),
  ('111300', 8),  ('111400', 9),  ('111500', 10), ('111600', 10)
) as t(mk_kode, jumlah) on t.mk_kode = mk.kode
cross join generate_series(1, 16) as g(pertemuan_ke)
on conflict (kelas_id, pertemuan_ke) do update
  set tanggal = excluded.tanggal,
      is_terlaksana = excluded.is_terlaksana;

-- 13b. Presensi: default 'hadir', lalu ditimpa oleh daftar pengecualian.
with mhs as (
  select id from public.profiles where nim = '2411044'
),
terlaksana(mk_kode, jumlah) as (values
  ('110600', 10), ('111000', 10), ('111100', 9), ('000800', 9),
  ('111300', 8),  ('111400', 9),  ('111500', 10), ('111600', 10)
),
pengecualian(mk_kode, pertemuan_ke, status, keterangan) as (values
  ('111500', 10, 'sakit', 'Surat keterangan sakit'),
  ('111400',  9, 'izin',  'Izin lomba antar kampus'),
  ('111100',  8, 'izin',  'Izin keperluan keluarga'),
  ('111100',  9, 'alpa',  null),
  ('110600', 10, 'sakit', 'Demam'),
  ('000800',  9, 'izin',  'Izin kegiatan himpunan')
)
insert into public.presensi (mahasiswa_id, kelas_id, pertemuan_ke, status, keterangan)
select
  m.id,
  kk.id,
  g.pertemuan_ke,
  coalesce(x.status, 'hadir'),
  x.keterangan
from mhs m
cross join public.kelas_kuliah kk
join public.periode_akademik pa on pa.id = kk.periode_id and pa.is_aktif
join public.mata_kuliah mk on mk.id = kk.mata_kuliah_id
join terlaksana t on t.mk_kode = mk.kode
cross join generate_series(1, t.jumlah) as g(pertemuan_ke)
left join pengecualian x
  on x.mk_kode = mk.kode and x.pertemuan_ke = g.pertemuan_ke
on conflict (mahasiswa_id, kelas_id, pertemuan_ke) do nothing;


-- ============================================================================
-- BAGIAN 14 — KEUANGAN
-- ============================================================================

insert into public.tagihan (
  mahasiswa_id, periode_id, jenis, keterangan, nominal,
  tanggal_terbit, jatuh_tempo, status, va_number, bank
)
select p.id, pa.id, v.jenis, v.keterangan, v.nominal, v.terbit, v.tempo,
       'lunas', '800123456789', 'BNI'
from (values
  ('2024/2025-GANJIL', 'ukt',        'UKT S1 IF Pagi Gel II', 9000000, date '2024-09-06', date '2024-09-06'),
  ('2024/2025-GENAP',  'ukt',        'UKT S1 IF Pagi Gel II', 8500000, date '2025-02-10', date '2025-02-10'),
  ('2025/2026-GANJIL', 'praktikum',  'Biaya Praktikum Lab',    500000, date '2025-08-20', date '2025-08-20'),
  ('2025/2026-GANJIL', 'denda',      'Denda Keterlambatan KRS', 100000, date '2025-09-15', date '2025-09-15')
) as v(periode_kode, jenis, keterangan, nominal, terbit, tempo)
join public.periode_akademik pa on pa.kode = v.periode_kode
cross join public.profiles p
where p.nim = '2411044'
  and not exists (
    select 1 from public.tagihan t
    where t.mahasiswa_id = p.id and t.keterangan = v.keterangan
      and t.nominal = v.nominal
  );

-- Lunasi semua tagihan di atas (sekali saja, tidak dobel saat dijalankan ulang).
insert into public.pembayaran (tagihan_id, nominal, tanggal, metode, referensi)
select
  t.id,
  t.nominal,
  t.tanggal_terbit + 2,
  'va',
  'TRX' || to_char(t.tanggal_terbit, 'YYYYMMDD') || left(t.id::text, 4)
from public.tagihan t
join public.profiles p on p.id = t.mahasiswa_id and p.nim = '2411044'
where not exists (
  select 1 from public.pembayaran b where b.tagihan_id = t.id
);


-- ============================================================================
-- BAGIAN 15 — SKRIPSI
-- ============================================================================

insert into public.skripsi (mahasiswa_id, periode_id, judul, tahapan_aktif, status, tanggal_mulai)
select p.id, pa.id, null, 1, 'berjalan', date '2026-10-28'
from public.profiles p
cross join public.periode_akademik pa
where p.nim = '2411044' and pa.kode = '2026/2027-GANJIL'
on conflict (mahasiswa_id) do nothing;

insert into public.skripsi_pengajuan (
  mahasiswa_id, judul, berkas_1, berkas_2, berkas_3, status, catatan, tanggal_diajukan
)
select
  p.id,
  'Penerapan Algoritma YOLOv8 untuk Deteksi Penggunaan Alat Pelindung Diri pada Laboratorium Fakultas Ilmu Komputer',
  'https://drive.google.com/file/d/1a2b3c4d5e6f7g8h/view',
  'https://drive.google.com/file/d/9i8h7g6f5e4d3c2b/view',
  '-',
  'menunggu',
  'Menunggu verifikasi judul oleh Program Studi.',
  timestamptz '2026-10-28 09:15:00+07'
from public.profiles p
where p.nim = '2411044'
  and not exists (
    select 1 from public.skripsi_pengajuan s where s.mahasiswa_id = p.id
  );

-- Progres tahapan: tahap 1 berjalan, sisanya belum.
insert into public.skripsi_progres (mahasiswa_id, tahapan_id, status)
select p.id, t.id, case when t.urutan = 1 then 'berjalan' else 'belum' end
from public.profiles p
cross join public.tahapan_skripsi t
where p.nim = '2411044'
on conflict (mahasiswa_id, tahapan_id) do nothing;

-- Pembimbing sengaja TIDAK diisi: di aplikasi statusnya "Belum ditetapkan".
-- Isi manual setelah judul di-ACC, contoh:
--   insert into public.skripsi_pembimbing (mahasiswa_id, dosen_id, peran)
--   select p.id, d.id, 1 from public.profiles p, public.dosen d
--   where p.nim = '2411044' and d.nama = 'NASRUDDIN BIN IDRIS';


-- ============================================================================
-- BAGIAN 16 — PEMERIKSAAN HASIL
-- ============================================================================
-- Angka yang SEHARUSNYA keluar setelah seed ini jalan:
--
--   view                        nilai
--   --------------------------  ------------------------------------------
--   v_ips_periode  sem 1        SKS 23, mutu 84.25, IPS 3.66  (data asli)
--   v_ips_periode  sem 2        SKS 24, mutu 88.75, IPS 3.70  (contoh)
--   v_ips_periode  sem 3        SKS 23, mutu 81.50, IPS 3.54  (contoh)
--   v_ips_periode  sem 4        SKS 23, mutu 86.75, IPS 3.77  (contoh)
--   v_ipk_mahasiswa             SKS 93, IPK 3.67
--   v_rekap_presensi            total hadir 69, sakit 2, izin 3, alpa 1
--   v_progres_pertemuan         8 kelas, terlaksana 8-10 dari 16
--   v_ringkasan_akademik        sks_semester_ini 23, jumlah_mk_aktif 8,
--                               sisa_tagihan 0
--
-- CATATAN PENTING: aplikasi menulis IPK 3.68 dan IPS sem 1 = 3.68, padahal
-- nilai huruf semester 1 yang ditampilkan di layar KHS-nya sendiri
-- (A, A-, B, A, A, A-, B, B+, A x 23 SKS) menghasilkan 84.25 / 23 = 3.66.
-- Jadi angka 3.68 di aplikasi itu diketik tangan dan meleset 0.02.
-- Di database ini angkanya dihitung, jadi yang keluar 3.66 — itu yang benar.

-- Ringkasan satu baris (IPK, SKS, mk aktif, sisa tagihan)
select * from public.v_ringkasan_akademik;

-- IPS per semester
select periode_nama, sks_diambil, total_mutu, ips
from public.v_ips_periode
order by periode_nama;

-- Rekap presensi per mata kuliah semester aktif
select mk_nama, hadir, sakit, izin, alpa, pertemuan_terlaksana,
       pertemuan_rencana, persen_hadir, persen_dari_rencana
from public.v_rekap_presensi
order by mk_nama;

-- Progres realisasi pertemuan per kelas
select mk_nama, terlaksana, rencana, persen
from public.v_progres_pertemuan
order by mk_nama;
