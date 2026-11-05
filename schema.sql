-- ============================================================================
-- SmartKampus — Skema Database Supabase (PostgreSQL)
-- ----------------------------------------------------------------------------
-- File ini adalah BAGIAN 1 dari 2.
--   1. schema.sql  (file ini)  -> tabel, view, fungsi, RLS, trigger
--   2. seed.sql                -> data awal (master + contoh transaksional)
--
-- Urutan menjalankan: schema.sql DULU, baru seed.sql.
-- Kedua file aman dijalankan berulang (idempotent).
--
-- Cara jalan: Supabase Dashboard -> SQL Editor -> New query -> tempel -> Run.
--
-- Konvensi:
--   * Semua primary key uuid (gen_random_uuid(), bawaan PostgreSQL 13+).
--   * Nama tabel & kolom: huruf kecil, snake_case, bahasa Indonesia.
--   * IPS/IPK TIDAK disimpan, tapi dihitung di view supaya tidak pernah
--     beda dengan nilai aslinya.
--   * Semua tabel pakai Row Level Security (RLS).
-- ============================================================================


-- ============================================================================
-- BAGIAN 1 — FUNGSI BANTU
-- ============================================================================

-- Menjaga kolom updated_at tetap akurat.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Konversi nilai huruf -> bobot mutu (skala 4.00).
-- Dipakai bersama oleh view IPS/IPK, jadi ubah di sini kalau skala kampus beda.
create or replace function public.bobot_mutu(p_huruf text)
returns numeric
language sql
immutable
as $$
  select case upper(trim(coalesce(p_huruf, '')))
    when 'A'  then 4.00
    when 'A-' then 3.75
    when 'B+' then 3.25
    when 'B'  then 3.00
    when 'B-' then 2.75
    when 'C+' then 2.25
    when 'C'  then 2.00
    when 'C-' then 1.75
    when 'D'  then 1.00
    when 'E'  then 0.00
    else null
  end::numeric(3,2);
$$;

-- Role user yang sedang login ('mahasiswa' | 'dosen' | 'admin').
-- CATATAN: fungsi current_role/is_staff/is_admin TIDAK boleh di sini.
-- Fungsi ber-bahasa `sql` dicek isinya saat CREATE, jadi kalau tabel
-- `profiles` belum ada, CREATE-nya gagal ("relation public.profiles does not
-- exist"). Ketiganya diletakkan di BAGIAN 3B setelah tabel profiles dibuat.

-- Otomatis membuat baris profiles saat user baru mendaftar lewat Supabase Auth.
-- Metadata diambil dari raw_user_meta_data, contoh saat signUp:
--   supabase.auth.signUp(email: ..., data: {'nim': '2411044', 'nama': '...'})
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, nim, nama, nama_panggilan)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'nim', new.email),
    coalesce(new.raw_user_meta_data ->> 'nama', new.email),
    coalesce(new.raw_user_meta_data ->> 'nama_panggilan', 'Mahasiswa')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;


-- ============================================================================
-- BAGIAN 2 — TABEL MASTER
-- ============================================================================

