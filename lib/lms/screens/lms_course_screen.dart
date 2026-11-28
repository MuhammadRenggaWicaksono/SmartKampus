import 'package:flutter/material.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/konten_layar.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/lms/models/moodle_course.dart';
import 'package:app_kampus/lms/models/moodle_forum.dart';
import 'package:app_kampus/lms/models/moodle_kuis.dart';
import 'package:app_kampus/lms/models/moodle_materi.dart';
import 'package:app_kampus/lms/models/moodle_tugas.dart';
import 'package:app_kampus/lms/moodle_format.dart';
import 'package:app_kampus/lms/providers/lms_session.dart';
import 'package:app_kampus/lms/screens/lms_assignment_screen.dart';
import 'package:app_kampus/lms/services/moodle_api_service.dart';
import 'package:app_kampus/lms/widgets/lms_support.dart';

/// Halaman detail satu mata kuliah: Pengumuman, Tugas, dan Materi.

class LmsCourseScreen extends StatefulWidget {
  const LmsCourseScreen({super.key, required this.course});

  final MoodleCourse course;

  @override
  State<LmsCourseScreen> createState() => _LmsCourseScreenState();
}

class _LmsCourseScreenState extends State<LmsCourseScreen> {
  final MoodleApiService _api = MoodleApiService();

  String get _token => lmsSession.token ?? '';

