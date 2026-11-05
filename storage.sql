-- ============================================================================
-- SmartKampus — Supabase Storage untuk foto profil
-- ----------------------------------------------------------------------------
-- Jalankan SETELAH schema.sql dan seed.sql.
-- Aman dijalankan berulang.
--
-- Yang dibuat:
--   1. bucket `foto-profil` (publik untuk DIBACA, tapi hanya pemilik yang
--      boleh MENULIS ke foldernya sendiri)
--   2. 4 policy pada storage.objects
--
-- Kenapa publik untuk dibaca: Supabase Storage butuh policy SELECT walaupun
-- bucket-nya public, dan foto profil memang tidak rahasia. Yang dijaga adalah
-- siapa yang boleh menulis.
--
-- Struktur file di dalam bucket:
--   foto-profil/<uid-mahasiswa>/avatar.jpg
-- Policy di bawah memakai (storage.foldername(name))[1] = auth.uid()
-- sehingga mahasiswa A TIDAK bisa menimpa foto mahasiswa B.
-- ============================================================================

-- ------------------------------------------------------------------ BUCKET
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'foto-profil',
  'foto-profil',
  true,
  2097152,                                        -- maksimal 2 MB
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;


-- ----------------------------------------------------------------- POLICY
-- Hapus dulu supaya bisa dijalankan ulang tanpa error "already exists".
drop policy if exists "foto_profil_baca"   on storage.objects;
drop policy if exists "foto_profil_unggah" on storage.objects;
drop policy if exists "foto_profil_ubah"   on storage.objects;
drop policy if exists "foto_profil_hapus"  on storage.objects;

-- Siapa pun (termasuk yang belum login) boleh MELIHAT foto profil.
create policy "foto_profil_baca" on storage.objects
  for select
  using (bucket_id = 'foto-profil');

-- Hanya pemilik folder yang boleh mengunggah.
create policy "foto_profil_unggah" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'foto-profil'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Hanya pemilik folder yang boleh menimpa (upsert).
create policy "foto_profil_ubah" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'foto-profil'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'foto-profil'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Hanya pemilik folder yang boleh menghapus.
create policy "foto_profil_hapus" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'foto-profil'
    and (storage.foldername(name))[1] = auth.uid()::text
  );


-- ============================================================================
-- PEMERIKSAAN
-- ============================================================================

-- Harus muncul 1 baris: foto-profil | public = true | limit 2097152
select id, public, file_size_limit, allowed_mime_types
from storage.buckets
where id = 'foto-profil';

-- Harus muncul 4 policy.
select policyname, cmd
from pg_policies
where schemaname = 'storage' and tablename = 'objects'
  and policyname like 'foto_profil%'
order by policyname;