create table if not exists public.program_studi (
  id         uuid primary key default gen_random_uuid(),
  kode       text not null unique,
  nama       text not null,
  fakultas   text not null,
  jenjang    text not null default 'S1',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.periode_akademik (
  id                  uuid primary key default gen_random_uuid(),
  kode                text not null unique,          -- '2026/2027-GANJIL'
  nama                text not null,                 -- 'Semester Ganjil 2026/2027'
  tahun_akademik      text not null,                 -- '2026/2027'
  jenis               text not null check (jenis in ('ganjil', 'genap', 'antara')),
  tanggal_mulai       date not null,
  tanggal_selesai     date not null,
  krs_dibuka          date,
  krs_ditutup         date,
  ukt_jatuh_tempo     date,
  is_aktif            boolean not null default false,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint periode_tanggal_wajar check (tanggal_selesai > tanggal_mulai)
);

-- Hanya boleh ada satu periode aktif pada satu waktu.
create unique index if not exists periode_satu_aktif
  on public.periode_akademik (is_aktif)
  where is_aktif;

create table if not exists public.dosen (
  id            uuid primary key default gen_random_uuid(),
  nidn          text unique,
  nama          text not null,
  gelar_depan   text,
  gelar_belakang text,
  email         text,
  is_pembimbing boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table if not exists public.mata_kuliah (
  id              uuid primary key default gen_random_uuid(),
  kode            text not null unique,
  nama            text not null,
  sks             smallint not null check (sks between 1 and 8),
  semester_ke     smallint not null check (semester_ke between 1 and 14),
  program_studi_id uuid references public.program_studi (id) on delete set null,
  is_praktikum    boolean not null default false,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- Satu penawaran mata kuliah pada satu periode (mis. SISTEM MANAJEMEN BASIS
-- DATA kelas IFB5A, Ganjil 2026/2027, Senin 08:00-10:30).
create table if not exists public.kelas_kuliah (
  id              uuid primary key default gen_random_uuid(),
  mata_kuliah_id  uuid not null references public.mata_kuliah (id) on delete cascade,
  periode_id      uuid not null references public.periode_akademik (id) on delete cascade,
  dosen_id        uuid references public.dosen (id) on delete set null,
  kode_kelas      text not null,                    -- 'IFB5A'
  ruang           text,
  hari            smallint check (hari between 1 and 7),  -- 1=Senin ... 7=Minggu
  jam_mulai       time,
  jam_selesai     time,
  kapasitas       smallint not null default 40,
  link_materi     text,
  is_aktif        boolean not null default true,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint kelas_unik unique (mata_kuliah_id, periode_id, kode_kelas),
  constraint kelas_jam_wajar check (
    jam_mulai is null or jam_selesai is null or jam_selesai > jam_mulai
  )
);

create index if not exists kelas_periode_idx on public.kelas_kuliah (periode_id);
create index if not exists kelas_mk_idx      on public.kelas_kuliah (mata_kuliah_id);
create index if not exists kelas_dosen_idx   on public.kelas_kuliah (dosen_id);

create table if not exists public.kalender_akademik (
  id             uuid primary key default gen_random_uuid(),
  periode_id     uuid references public.periode_akademik (id) on delete cascade,
  nama_kegiatan  text not null,
  deskripsi      text,
  tanggal_mulai  date not null,
  tanggal_selesai date,
  is_penting     boolean not null default false,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index if not exists kalender_periode_idx on public.kalender_akademik (periode_id);


-- ============================================================================
-- BAGIAN 3 — MAHASISWA
-- ============================================================================

-- Satu baris per user. id-nya sama dengan auth.users.id.
create table if not exists public.profiles (
  id               uuid primary key references auth.users (id) on delete cascade,
  email            text,
  nim              text unique,
  nama             text not null,
  nama_panggilan   text not null default 'Mahasiswa',
  program_studi_id uuid references public.program_studi (id) on delete set null,
  angkatan         smallint,
  semester_ke      smallint,
  role             text not null default 'mahasiswa'
                     check (role in ('mahasiswa', 'dosen', 'admin')),
  status           text not null default 'aktif'
                     check (status in ('aktif', 'cuti', 'lulus', 'nonaktif')),
  jenis_kelamin    text check (jenis_kelamin in ('L', 'P')),
  tempat_lahir     text,
  tanggal_lahir    date,
  no_hp            text,
  alamat           text,
  foto_url         text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists profiles_prodi_idx on public.profiles (program_studi_id);

create table if not exists public.biodata_keluarga (
  id               uuid primary key default gen_random_uuid(),
  mahasiswa_id     uuid not null unique references public.profiles (id) on delete cascade,
  nama_ayah        text,
  pekerjaan_ayah   text,
  nama_ibu         text,
  pekerjaan_ibu    text,
  nama_wali        text,
  pekerjaan_wali   text,
  penghasilan_ortu text,
  no_hp_ortu       text,
  alamat_ortu      text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);


-- ============================================================================
-- BAGIAN 3B — FUNGSI PEMBACA profiles
-- ============================================================================
-- Diletakkan SETELAH tabel profiles dibuat.
--
-- Kenapa tidak di BAGIAN 1: fungsi `language sql` divalidasi isinya pada saat
-- CREATE. Kalau tabel yang dirujuk belum ada, muncul
--   ERROR: 42P01: relation "public.profiles" does not exist
-- Ini persis error yang muncul kalau ketiga fungsi ini ditaruh di atas.
--
-- Kenapa tetap `language sql` dan bukan plpgsql: fungsi sql yang STABLE bisa
-- di-inline oleh planner. Ketiganya dipanggil per baris di dalam RLS policy,
-- jadi inlining-nya berpengaruh ke kecepatan query.

-- Role user yang sedang login ('mahasiswa' | 'dosen' | 'admin').
-- security definer supaya membaca profiles tidak memicu RLS berulang.
create or replace function public.current_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select p.role from public.profiles p where p.id = auth.uid()),
    'anon'
  );
$$;

-- true kalau yang login dosen atau admin (boleh menulis data akademik).
create or replace function public.is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('dosen', 'admin')
  );
$$;

-- true kalau yang login admin (boleh mengubah master data & pengumuman).
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  );
$$;


-- ============================================================================
-- BAGIAN 4 — AKADEMIK (KRS, NILAI, PRESENSI)
-- ============================================================================

create table if not exists public.krs (
  id                uuid primary key default gen_random_uuid(),
  mahasiswa_id      uuid not null references public.profiles (id) on delete cascade,
  periode_id        uuid not null references public.periode_akademik (id) on delete cascade,
  dosen_pa_id       uuid references public.dosen (id) on delete set null,
  status            text not null default 'draft'
                      check (status in ('draft', 'diajukan', 'disetujui', 'ditolak')),
  sks_diambil       smallint not null default 0,
  tanggal_pengajuan timestamptz,
  tanggal_verifikasi timestamptz,
  catatan           text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  constraint krs_unik unique (mahasiswa_id, periode_id)
);

create index if not exists krs_mahasiswa_idx on public.krs (mahasiswa_id);
create index if not exists krs_periode_idx   on public.krs (periode_id);

create table if not exists public.krs_detail (
  id        uuid primary key default gen_random_uuid(),
  krs_id    uuid not null references public.krs (id) on delete cascade,
  kelas_id  uuid not null references public.kelas_kuliah (id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint krs_detail_unik unique (krs_id, kelas_id)
);

create index if not exists krs_detail_kelas_idx on public.krs_detail (kelas_id);

-- Jadwal 16 kali tatap muka per kelas. Baris ini dibuat sekali di awal
-- semester; kolom is_terlaksana diisi setelah pertemuan benar-benar terjadi.
create table if not exists public.pertemuan_kuliah (
  id            uuid primary key default gen_random_uuid(),
  kelas_id      uuid not null references public.kelas_kuliah (id) on delete cascade,
  pertemuan_ke  smallint not null check (pertemuan_ke between 1 and 16),
  tanggal       date,
  materi        text,
  is_terlaksana boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint pertemuan_unik unique (kelas_id, pertemuan_ke)
);

-- Presensi mahasiswa per pertemuan.
create table if not exists public.presensi (
  id            uuid primary key default gen_random_uuid(),
  mahasiswa_id  uuid not null references public.profiles (id) on delete cascade,
  kelas_id      uuid not null references public.kelas_kuliah (id) on delete cascade,
  pertemuan_ke  smallint not null check (pertemuan_ke between 1 and 16),
  status        text not null check (status in ('hadir', 'sakit', 'izin', 'alpa')),
  keterangan    text,
  dicatat_pada  timestamptz not null default now(),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint presensi_unik unique (mahasiswa_id, kelas_id, pertemuan_ke),
  constraint presensi_pertemuan_fk foreign key (kelas_id, pertemuan_ke)
    references public.pertemuan_kuliah (kelas_id, pertemuan_ke) on delete cascade
);

create index if not exists presensi_mahasiswa_idx on public.presensi (mahasiswa_id);
create index if not exists presensi_kelas_idx      on public.presensi (kelas_id);

create table if not exists public.nilai (
  id            uuid primary key default gen_random_uuid(),
  mahasiswa_id  uuid not null references public.profiles (id) on delete cascade,
  kelas_id      uuid not null references public.kelas_kuliah (id) on delete cascade,
  nilai_huruf   text not null check (
    nilai_huruf in ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'E')
  ),
  tanggal_input timestamptz not null default now(),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint nilai_unik unique (mahasiswa_id, kelas_id)
);

create index if not exists nilai_mahasiswa_idx on public.nilai (mahasiswa_id);
create index if not exists nilai_kelas_idx     on public.nilai (kelas_id);


-- ============================================================================
-- BAGIAN 5 — KEUANGAN
-- ============================================================================

create table if not exists public.tagihan (
  id            uuid primary key default gen_random_uuid(),
  mahasiswa_id  uuid not null references public.profiles (id) on delete cascade,
  periode_id    uuid references public.periode_akademik (id) on delete set null,
  jenis         text not null default 'ukt',      -- 'ukt','praktikum','denda','lain'
  keterangan    text not null,
  nominal       numeric(12, 2) not null check (nominal >= 0),
  tanggal_terbit date not null default current_date,
  jatuh_tempo   date,
  status        text not null default 'belum_bayar'
                  check (status in ('belum_bayar', 'sebagian', 'lunas', 'batal')),
  va_number     text,
  bank          text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index if not exists tagihan_mahasiswa_idx on public.tagihan (mahasiswa_id);
create index if not exists tagihan_status_idx    on public.tagihan (status);

create table if not exists public.pembayaran (
  id          uuid primary key default gen_random_uuid(),
  tagihan_id  uuid not null references public.tagihan (id) on delete cascade,
  nominal     numeric(12, 2) not null check (nominal > 0),
  tanggal     timestamptz not null default now(),
  metode      text,                                -- 'transfer','va','tunai'
  referensi   text,                                -- nomor transaksi bank
  created_at  timestamptz not null default now()
);

create index if not exists pembayaran_tagihan_idx on public.pembayaran (tagihan_id);


-- ============================================================================
-- BAGIAN 6 — TUGAS AKHIR (SKRIPSI)
-- ============================================================================

-- Master 6 tahapan. Urutan 1..6 sesuai tampilan timeline di aplikasi.
create table if not exists public.tahapan_skripsi (
  id          uuid primary key default gen_random_uuid(),
  urutan      smallint not null unique check (urutan between 1 and 20),
  nama        text not null,
  keterangan  text,
  created_at  timestamptz not null default now()
);

-- Satu mahasiswa = satu skripsi (judul final yang sudah di-ACC).
create table if not exists public.skripsi (
  id                uuid primary key default gen_random_uuid(),
  mahasiswa_id      uuid not null unique references public.profiles (id) on delete cascade,
  periode_id        uuid references public.periode_akademik (id) on delete set null,
  judul             text,
  tahapan_aktif     smallint not null default 1,
  status            text not null default 'berjalan'
                      check (status in ('berjalan', 'lulus', 'gagal', 'batal')),
  tanggal_mulai     date,
  tanggal_selesai   date,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- Pengajuan judul. Boleh lebih dari satu per mahasiswa (riwayat pengajuan).
-- Aturan kampus: minimal berkas_1 terisi; berkas_2 dan berkas_3 kalau tidak
-- ada diisi karakter '-'.
create table if not exists public.skripsi_pengajuan (
  id               uuid primary key default gen_random_uuid(),
  mahasiswa_id     uuid not null references public.profiles (id) on delete cascade,
  judul            text not null check (char_length(trim(judul)) >= 10),
  berkas_1         text not null check (
                     char_length(trim(berkas_1)) > 0 and trim(berkas_1) <> '-'
                   ),
  berkas_2         text not null default '-',
  berkas_3         text not null default '-',
  status           text not null default 'menunggu'
                     check (status in ('menunggu', 'disetujui', 'ditolak')),
  catatan          text,
  tanggal_diajukan timestamptz not null default now(),
  diverifikasi_oleh uuid references public.profiles (id) on delete set null,
  tanggal_verifikasi timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists skripsi_pengajuan_mhs_idx on public.skripsi_pengajuan (mahasiswa_id);
create index if not exists skripsi_pengajuan_status_idx on public.skripsi_pengajuan (status);

-- Progres per tahapan (mengisi timeline di aplikasi).
create table if not exists public.skripsi_progres (
  id               uuid primary key default gen_random_uuid(),
  mahasiswa_id     uuid not null references public.profiles (id) on delete cascade,
  tahapan_id       uuid not null references public.tahapan_skripsi (id) on delete cascade,
  status           text not null default 'belum'
                     check (status in ('belum', 'berjalan', 'selesai')),
  tanggal_selesai  date,
  catatan          text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  constraint skripsi_progres_unik unique (mahasiswa_id, tahapan_id)
);

create table if not exists public.skripsi_pembimbing (
  id                uuid primary key default gen_random_uuid(),
  mahasiswa_id      uuid not null references public.profiles (id) on delete cascade,
  dosen_id          uuid not null references public.dosen (id) on delete cascade,
  peran             smallint not null check (peran in (1, 2)),
  tanggal_ditetapkan date not null default current_date,
  created_at        timestamptz not null default now(),
  constraint skripsi_pembimbing_unik unique (mahasiswa_id, peran),
  constraint skripsi_pembimbing_dosen_unik unique (mahasiswa_id, dosen_id)
);

create table if not exists public.bimbingan (
  id            uuid primary key default gen_random_uuid(),
  mahasiswa_id  uuid not null references public.profiles (id) on delete cascade,
  dosen_id      uuid references public.dosen (id) on delete set null,
  pertemuan_ke  smallint,
  tanggal       date not null default current_date,
  topik         text,
  catatan       text,
  disetujui     boolean not null default false,
  created_at    timestamptz not null default now()
);

create index if not exists bimbingan_mhs_idx on public.bimbingan (mahasiswa_id);


-- ============================================================================
-- BAGIAN 7 — KOMUNIKASI & PENGUMUMAN
-- ============================================================================

create table if not exists public.pesan (
  id          uuid primary key default gen_random_uuid(),
  pengirim_id uuid references public.profiles (id) on delete set null,
  penerima_id uuid references public.profiles (id) on delete cascade,
  subjek      text,
  isi         text not null,
  kategori    text not null default 'umum'
                check (kategori in ('umum', 'akademik', 'keuangan', 'skripsi', 'pengumuman')),
  is_terkirim boolean not null default false,
  dibaca      boolean not null default false,
  dibuat_pada timestamptz not null default now(),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists pesan_penerima_idx on public.pesan (penerima_id, dibaca);

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

create index if not exists pengumuman_tanggal_idx on public.pengumuman (tanggal_mulai desc);


-- ============================================================================
-- BAGIAN 8 — TRIGGER updated_at
-- ============================================================================

do $$
declare
  t text;
begin
  foreach t in array array[
    'program_studi', 'periode_akademik', 'dosen', 'mata_kuliah', 'kelas_kuliah',
    'kalender_akademik', 'profiles', 'biodata_keluarga', 'krs', 'pertemuan_kuliah',
    'presensi', 'nilai', 'tagihan', 'skripsi', 'skripsi_pengajuan',
    'skripsi_progres', 'pesan', 'pengumuman'
  ]
  loop
    execute format('drop trigger if exists set_updated_at on public.%I', t);
    execute format(
      'create trigger set_updated_at before update on public.%I
       for each row execute function public.set_updated_at()', t
    );
  end loop;
end;
$$;

-- Trigger pembuatan profil otomatis saat user baru mendaftar.
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Menjaga krs.sks_diambil selalu sama dengan jumlah SKS di krs_detail,
-- jadi angka SKS tidak bisa lagi beda dengan daftar mata kuliahnya.
create or replace function public.hitung_sks_krs()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_krs uuid;
begin
  if tg_op = 'DELETE' then
    v_krs := old.krs_id;
  else
    v_krs := new.krs_id;
  end if;

  update public.krs k
  set sks_diambil = coalesce((
    select sum(mk.sks)
    from public.krs_detail kd
    join public.kelas_kuliah kk on kk.id = kd.kelas_id
    join public.mata_kuliah mk   on mk.id = kk.mata_kuliah_id
    where kd.krs_id = v_krs
  ), 0)
  where k.id = v_krs;

  return null;
end;
$$;

drop trigger if exists krs_detail_hitung_sks on public.krs_detail;
create trigger krs_detail_hitung_sks
  after insert or update or delete on public.krs_detail
  for each row execute function public.hitung_sks_krs();


-- ============================================================================
-- BAGIAN 9 — VIEW (perhitungan IPS, IPK, presensi, ringkasan)
-- ============================================================================

-- Nilai per mata kuliah lengkap dengan bobot dan mutu (bobot x sks).
drop view if exists public.v_nilai_mahasiswa;
create view public.v_nilai_mahasiswa as
select
  n.id                as nilai_id,
  n.mahasiswa_id,
  kk.periode_id,
  pa.kode             as periode_kode,
  pa.nama             as periode_nama,
  mk.kode             as mk_kode,
  mk.nama             as mk_nama,
  mk.sks,
  kk.kode_kelas,
  n.nilai_huruf,
  public.bobot_mutu(n.nilai_huruf)                        as bobot,
  public.bobot_mutu(n.nilai_huruf) * mk.sks               as mutu
from public.nilai n
join public.kelas_kuliah kk on kk.id = n.kelas_id
join public.mata_kuliah mk  on mk.id = kk.mata_kuliah_id
join public.periode_akademik pa on pa.id = kk.periode_id;

-- IPS per semester: jumlah mutu / jumlah SKS.
drop view if exists public.v_ips_periode;
create view public.v_ips_periode as
select
  v.mahasiswa_id,
  v.periode_id,
  v.periode_kode,
  v.periode_nama,
  sum(v.sks)::int                                     as sks_diambil,
  sum(v.mutu)                                         as total_mutu,
  round(sum(v.mutu) / nullif(sum(v.sks), 0), 2)       as ips
from public.v_nilai_mahasiswa v
group by v.mahasiswa_id, v.periode_id, v.periode_kode, v.periode_nama;

-- IPK kumulatif seluruh semester yang sudah dinilai.
drop view if exists public.v_ipk_mahasiswa;
create view public.v_ipk_mahasiswa as
select
  v.mahasiswa_id,
  sum(v.sks)::int                                     as sks_lulus,
  sum(v.mutu)                                         as total_mutu,
  round(sum(v.mutu) / nullif(sum(v.sks), 0), 2)       as ipk
from public.v_nilai_mahasiswa v
where v.nilai_huruf not in ('D', 'E')                 -- D & E tidak dihitung lulus
group by v.mahasiswa_id;

-- Rekap presensi per mata kuliah: hadir/sakit/izin/alpa dari 16 pertemuan.
drop view if exists public.v_rekap_presensi;
create view public.v_rekap_presensi as
select
  p.mahasiswa_id,
  p.kelas_id,
  kk.periode_id,
  mk.kode                                             as mk_kode,
  mk.nama                                             as mk_nama,
  mk.sks,
  kk.kode_kelas,
  count(*) filter (where p.status = 'hadir')::int     as hadir,
  count(*) filter (where p.status = 'sakit')::int     as sakit,
  count(*) filter (where p.status = 'izin')::int      as izin,
  count(*) filter (where p.status = 'alpa')::int      as alpa,
  count(*)::int                                       as pertemuan_terlaksana,
  16                                                  as pertemuan_rencana,
  round(100.0 * count(*) filter (where p.status = 'hadir') / nullif(count(*), 0), 0)
                                                      as persen_hadir,
  round(100.0 * count(*) filter (where p.status = 'hadir') / 16, 0)
                                                      as persen_dari_rencana
from public.presensi p
join public.kelas_kuliah kk on kk.id = p.kelas_id
join public.mata_kuliah mk  on mk.id = kk.mata_kuliah_id
group by p.mahasiswa_id, p.kelas_id, kk.periode_id, mk.kode, mk.nama, mk.sks, kk.kode_kelas;

-- Progres realisasi pertemuan per kelas (dipakai grafik "Tatap Muka").
drop view if exists public.v_progres_pertemuan;
create view public.v_progres_pertemuan as
select
  pt.kelas_id,
  kk.periode_id,
  mk.kode                                             as mk_kode,
  mk.nama                                             as mk_nama,
  count(*) filter (where pt.is_terlaksana)::int       as terlaksana,
  count(*)::int                                       as rencana,
  round(100.0 * count(*) filter (where pt.is_terlaksana) / nullif(count(*), 0), 0)
                                                      as persen
from public.pertemuan_kuliah pt
join public.kelas_kuliah kk on kk.id = pt.kelas_id
join public.mata_kuliah mk  on mk.id = kk.mata_kuliah_id
group by pt.kelas_id, kk.periode_id, mk.kode, mk.nama;

-- Sisa tagihan per mahasiswa (total tagihan - total pembayaran).
drop view if exists public.v_tagihan_mahasiswa;
create view public.v_tagihan_mahasiswa as
select
  t.mahasiswa_id,
  t.id                                                as tagihan_id,
  t.periode_id,
  t.jenis,
  t.keterangan,
  t.nominal,
  coalesce(sum(b.nominal), 0)                         as dibayar,
  t.nominal - coalesce(sum(b.nominal), 0)             as sisa,
  t.jatuh_tempo,
  t.status
from public.tagihan t
left join public.pembayaran b on b.tagihan_id = t.id
group by t.id;

-- Ringkasan satu baris per mahasiswa untuk dashboard.
drop view if exists public.v_ringkasan_akademik;
create view public.v_ringkasan_akademik as
select
  pr.id                                               as mahasiswa_id,
  pr.nim,
  pr.nama,
  pr.nama_panggilan,
  pr.semester_ke,
  coalesce(ipk.ipk, 0)                                as ipk,
  coalesce(ipk.sks_lulus, 0)                          as sks_lulus,
  coalesce(aktif.jumlah_mk, 0)                        as jumlah_mk_aktif,
  coalesce(aktif.sks_semester_ini, 0)                 as sks_semester_ini,
  coalesce(tag.sisa_total, 0)                         as sisa_tagihan
from public.profiles pr
left join public.v_ipk_mahasiswa ipk on ipk.mahasiswa_id = pr.id
left join (
  select
    k.mahasiswa_id,
    count(kd.id)::int                                 as jumlah_mk,
    coalesce(sum(mk.sks), 0)::int                     as sks_semester_ini
  from public.krs k
  join public.periode_akademik pa on pa.id = k.periode_id and pa.is_aktif
  join public.krs_detail kd on kd.krs_id = k.id
  join public.kelas_kuliah kk on kk.id = kd.kelas_id
  join public.mata_kuliah mk on mk.id = kk.mata_kuliah_id
  where k.status in ('diajukan', 'disetujui')
  group by k.mahasiswa_id
) aktif on aktif.mahasiswa_id = pr.id
left join (
  select mahasiswa_id, sum(sisa) as sisa_total
  from public.v_tagihan_mahasiswa
  where status <> 'batal'
  group by mahasiswa_id
) tag on tag.mahasiswa_id = pr.id;

-- View di atas tetap menghormati RLS tabel di bawahnya.
alter view public.v_nilai_mahasiswa     set (security_invoker = on);
alter view public.v_ips_periode         set (security_invoker = on);
alter view public.v_ipk_mahasiswa       set (security_invoker = on);
alter view public.v_rekap_presensi      set (security_invoker = on);
alter view public.v_progres_pertemuan   set (security_invoker = on);
alter view public.v_tagihan_mahasiswa   set (security_invoker = on);
alter view public.v_ringkasan_akademik  set (security_invoker = on);


-- ============================================================================
-- BAGIAN 10 — ROW LEVEL SECURITY
-- ============================================================================
-- Aturan singkat:
--   * master data  -> semua user login boleh BACA, hanya admin yang menulis
--   * data pribadi -> mahasiswa hanya melihat barisnya sendiri
--   * nilai/presensi -> mahasiswa baca saja, dosen/admin yang menulis

alter table public.program_studi      enable row level security;
alter table public.periode_akademik   enable row level security;
alter table public.dosen              enable row level security;
alter table public.mata_kuliah        enable row level security;
alter table public.kelas_kuliah       enable row level security;
alter table public.kalender_akademik  enable row level security;
alter table public.profiles           enable row level security;
alter table public.biodata_keluarga   enable row level security;
alter table public.krs                enable row level security;
alter table public.krs_detail         enable row level security;
alter table public.pertemuan_kuliah   enable row level security;
alter table public.presensi           enable row level security;
alter table public.nilai              enable row level security;
alter table public.tagihan            enable row level security;
alter table public.pembayaran         enable row level security;
alter table public.tahapan_skripsi    enable row level security;
alter table public.skripsi            enable row level security;
alter table public.skripsi_pengajuan  enable row level security;
alter table public.skripsi_progres    enable row level security;
alter table public.skripsi_pembimbing enable row level security;
alter table public.bimbingan          enable row level security;
alter table public.pesan              enable row level security;
alter table public.pengumuman         enable row level security;

-- ---- master: baca untuk semua user login, tulis hanya admin

drop policy if exists program_studi_baca on public.program_studi;
create policy program_studi_baca on public.program_studi
  for select to authenticated using (true);
drop policy if exists program_studi_tulis on public.program_studi;
create policy program_studi_tulis on public.program_studi
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists periode_baca on public.periode_akademik;
create policy periode_baca on public.periode_akademik
  for select to authenticated using (true);
drop policy if exists periode_tulis on public.periode_akademik;
create policy periode_tulis on public.periode_akademik
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists dosen_baca on public.dosen;
create policy dosen_baca on public.dosen
  for select to authenticated using (true);
drop policy if exists dosen_tulis on public.dosen;
create policy dosen_tulis on public.dosen
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists mata_kuliah_baca on public.mata_kuliah;
create policy mata_kuliah_baca on public.mata_kuliah
  for select to authenticated using (true);
drop policy if exists mata_kuliah_tulis on public.mata_kuliah;
create policy mata_kuliah_tulis on public.mata_kuliah
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists kelas_baca on public.kelas_kuliah;
create policy kelas_baca on public.kelas_kuliah
  for select to authenticated using (true);
drop policy if exists kelas_tulis on public.kelas_kuliah;
create policy kelas_tulis on public.kelas_kuliah
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists kalender_baca on public.kalender_akademik;
create policy kalender_baca on public.kalender_akademik
  for select to authenticated using (true);
drop policy if exists kalender_tulis on public.kalender_akademik;
create policy kalender_tulis on public.kalender_akademik
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists tahapan_baca on public.tahapan_skripsi;
create policy tahapan_baca on public.tahapan_skripsi
  for select to authenticated using (true);
drop policy if exists tahapan_tulis on public.tahapan_skripsi;
create policy tahapan_tulis on public.tahapan_skripsi
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists pengumuman_baca on public.pengumuman;
create policy pengumuman_baca on public.pengumuman
  for select to authenticated using (true);
drop policy if exists pengumuman_tulis on public.pengumuman;
create policy pengumuman_tulis on public.pengumuman
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ---- profiles: diri sendiri + staff boleh lihat semua

drop policy if exists profiles_baca on public.profiles;
create policy profiles_baca on public.profiles
  for select to authenticated
  using (id = auth.uid() or public.is_staff());

drop policy if exists profiles_ubah_sendiri on public.profiles;
create policy profiles_ubah_sendiri on public.profiles
  for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists profiles_admin on public.profiles;
create policy profiles_admin on public.profiles
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ---- data pribadi mahasiswa

drop policy if exists biodata_baca on public.biodata_keluarga;
create policy biodata_baca on public.biodata_keluarga
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());

drop policy if exists biodata_tulis on public.biodata_keluarga;
create policy biodata_tulis on public.biodata_keluarga
  for all to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff())
  with check (mahasiswa_id = auth.uid() or public.is_staff());

-- ---- KRS: mahasiswa boleh baca & mengisi draf miliknya sendiri,
--      persetujuan dilakukan dosen/admin.

drop policy if exists krs_baca on public.krs;
create policy krs_baca on public.krs
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());

drop policy if exists krs_isi_sendiri on public.krs;
create policy krs_isi_sendiri on public.krs
  for insert to authenticated
  with check (mahasiswa_id = auth.uid() and status in ('draft', 'diajukan'));

drop policy if exists krs_ubah_draf on public.krs;
create policy krs_ubah_draf on public.krs
  for update to authenticated
  using (mahasiswa_id = auth.uid() and status in ('draft', 'diajukan'))
  with check (mahasiswa_id = auth.uid());

drop policy if exists krs_staff on public.krs;
create policy krs_staff on public.krs
  for all to authenticated using (public.is_staff()) with check (public.is_staff());

drop policy if exists krs_detail_baca on public.krs_detail;
create policy krs_detail_baca on public.krs_detail
  for select to authenticated
  using (
    public.is_staff()
    or exists (
      select 1 from public.krs k
      where k.id = krs_detail.krs_id and k.mahasiswa_id = auth.uid()
    )
  );

drop policy if exists krs_detail_tulis on public.krs_detail;
create policy krs_detail_tulis on public.krs_detail
  for all to authenticated
  using (
    public.is_staff()
    or exists (
      select 1 from public.krs k
      where k.id = krs_detail.krs_id and k.mahasiswa_id = auth.uid()
        and k.status in ('draft', 'diajukan')
    )
  )
  with check (
    public.is_staff()
    or exists (
      select 1 from public.krs k
      where k.id = krs_detail.krs_id and k.mahasiswa_id = auth.uid()
    )
  );

-- ---- nilai, presensi, pertemuan: mahasiswa baca sendiri, staff menulis

drop policy if exists nilai_baca on public.nilai;
create policy nilai_baca on public.nilai
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());
drop policy if exists nilai_tulis on public.nilai;
create policy nilai_tulis on public.nilai
  for all to authenticated using (public.is_staff()) with check (public.is_staff());

drop policy if exists presensi_baca on public.presensi;
create policy presensi_baca on public.presensi
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());
drop policy if exists presensi_tulis on public.presensi;
create policy presensi_tulis on public.presensi
  for all to authenticated using (public.is_staff()) with check (public.is_staff());

