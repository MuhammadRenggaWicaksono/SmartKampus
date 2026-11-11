-- ============================================================================
-- PENGUMUMAN — feed info kampus untuk dashboard
-- ============================================================================
--
-- PENTING, BACA DULU:
-- Tabel `public.pengumuman` SUDAH ADA di schema.sql (BAGIAN 7, baris ±530),
-- lengkap dengan index, RLS, dan dua policy (`pengumuman_baca`,
-- `pengumuman_tulis`). Jadi kamu TIDAK perlu mendesain tabel baru — file ini
-- hanya:
--   1. memastikan tabel + index + RLS-nya benar-benar ada di project Supabase,
--   2. merapikan kategori bawaan seed.sql ('seed' -> kategori yang bermakna),
--   3. mengisi 6 pengumuman contoh supaya dashboard tidak kosong.
--
-- URUTAN JALANKAN (SQL Editor Supabase):
--   schema.sql   (kalau belum pernah — ini yang bikin tabelnya)
--   seed.sql     (opsional, data akademik dummy)
--   pengumuman.sql  (file ini)  <- aman dijalankan berkali-kali
--
-- File ini idempoten: `create ... if not exists`, `drop policy if exists`
-- sebelum `create policy`, dan seed memakai `on conflict do nothing` di atas
-- unique index (judul, tanggal_mulai). Jalankan ulang tidak menggandakan data.
--
-- Butuh: fungsi public.is_admin() dan tabel public.profiles dari schema.sql.
-- ============================================================================


-- ---------------------------------------------------------------- 1. TABEL
-- Bentuknya sengaja SAMA PERSIS dengan schema.sql, supaya tidak ada dua versi
-- skema yang berbeda di repo. Kalau tabelnya sudah ada, blok ini dilewati.
create table if not exists public.pengumuman (
  id            uuid primary key default gen_random_uuid(),
  judul         text not null,
  isi           text not null,
  kategori      text not null default 'umum',
  url           text,
  tanggal_mulai date not null default current_date,
  tanggal_selesai date,
  is_penting    boolean not null default false,
  dibuat_oleh   uuid references public.profiles (id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index if not exists pengumuman_tanggal_idx
  on public.pengumuman (tanggal_mulai desc);

-- Kunci idempotensi seed di bawah. (judul, tanggal_mulai) dianggap identitas
-- satu pengumuman, jadi menjalankan file ini dua kali tidak bikin dobel.
create unique index if not exists pengumuman_judul_tgl_uidx
  on public.pengumuman (judul, tanggal_mulai);


-- ------------------------------------------------------- 2. HAK AKSES + RLS
-- RLS tetap yang menentukan siapa boleh apa; GRANT ini cuma memastikan role
-- `authenticated` memang punya izin menyentuh tabelnya sama sekali.
grant select on public.pengumuman to authenticated;
grant insert, update, delete on public.pengumuman to authenticated;

alter table public.pengumuman enable row level security;

-- Semua yang login boleh membaca semua pengumuman.
drop policy if exists pengumuman_baca on public.pengumuman;
create policy pengumuman_baca on public.pengumuman
  for select to authenticated using (true);

-- Hanya admin yang boleh menulis.
drop policy if exists pengumuman_tulis on public.pengumuman;
create policy pengumuman_tulis on public.pengumuman
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());


-- --------------------------------------------------- 3. TRIGGER updated_at
-- Dibuat hanya kalau fungsi public.set_updated_at() sudah ada (schema.sql).
do $$
begin
  if exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'set_updated_at'
  ) then
    drop trigger if exists set_updated_at on public.pengumuman;
    create trigger set_updated_at
      before update on public.pengumuman
      for each row execute function public.set_updated_at();
  else
    raise notice 'set_updated_at() belum ada — trigger dilewati (jalankan schema.sql dulu).';
  end if;
end $$;


-- -------------------------------------------- 4. RAPIIKAN KATEGORI BAWAAN
-- seed.sql memasukkan pengumuman dengan kategori literal 'seed' — itu penanda
-- internal, bukan kategori yang bisa ditampilkan. Petakan ke kategori nyata.
update public.pengumuman set kategori = 'akademik'
  where kategori = 'seed' and judul ilike '%ujian%';
update public.pengumuman set kategori = 'kemahasiswaan'
  where kategori = 'seed';


-- ------------------------------------------------------------ 5. SEED DATA
-- Kategori yang dipakai aplikasi: akademik, keuangan, kemahasiswaan, skripsi,
-- darurat, umum. (Kolom kategori tidak punya CHECK constraint di schema, jadi
-- nilai baru tetap masuk — aplikasi yang memetakan ke label.)
insert into public.pengumuman
  (judul, isi, kategori, url, tanggal_mulai, tanggal_selesai, is_penting)
values
  ('Batas Pembayaran UKT Semester Ganjil 2026/2027',
   'Pembayaran UKT gelombang akhir ditutup 20 November 2026. Mahasiswa yang belum melunasi tidak dapat mengikuti UAS dan KRS semester berikutnya terkunci otomatis oleh sistem.',
   'keuangan', null, date '2026-11-05', date '2026-11-20', true),

  ('Masa Perubahan KRS: 10 – 14 November 2026',
   'Perubahan KRS dibuka terbatas lima hari. Perubahan hanya bisa dilakukan untuk mata kuliah yang kelasnya masih memiliki sisa kuota, dan wajib disetujui dosen pembimbing akademik.',
   'akademik', null, date '2026-11-10', date '2026-11-14', true),

  ('Pendaftaran Beasiswa Prestasi Akademik 2026',
   'Pendaftaran dibuka sampai 30 November 2026. Syarat: IPK minimal 3.25, tidak sedang menerima beasiswa lain, dan melampirkan transkrip serta surat keterangan aktif kuliah.',
   'kemahasiswaan', null, date '2026-11-01', date '2026-11-30', false),

  ('Jadwal Ujian Akhir Semester Ganjil 2026/2027',
   'UAS dilaksanakan 5 – 16 Januari 2027. Jadwal per mata kuliah dan tata tertib ujian dapat dilihat di menu Perkuliahan > Jadwal Ujian.',
   'akademik', null, date '2026-11-09', date '2027-01-16', false),

  ('Pemeliharaan Jaringan Kampus — WiFi dan SIAKAD',
   'Pada Sabtu, 14 November 2026 pukul 22.00–04.00 WIB, jaringan kampus dan SIAKAD akan dimatikan untuk pemeliharaan rutin. Simpan pekerjaan sebelum jadwal tersebut.',
   'darurat', null, date '2026-11-12', date '2026-11-14', false),

  ('Pengumpulan Berkas Sidang Skripsi Periode Desember',
   'Berkas sidang (naskah, lembar persetujuan, dan bukti bebas plagiarisme) dikumpulkan paling lambat 27 November 2026 ke bagian akademik fakultas.',
   'skripsi', null, date '2026-11-03', date '2026-11-27', false)
on conflict (judul, tanggal_mulai) do nothing;


-- ------------------------------------------------------------ 6. VERIFIKASI
select judul, kategori, tanggal_mulai, tanggal_selesai, is_penting
from public.pengumuman
order by is_penting desc, tanggal_mulai desc;