  @override
  Widget build(BuildContext context) {
    final mk = widget.course;
    final warna = warnaKelas(mk.id);

    return ThemeBuilder(
      builder: (context, p) {
        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Detail Kelas',
                style: TextStyle(color: p.textPrimary, fontSize: 18),
              ),
              backgroundColor: p.card,
              foregroundColor: p.textPrimary,
              iconTheme: IconThemeData(color: p.textPrimary),
              elevation: 0.5,
            ),
            body: KontenLayar(
              paddingHp: EdgeInsets.zero,
              paddingLebar: EdgeInsets.zero,
              child: DefaultTabController(
                length: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _kepala(p, mk, warna),
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: p.accentInk,
                      unselectedLabelColor: p.textCardSupport,
                      indicatorColor: p.accent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const <Widget>[
                        Tab(text: 'Pengumuman'),
                        Tab(text: 'Tugas'),
                        Tab(text: 'Kuis'),
                        Tab(text: 'Materi'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          _TabPengumuman(
                            api: _api,
                            token: _token,
                            courseId: mk.id,
                          ),
                          _TabTugas(
                            api: _api,
                            token: _token,
                            courseId: mk.id,
                            namaKelas: mk.fullName,
                          ),
                          _TabKuis(
                            api: _api,
                            token: _token,
                            courseId: mk.id,
                          ),
                          _TabMateri(
                            api: _api,
                            token: _token,
                            courseId: mk.id,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _kepala(AppPalette p, MoodleCourse mk, Color warna) {
    return Container(
      color: warna,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mk.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _pil(mk.shortName),
              const SizedBox(width: 8),
              _pil('${mk.progress.round()}% selesai'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (mk.progress / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pil(String teks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        teks,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- pengumuman

class _TabPengumuman extends StatelessWidget {
  const _TabPengumuman({
    required this.api,
    required this.token,
    required this.courseId,
  });

  final MoodleApiService api;
  final String token;
  final int courseId;

  /// Forum `news` dulu (pengumuman), lalu `general`, lalu forum apa pun.
  Future<List<ForumDiscussion>> _muat() async {
    final forums = await api.getForums(token: token, courseId: courseId);
    if (forums.isEmpty) return const <ForumDiscussion>[];

    final forum = forums.firstWhere(
      (f) => f.pengumuman,
      orElse: () => forums.firstWhere(
        (f) => f.type == 'general',
        orElse: () => forums.first,
      ),
    );
    return api.getForumDiscussions(token: token, forumId: forum.id);
  }

  @override
  Widget build(BuildContext context) {
    return LmsTabData<List<ForumDiscussion>>(
      muat: _muat,
      bangun: (p, data, segarkan) {
        if (data.isEmpty) {
          return RefreshIndicator(
            onRefresh: segarkan,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const <Widget>[
                LmsStatus(
                  ikon: Icons.campaign_outlined,
                  teks: 'Belum ada pengumuman di kelas ini.',
                ),
              ],
            ),
          );
        }

        final urut = data.toList()
          ..sort((a, b) {
            if (a.disematkan != b.disematkan) return a.disematkan ? -1 : 1;
            return (b.dibuat ?? 0).compareTo(a.dibuat ?? 0);
          });

        return RefreshIndicator(
          onRefresh: segarkan,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: urut.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _kartu(p, urut[i]),
          ),
        );
      },
    );
  }

  Widget _kartu(AppPalette p, ForumDiscussion d) {
    final isi = bersihkanHtml(d.pesan);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: p.cardDeco(radius: 14, borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (d.disematkan)
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 6),
                  child: Icon(Icons.push_pin, size: 14, color: p.accentInk),
                ),
              Expanded(
                child: Text(
                  d.judul,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: p.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${d.penulis} · ${tanggalMoodle(d.dibuat)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: p.textCardSupport),
          ),
          if (isi.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              isi,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: p.textSecondary,
              ),
            ),
          ],
          if (d.jumlahBalasan > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Icon(
                  Icons.mode_comment_outlined,
                  size: 13,
                  color: p.textCardSupport,
                ),
                const SizedBox(width: 5),
                Text(
                  '${d.jumlahBalasan} balasan',
                  style: TextStyle(fontSize: 11.5, color: p.textCardSupport),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------- tugas

class _TabTugas extends StatelessWidget {
  const _TabTugas({
    required this.api,
    required this.token,
    required this.courseId,
    required this.namaKelas,
  });

  final MoodleApiService api;
  final String token;
  final int courseId;
  final String namaKelas;

  Future<List<Assignment>> _muat() =>
      api.getAssignments(token: token, courseId: courseId);

  @override
  Widget build(BuildContext context) {
    return LmsTabData<List<Assignment>>(
      muat: _muat,
      bangun: (p, data, segarkan) {
        if (data.isEmpty) {
          return RefreshIndicator(
            onRefresh: segarkan,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const <Widget>[
                LmsStatus(
                  ikon: Icons.assignment_turned_in_outlined,
                  teks: 'Belum ada tugas di kelas ini.',
                ),
              ],
            ),
          );
        }

        // Tenggat paling dekat di atas; yang tanpa tenggat paling bawah.
        final urut = data.toList()
          ..sort((a, b) {
            final ta = a.tenggat;
            final tb = b.tenggat;
            if (ta == null && tb == null) return a.nama.compareTo(b.nama);
            if (ta == null) return 1;
            if (tb == null) return -1;
            return ta.compareTo(tb);
          });

        return RefreshIndicator(
          onRefresh: segarkan,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: urut.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LmsAssignmentScreen(
                    tugas: urut[i],
                    namaKelas: namaKelas,
                  ),
                ),
              ),
              child: _kartu(p, urut[i]),
            ),
          ),
        );
      },
    );
  }

  Widget _kartu(AppPalette p, Assignment tugas) {
    final intro = bersihkanHtml(tugas.intro);
    final sisa = sisaHari(tugas.tenggat);

    late final String labelTenggat;
    late final Color warnaTenggat;
    if (tugas.tenggat == null) {
      labelTenggat = 'Tanpa tenggat';
      warnaTenggat = p.textCardSupport;
    } else if (sisa != null && sisa < 0) {
      labelTenggat = 'Terlambat ${-sisa} hari';
      warnaTenggat = p.danger;
    } else if (sisa == 0) {
      labelTenggat = 'Tenggat hari ini';
      warnaTenggat = p.danger;
    } else if (sisa != null && sisa <= 2) {
      labelTenggat = '$sisa hari lagi';
      warnaTenggat = p.warning;
    } else {
      labelTenggat = '$sisa hari lagi';
      warnaTenggat = p.success;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: p.cardDeco(radius: 14, borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 18,
                color: p.warning,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  tugas.nama,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: p.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: warnaTenggat.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.schedule, size: 12, color: warnaTenggat),
                    const SizedBox(width: 5),
                    Text(
                      labelTenggat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: p.statusInk(warnaTenggat),
                      ),
                    ),
                  ],
                ),
              ),
              if (tugas.tenggat != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    tanggalJamMoodle(tugas.tenggat),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: p.textCardSupport),
                  ),
                ),
              ],
            ],
          ),
          if (intro.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              intro,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: p.textSecondary,
              ),
            ),
          ],
          if (tugas.nilaiMaks > 0) ...[
            const SizedBox(height: 9),
            Text(
              'Nilai maksimal ${tugas.nilaiMaks.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 11.5, color: p.textCardSupport),
            ),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------------ kuis

/// Kuis kelas (`mod_quiz`).
///
/// Kuis berbeda dari tugas: pengerjaannya di halaman Moodle, dan kuis ber-
/// **Safe Exam Browser** memang hanya bisa dibuka dari browser terkunci itu.
/// Karena itu tab ini menampilkan status & nilai, lalu menyediakan tombol
/// buka di browser — bukan memaksa pengerjaan di dalam app.
class _TabKuis extends StatelessWidget {
  const _TabKuis({
    required this.api,
    required this.token,
    required this.courseId,
  });

  final MoodleApiService api;
  final String token;
  final int courseId;

  Future<List<KuisRingkas>> _muat() => api.getKuisKelas(
    token: token,
    courseId: courseId,
    userId: lmsSession.user?.userId ?? 0,
  );

  @override
  Widget build(BuildContext context) {
    return LmsTabData<List<KuisRingkas>>(
      muat: _muat,
      bangun: (p, data, segarkan) {
        if (data.isEmpty) {
          return RefreshIndicator(
            onRefresh: segarkan,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const <Widget>[
                LmsStatus(ikon: Icons.quiz_outlined, teks: 'Belum ada kuis di kelas ini.'),
              ],
            ),
          );
        }

        // Yang paling cepat ditutup di atas; tanpa tenggat paling bawah.
        final urut = data.toList()
          ..sort((a, b) {
            final ta = a.kuis.tutup;
            final tb = b.kuis.tutup;
            if (ta == null && tb == null) {
              return a.kuis.nama.compareTo(b.kuis.nama);
            }
            if (ta == null) return 1;
            if (tb == null) return -1;
            return ta.compareTo(tb);
          });

        return RefreshIndicator(
          onRefresh: segarkan,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: urut.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _kartu(context, p, urut[i]),
          ),
        );
      },
    );
  }

  Widget _kartu(BuildContext context, AppPalette p, KuisRingkas ringkas) {
    final kuis = ringkas.kuis;
    final sisa = sisaHari(kuis.tutup);
    final ditutup = sisa != null && sisa < 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: p.cardDeco(radius: 14, borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.quiz_outlined, size: 18, color: p.danger),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  kuis.nama,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: p.textPrimary,
                  ),
                ),
              ),
              if (ringkas.sudahAdaNilai)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: p.success.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Nilai ${ringkas.nilai!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.statusInk(p.success),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (kuis.nilaiMaks > 0)
                _pil(p, Icons.grade_outlined, 'Maks ${kuis.nilaiMaks.toStringAsFixed(0)}', p.accentInk),
              if (kuis.terbatasWaktu)
                _pil(p, Icons.timer_outlined, kuis.labelBatasWaktu, p.accentInk),
              _pil(p, Icons.repeat, kuis.labelPercobaan, p.textCardSupport),
              _pil(
                p,
                Icons.event_outlined,
                kuis.tutup == null ? 'Tanpa tenggat' : 'Tutup ${tanggalMoodle(kuis.tutup)}',
                ditutup ? p.textCardSupport : (sisa != null && sisa <= 3 ? p.warning : p.textCardSupport),
              ),
            ],
          ),
          if (!ringkas.sudahAdaNilai && !ditutup) ...[
            const SizedBox(height: 9),
            Text(
              'Belum ada nilai untuk akunmu.',
              style: TextStyle(fontSize: 11.5, color: p.textCardSupport),
            ),
          ],
          const SizedBox(height: 11),
          OutlinedButton.icon(
            onPressed: () =>
                bukaDiLuar(api.urlModul('quiz', kuis.moduleId)),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(ditutup ? 'Lihat di browser' : 'Kerjakan di browser'),
            style: OutlinedButton.styleFrom(
              foregroundColor: p.accentInk,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kuis dijalankan di halaman Moodle. Kuis yang mewajibkan Safe Exam '
            'Browser memang hanya bisa dibuka dari browser tersebut.',
            style: TextStyle(fontSize: 10.5, height: 1.4, color: p.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _pil(AppPalette p, IconData ikon, String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(ikon, size: 12, color: p.statusInk(warna)),
          const SizedBox(width: 5),
          Text(
            teks,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: p.statusInk(warna),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------- materi

class _TabMateri extends StatelessWidget {
  const _TabMateri({
    required this.api,
    required this.token,
    required this.courseId,
  });

  final MoodleApiService api;
  final String token;
  final int courseId;

  Future<List<CourseSection>> _muat() =>
      api.getCourseContents(token: token, courseId: courseId);

  @override
  Widget build(BuildContext context) {
    return LmsTabData<List<CourseSection>>(
      muat: _muat,
      bangun: (p, data, segarkan) {
        // Tugas/kuis/forum sudah punya tabnya sendiri — jangan dobel di sini.
        // Section yang jadi kosong gara-gara itu ikut dibuang, kecuali masih
        // ada ringkasan teks.
        final bagian = data
            .map((s) => s.tanpaJenis(kJenisPunyaTabSendiri))
            .where(
              (s) => !s.kosong || bersihkanHtml(s.ringkasan).isNotEmpty,
            )
            .toList(growable: false);

        if (bagian.isEmpty) {
          return RefreshIndicator(
            onRefresh: segarkan,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const <Widget>[
                LmsStatus(
                  ikon: Icons.folder_off_outlined,
                  teks: 'Belum ada materi yang diunggah di kelas ini.',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: segarkan,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: bagian.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _kartu(p, bagian[i]),
          ),
        );
      },
    );
  }

  Widget _kartu(AppPalette p, CourseSection bagian) {
    final ringkasan = bersihkanHtml(bagian.ringkasan);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: p.cardDeco(radius: 14, borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            color: p.surfaceAlt,
            child: Row(
              children: <Widget>[
                Icon(Icons.topic_outlined, size: 17, color: p.accentInk),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    bagian.nama.isEmpty ? 'Topik' : bagian.nama,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (ringkasan.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 2),
              child: Text(
                ringkasan,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: p.textSecondary,
                ),
              ),
            ),
          for (var i = 0; i < bagian.modules.length; i++) ...[
            if (i > 0) Divider(height: 1, color: p.divider),
            _barisModul(p, bagian.modules[i]),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _barisModul(AppPalette p, CourseModule modul) {
    final deskripsi = bersihkanHtml(modul.deskripsi);
    final bisaDibuka = modul.url.isNotEmpty;

    return InkWell(
      onTap: bisaDibuka ? () => bukaDiLuar(modul.url) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  ikonModul(modul.jenis),
                  size: 17,
                  color: _warnaModul(p, modul.jenis),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    modul.nama,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: p.textPrimary,
                    ),
                  ),
                ),
                if (bisaDibuka)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.open_in_new,
                      size: 13,
                      color: p.textMuted,
                    ),
                  ),
              ],
            ),
            if (deskripsi.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 26, top: 3),
                child: Text(
                  deskripsi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: p.textCardSupport,
                  ),
                ),
              ),
            for (final berkas in modul.berkas)
              Padding(
                padding: const EdgeInsets.only(left: 26, top: 6),
                child: InkWell(
                  onTap: () => bukaDiLuar(api.withToken(berkas.url, token)),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        berkas.pdf
                            ? Icons.picture_as_pdf_outlined
                            : Icons.attach_file,
                        size: 14,
                        color: p.accentInk,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          berkas.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: p.accentInk,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      if (berkas.ukuran > 0)
                        Text(
                          ukuranBerkas(berkas.ukuran),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: p.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _warnaModul(AppPalette p, String jenis) {
    switch (jenis) {
      case 'assign':
        return p.warning;
      case 'forum':
        return p.success;
      case 'quiz':
        return p.danger;
      default:
        return p.accentInk;
    }
  }
}