drop policy if exists pertemuan_baca on public.pertemuan_kuliah;
create policy pertemuan_baca on public.pertemuan_kuliah
  for select to authenticated using (true);
drop policy if exists pertemuan_tulis on public.pertemuan_kuliah;
create policy pertemuan_tulis on public.pertemuan_kuliah
  for all to authenticated using (public.is_staff()) with check (public.is_staff());

-- ---- keuangan

drop policy if exists tagihan_baca on public.tagihan;
create policy tagihan_baca on public.tagihan
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());
drop policy if exists tagihan_tulis on public.tagihan;
create policy tagihan_tulis on public.tagihan
  for all to authenticated using (public.is_staff()) with check (public.is_staff());

drop policy if exists pembayaran_baca on public.pembayaran;
create policy pembayaran_baca on public.pembayaran
  for select to authenticated
  using (
    public.is_staff()
    or exists (
      select 1 from public.tagihan t
      where t.id = pembayaran.tagihan_id and t.mahasiswa_id = auth.uid()
    )
  );
drop policy if exists pembayaran_tulis on public.pembayaran;
create policy pembayaran_tulis on public.pembayaran
  for all to authenticated using (public.is_staff()) with check (public.is_staff());

-- ---- skripsi: mahasiswa mengajukan & memantau, staff memverifikasi

