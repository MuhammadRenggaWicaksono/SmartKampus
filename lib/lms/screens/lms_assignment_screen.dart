import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/konten_layar.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/lms/models/moodle_pengumpulan.dart';
import 'package:app_kampus/lms/models/moodle_tugas.dart';
import 'package:app_kampus/lms/moodle_format.dart';
import 'package:app_kampus/lms/providers/lms_session.dart';
import 'package:app_kampus/lms/services/moodle_api_service.dart';
import 'package:app_kampus/lms/widgets/lms_support.dart';

/// Detail satu tugas + pengumpulan berkas (Tahap 3).
///
/// Alur yang aktif: pilih berkas → unggah ke `webservice/upload.php` → simpan
/// sebagai **draf** lewat `mod_assign_save_submission`.
///
/// Yang sengaja belum aktif: `mod_assign_submit_for_grading` (mengirim tugas
/// untuk dinilai). Tombolnya ada, tapi terkunci di balik [kKirimTugasAktif]
/// yang masih `false` — jadi tidak ada tugas yang benar-benar terkirim.
class LmsAssignmentScreen extends StatefulWidget {
  const LmsAssignmentScreen({
    super.key,
    required this.tugas,
    required this.namaKelas,
  });

  final Assignment tugas;
  final String namaKelas;

  @override
  State<LmsAssignmentScreen> createState() => _LmsAssignmentScreenState();
}

class _LmsAssignmentScreenState extends State<LmsAssignmentScreen> {
  final MoodleApiService _api = MoodleApiService();

  MoodleSubmission _pengumpulan = MoodleSubmission.kosong;
  bool _memuat = true;
  String? _galat;

  /// Berkas yang baru dipilih, belum diunggah.
  final List<PlatformFile> _pilihan = <PlatformFile>[];

  bool _sibuk = false;

