import 'package:flutter/material.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/konten_layar.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/lms/models/course_group.dart';
import 'package:app_kampus/lms/models/moodle_course.dart';
import 'package:app_kampus/lms/providers/lms_session.dart';
import 'package:app_kampus/lms/screens/lms_course_screen.dart';
import 'package:app_kampus/lms/services/moodle_api_service.dart';
import 'package:app_kampus/lms/widgets/lms_support.dart';

/// Beranda LMS: daftar kelas (mata kuliah) dalam bentuk kartu ala
/// Google Classroom.
class LmsHomeScreen extends StatefulWidget {
  const LmsHomeScreen({super.key});

  @override
  State<LmsHomeScreen> createState() => _LmsHomeScreenState();
}

class _LmsHomeScreenState extends State<LmsHomeScreen> {
  final MoodleApiService _api = MoodleApiService();

  List<MoodleCourse>? _courses;
  String? _error;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final token = lmsSession.token;
    final user = lmsSession.user;
    if (token == null || user == null) {
      setState(() {
        _memuat = false;
        _error = 'Sesi tidak ditemukan. Silakan login ulang.';
      });
      return;
    }

    setState(() {
      _memuat = true;
      _error = null;
    });

    try {
      final courses = await _api.getUserCourses(
        token: token,
        userId: user.userId,
      );
      if (mounted) {
        setState(() {
          _courses = courses;
          _memuat = false;
        });
      }
    } on MoodleException catch (e) {
      if (mounted) setState(() { _error = e.message; _memuat = false; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat daftar kelas. Cek koneksi.';
          _memuat = false;
        });
      }
    }
  }

  Future<void> _keluar() async {
    await lmsSession.keluar();
    // Layar gerbang otomatis kembali ke halaman login.
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Kelas Saya',
                style: TextStyle(color: p.textPrimary, fontSize: 18),
              ),
              backgroundColor: p.card,
              foregroundColor: p.textPrimary,
              iconTheme: IconThemeData(color: p.textPrimary),
              elevation: 0.5,
              actions: [
                IconButton(
                  tooltip: 'Muat ulang',
                  onPressed: _memuat ? null : _muat,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: 'Keluar',
                  onPressed: _keluar,
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: KontenLayar(
              paddingHp: EdgeInsets.zero,
              paddingLebar: EdgeInsets.zero,
              child: _isi(p),
            ),
          ),
        );
      },
    );
  }

  Widget _sapaan(AppPalette p) {
    final user = lmsSession.user;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: p.accent.withValues(alpha: 0.15),
          child: Text(
            user?.inisial ?? '?',
            style: TextStyle(
              color: p.accentInk,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${user?.fullName ?? 'Mahasiswa'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: p.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.siteName ?? 'LMS Lentera Universitas Mulia',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: p.textCardSupport),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Isi halaman: memuat → error → kosong → TabBar per semester.
  Widget _isi(AppPalette p) {
    if (_memuat) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sapaan(p),
          const SizedBox(height: 18),
          _statusBox(p, ikon: null, teks: 'Memuat daftar kelas...'),
        ],
      );
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sapaan(p),
          const SizedBox(height: 18),
          _errorBox(p),
        ],
      );
    }

    final courses = _courses ?? const <MoodleCourse>[];
    if (courses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _muat,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _sapaan(p),
            const SizedBox(height: 18),
            _statusBox(
              p,
              ikon: Icons.school_outlined,
              teks: 'Belum ada kelas yang terdaftar di Moodle.',
            ),
          ],
        ),
      );
    }

    final grup = groupCoursesBySemester(courses);
    return DefaultTabController(
      // Kunci ikut jumlah tab supaya controller direset kalau jumlahnya
      // berubah setelah muat ulang.
      key: ValueKey<int>(grup.length),
      length: grup.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: _sapaan(p),
          ),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: p.accentInk,
            unselectedLabelColor: p.textCardSupport,
            indicatorColor: p.accent,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              for (final g in grup) Tab(text: '${g.label} (${g.courses.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [for (final g in grup) _gridKelas(p, g.courses)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridKelas(AppPalette p, List<MoodleCourse> courses) {
    return RefreshIndicator(
      onRefresh: _muat,
      child: LayoutBuilder(
        builder: (context, c) {
          final kolom = c.maxWidth >= 720 ? 2 : 1;
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: courses.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: kolom,
              mainAxisExtent: 156,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (_, i) => _kartuKelas(p, courses[i]),
          );
        },
      ),
    );
  }

  Widget _kartuKelas(AppPalette p, MoodleCourse mk) {
    final warna = warnaKelas(mk.id);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LmsCourseScreen(course: mk),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: p.cardDeco(radius: 16, borderColor: p.border),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56,
              color: warna,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      mk.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mk.shortName,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progres',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: p.textCardSupport,
                          ),
                        ),
                        Text(
                          '${mk.progress.round()}%',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: p.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: (mk.progress / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: p.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation<Color>(warna),
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

  Widget _statusBox(AppPalette p, {required IconData? ikon, required String teks}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: p.cardDeco(radius: 16),
      child: Column(
        children: [
          if (ikon == null)
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            )
          else
            Icon(ikon, size: 40, color: p.textMuted),
          const SizedBox(height: 14),
          Text(
            teks,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: p.textCardSupport),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(AppPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: p.cardDeco(radius: 16),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 40, color: p.danger),
          const SizedBox(height: 14),
          Text(
            _error ?? 'Terjadi kesalahan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: p.textCardSupport),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _muat,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