drop policy if exists skripsi_baca on public.skripsi;
create policy skripsi_baca on public.skripsi
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());
drop policy if exists skripsi_ubah on public.skripsi;
create policy skripsi_ubah on public.skripsi
  for all to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff())
  with check (mahasiswa_id = auth.uid() or public.is_staff());

drop policy if exists pengajuan_baca on public.skripsi_pengajuan;
create policy pengajuan_baca on public.skripsi_pengajuan
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());

drop policy if exists pengajuan_ajukan on public.skripsi_pengajuan;
create policy pengajuan_ajukan on public.skripsi_pengajuan
  for insert to authenticated
  with check (mahasiswa_id = auth.uid());

-- Mahasiswa hanya boleh membatalkan/menghapus pengajuan yang masih menunggu,
-- dan tidak boleh mengubah kolom status.
drop policy if exists pengajuan_hapus on public.skripsi_pengajuan;
create policy pengajuan_hapus on public.skripsi_pengajuan
  for delete to authenticated
  using (mahasiswa_id = auth.uid() and status = 'menunggu');

drop policy if exists pengajuan_verifikasi on public.skripsi_pengajuan;
create policy pengajuan_verifikasi on public.skripsi_pengajuan
  for update to authenticated
  using (public.is_staff()) with check (public.is_staff());