  String get _token => lmsSession.token ?? '';

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _memuat = true;
      _galat = null;
    });
    try {
      final status = await _api.getSubmissionStatus(
        token: _token,
        assignmentId: widget.tugas.id,
      );
      if (!mounted) return;
      setState(() {
        _pengumpulan = status;
        _memuat = false;
      });
    } on MoodleException catch (e) {
      if (!mounted) return;
      setState(() {
        _galat = e.message;
        _memuat = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _galat = 'Gagal memuat status pengumpulan. Cek koneksi lalu coba lagi.';
        _memuat = false;
      });
    }
  }

  Future<void> _pilihBerkas() async {
    try {
      final hasil = await FilePicker.pickFiles(
        allowMultiple: true,
        withReadStream: false,
      );
      if (hasil == null || !mounted) return;
      setState(() {
        for (final f in hasil.files) {
          if (f.path == null) continue;
          final sudahAda = _pilihan.any(
            (x) => x.path == f.path && x.name == f.name,
          );
          if (!sudahAda) _pilihan.add(f);
        }
      });
    } catch (_) {
      _pesan('Tidak bisa membuka pemilih berkas di perangkat ini.');
    }
  }

  /// Unggah semua berkas terpilih ke satu area draf yang sama, lalu simpan
  /// sebagai pengumpulan draf. Tidak ada pengiriman untuk dinilai di sini.
  Future<void> _simpanDraf() async {
    if (_pilihan.isEmpty) {
      _pesan('Pilih berkas dulu sebelum menyimpan draf.');
      return;
    }
    setState(() => _sibuk = true);
    try {
      var itemId = 0;
      for (final berkas in _pilihan) {
        final unggah = await _api.uploadFile(
          token: _token,
          path: berkas.path!,
          itemId: itemId,
          namaBerkas: berkas.name,
        );
        itemId = unggah.itemId;
      }

      await _api.saveSubmission(
        token: _token,
        assignmentId: widget.tugas.id,
        itemId: itemId,
      );

      if (!mounted) return;
      setState(() => _pilihan.clear());
      _pesan('Draf tersimpan di Moodle. Tugas belum dikirim untuk dinilai.');
      await _muat();
    } on MoodleException catch (e) {
      _pesan(e.message);
    } catch (_) {
      _pesan('Gagal menyimpan draf. Coba lagi.');
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  Future<void> _kumpulkan() async {
    if (!kKirimTugasAktif) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pengiriman belum diaktifkan'),
          content: const Text(
            'Tahap 3 baru sampai menyimpan draf. Berkas yang sudah diunggah '
            'aman tersimpan di Moodle, tapi tugas belum dikirim untuk dinilai.\n\n'
            'Aktifkan kKirimTugasAktif di moodle_api_service.dart kalau ingin '
            'mengaktifkan mod_assign_submit_for_grading.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      return;
    }

    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kumpulkan tugas?'),
        content: const Text(
          'Setelah dikumpulkan, tugas dikirim untuk dinilai dan tidak bisa '
          'ditarik kembali.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Kumpulkan'),
          ),
        ],
      ),
    );
    if (setuju != true) return;

    setState(() => _sibuk = true);
    try {
      await _api.submitForGrading(
        token: _token,
        assignmentId: widget.tugas.id,
      );
      _pesan('Tugas dikumpulkan.');
      await _muat();
    } on MoodleException catch (e) {
      _pesan(e.message);
    } catch (_) {
      _pesan('Gagal mengumpulkan tugas.');
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(teks), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tugas = widget.tugas;

    return ThemeBuilder(
      builder: (context, p) {
        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Detail Tugas',
                style: TextStyle(color: p.textPrimary, fontSize: 18),
              ),
              backgroundColor: p.card,
              foregroundColor: p.textPrimary,
              iconTheme: IconThemeData(color: p.textPrimary),
              elevation: 0.5,
              actions: <Widget>[
                IconButton(
                  onPressed: _memuat ? null : _muat,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Muat ulang',
                ),
              ],
            ),
            body: KontenLayar(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: <Widget>[
                  _kepala(p, tugas),
                  const SizedBox(height: 14),
                  _kartuStatus(p),
                  const SizedBox(height: 14),
                  _kartuBerkas(p),
                  const SizedBox(height: 18),
                  _aksi(p),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _kepala(AppPalette p, Assignment tugas) {
    final intro = bersihkanHtml(tugas.intro);
    final sisa = sisaHari(tugas.tenggat);

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: p.cardDeco(radius: 16, borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.namaKelas,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: p.accentInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tugas.nama,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _pilInfo(
                p,
                Icons.schedule,
                tugas.tenggat == null
                    ? 'Tanpa tenggat'
                    : tanggalJamMoodle(tugas.tenggat),
                tugas.tenggat == null ? p.textCardSupport : p.warning,
              ),
              if (sisa != null)
                _pilInfo(
                  p,
                  Icons.timelapse,
                  sisa < 0 ? 'Terlambat ${-sisa} hari' : '$sisa hari lagi',
                  sisa < 0 ? p.danger : p.success,
                ),
              if (tugas.nilaiMaks > 0)
                _pilInfo(
                  p,
                  Icons.grade_outlined,
                  'Maks ${tugas.nilaiMaks.toStringAsFixed(0)}',
                  p.accentInk,
                ),
            ],
          ),
          if (intro.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: p.divider),
            const SizedBox(height: 12),
            Text(
              intro,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: p.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pilInfo(AppPalette p, IconData ikon, String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(ikon, size: 13, color: p.statusInk(warna)),
          const SizedBox(width: 5),
          Text(
            teks,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: p.statusInk(warna),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuStatus(AppPalette p) {
    final sub = _pengumpulan;
    final warna = sub.sudahDinilai
        ? p.accentInk
        : sub.sudahDikumpul
        ? p.success
        : sub.masihDraf
        ? p.warning
        : p.textCardSupport;

    return _kartu(
      p,
      judul: 'Status pengumpulan',
      anak: <Widget>[
        if (_memuat)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          )
        else if (_galat != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _galat!,
                style: TextStyle(fontSize: 13, color: p.textCardSupport),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _muat,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba lagi'),
              ),
            ],
          )
        else ...<Widget>[
          Row(
            children: <Widget>[
              Icon(
                sub.sudahDikumpul
                    ? Icons.check_circle_outline
                    : sub.masihDraf
                    ? Icons.edit_note
                    : Icons.radio_button_unchecked,
                size: 17,
                color: warna,
              ),
              const SizedBox(width: 8),
              Text(
                sub.labelStatus,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: p.statusInk(warna),
                ),
              ),
              if (sub.nilai != null) ...[
                const Spacer(),
                Text(
                  'Nilai ${sub.nilai!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.accentInk,
                  ),
                ),
              ],
            ],
          ),
          if (sub.diubahPada != null) ...[
            const SizedBox(height: 6),
            Text(
              'Terakhir diubah ${tanggalJamMoodle(sub.diubahPada)}',
              style: TextStyle(fontSize: 11.5, color: p.textCardSupport),
            ),
          ],
          if (!sub.dapatDiubah && !_memuat) ...[
            const SizedBox(height: 8),
            Text(
              'Pengumpulan sudah ditutup, berkas tidak bisa diubah lagi.',
              style: TextStyle(fontSize: 11.5, color: p.danger),
            ),
          ],
          if (sub.berkas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: p.divider),
            const SizedBox(height: 10),
            Text(
              'Berkas di Moodle',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: p.textCardSupport,
              ),
            ),
            const SizedBox(height: 8),
            for (final berkas in sub.berkas) _barisBerkasMoodle(p, berkas),
          ],
        ],
      ],
    );
  }

  Widget _barisBerkasMoodle(AppPalette p, SubmissionFile berkas) {
    return InkWell(
      onTap: () => bukaDiLuar(_api.withToken(berkas.url, _token)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: <Widget>[
            Icon(Icons.insert_drive_file_outlined, size: 15, color: p.accentInk),
            const SizedBox(width: 8),
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
                style: TextStyle(fontSize: 10.5, color: p.textMuted),
              ),
          ],
        ),
      ),
    );
  }

  Widget _kartuBerkas(AppPalette p) {
    final bolehUbah = _pengumpulan.dapatDiubah && !_memuat && _galat == null;
    return _kartu(
      p,
      judul: 'Berkas yang akan diunggah',
      aksiJudul: TextButton.icon(
        onPressed: bolehUbah && !_sibuk ? _pilihBerkas : null,
        icon: const Icon(Icons.attach_file, size: 17),
        label: const Text('Pilih berkas'),
      ),
      anak: <Widget>[
        if (_pilihan.isEmpty)
          Text(
            'Belum ada berkas dipilih. Tugas ini menerima unggahan berkas.',
            style: TextStyle(fontSize: 12.5, color: p.textCardSupport),
          )
        else
          for (var i = 0; i < _pilihan.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    _ikonBerkas(_pilihan[i].name),
                    size: 16,
                    color: p.accentInk,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _pilihan[i].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: p.textPrimary),
                    ),
                  ),
                  Text(
                    ukuranBerkas(_pilihan[i].size),
                    style: TextStyle(fontSize: 10.5, color: p.textMuted),
                  ),
                  if (bolehUbah && !_sibuk)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      onPressed: () =>
                          setState(() => _pilihan.removeAt(i)),
                      icon: Icon(Icons.close, size: 15, color: p.danger),
                      tooltip: 'Buang',
                    ),
                ],
              ),
            ),
        const SizedBox(height: 12),
        Text(
          'Berkas diunggah ke area draf Moodle, lalu disimpan sebagai '
          'pengumpulan draf — belum terkirim untuk dinilai.',
          style: TextStyle(fontSize: 11, height: 1.4, color: p.textMuted),
        ),
      ],
    );
  }

  Widget _aksi(AppPalette p) {
    final bolehUbah = _pengumpulan.dapatDiubah && !_memuat && _galat == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton.icon(
          onPressed: bolehUbah && !_sibuk && _pilihan.isNotEmpty
              ? _simpanDraf
              : null,
          icon: _sibuk
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_sibuk ? 'Mengunggah...' : 'Simpan draf'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _sibuk ? null : _kumpulkan,
          icon: Icon(
            kKirimTugasAktif ? Icons.send_outlined : Icons.lock_outline,
            size: 18,
          ),
          label: const Text('Kumpulkan untuk dinilai'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: kKirimTugasAktif ? p.accentInk : p.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _kartu(
    AppPalette p, {
    required String judul,
    required List<Widget> anak,
    Widget? aksiJudul,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
      decoration: p.cardDeco(radius: 16, borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  judul,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: p.textCardSupport,
                  ),
                ),
              ),
              ?aksiJudul,
            ],
          ),
          const SizedBox(height: 8),
          ...anak,
        ],
      ),
    );
  }

  IconData _ikonBerkas(String nama) {
    final rendah = nama.toLowerCase();
    if (rendah.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (rendah.endsWith('.doc') || rendah.endsWith('.docx')) {
      return Icons.description_outlined;
    }
    if (rendah.endsWith('.zip') ||
        rendah.endsWith('.rar') ||
        rendah.endsWith('.7z')) {
      return Icons.folder_zip_outlined;
    }
    if (rendah.endsWith('.jpg') ||
        rendah.endsWith('.jpeg') ||
        rendah.endsWith('.png')) {
      return Icons.image_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }
}