drop policy if exists progres_baca on public.skripsi_progres;
create policy progres_baca on public.skripsi_progres
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());
drop policy if exists progres_tulis on public.skripsi_progres;
create policy progres_tulis on public.skripsi_progres
  for all to authenticated using (public.is_staff()) with check (public.is_staff());

drop policy if exists pembimbing_baca on public.skripsi_pembimbing;
create policy pembimbing_baca on public.skripsi_pembimbing
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());
drop policy if exists pembimbing_tulis on public.skripsi_pembimbing;
create policy pembimbing_tulis on public.skripsi_pembimbing
  for all to authenticated using (public.is_staff()) with check (public.is_staff());

drop policy if exists bimbingan_baca on public.bimbingan;
create policy bimbingan_baca on public.bimbingan
  for select to authenticated
  using (mahasiswa_id = auth.uid() or public.is_staff());
drop policy if exists bimbingan_tulis on public.bimbingan;
create policy bimbingan_tulis on public.bimbingan
  for all to authenticated using (public.is_staff()) with check (public.is_staff());

-- ---- pesan: hanya pengirim dan penerima

drop policy if exists pesan_baca on public.pesan;
create policy pesan_baca on public.pesan
  for select to authenticated
  using (penerima_id = auth.uid() or pengirim_id = auth.uid() or public.is_staff());

drop policy if exists pesan_kirim on public.pesan;
create policy pesan_kirim on public.pesan
  for insert to authenticated
  with check (pengirim_id = auth.uid());

-- Menandai sudah dibaca hanya boleh oleh penerima.
drop policy if exists pesan_tandai_dibaca on public.pesan;
create policy pesan_tandai_dibaca on public.pesan
  for update to authenticated
  using (penerima_id = auth.uid())
  with check (penerima_id = auth.uid());
