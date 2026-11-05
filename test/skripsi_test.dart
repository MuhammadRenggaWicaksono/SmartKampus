import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/akademik/skripsi_screen.dart';
import 'package:app_kampus/akademik/tambah_judul_skripsi_screen.dart';
import 'package:app_kampus/data/skripsi_store.dart';
import 'package:app_kampus/screens/akademik_screen.dart';
import 'package:app_kampus/theme_notifier.dart';

void _pasangLayar(WidgetTester tester, {double tinggi = 2400}) {
  tester.view.physicalSize = Size(1080, tinggi);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  // Store bersifat statis — kembalikan ke kondisi awal tiap test.
  final List<PengajuanSkripsi> awal = SkripsiStore.pengajuan.value;
  tearDown(() {
    SkripsiStore.pengajuan.value = awal;
    appThemeNotifier.value = AppThemeMode.light;
  });

  group('SkripsiStore', () {
    test('data awal berisi 1 pengajuan berstatus menunggu', () {
      expect(SkripsiStore.pengajuan.value.length, 1);
      final item = SkripsiStore.terakhir!;
      expect(item.status, StatusSkripsi.menunggu);
      expect(item.status.label, 'Menunggu Verifikasi');
    });

    test('tambah() menaruh pengajuan baru di urutan paling atas', () {
      final baru = PengajuanSkripsi(
        judul: 'Sistem Rekomendasi Mata Kuliah Pilihan',
        berkas1: 'https://contoh.test/berkas',
        berkas2: '-',
        berkas3: '-',
        diajukan: DateTime(2026, 11, 5),
      );
      SkripsiStore.tambah(baru);

      expect(SkripsiStore.pengajuan.value.length, 2);
      expect(SkripsiStore.pengajuan.value.first.judul, baru.judul);
      expect(SkripsiStore.terakhir!.judul, baru.judul);
    });

    test('jumlahBerkasNyata mengabaikan "-" dan string kosong', () {
      final item = PengajuanSkripsi(
        judul: 'Contoh Judul Skripsi Yang Cukup Panjang',
        berkas1: 'https://a.test/1',
        berkas2: '-',
        berkas3: '',
        diajukan: _tanggalTetap,
      );
      expect(item.jumlahBerkasNyata, 1);
      expect(item.daftarBerkas.length, 3);
    });

    test('formatTanggalSingkat menghasilkan format Indonesia', () {
      expect(formatTanggalSingkat(DateTime(2026, 10, 28)), '28 Okt 2026');
      expect(formatTanggalSingkat(DateTime(2026, 1, 5)), '05 Jan 2026');
      expect(formatTanggalSingkat(DateTime(2027, 12, 31)), '31 Des 2027');
    });

    test('tahapan skripsi punya tepat satu tahap berjalan', () {
      final berjalan = tahapanSkripsi
          .where((t) => t.status == StatusTahapan.berjalan)
          .length;
      expect(berjalan, 1);
      expect(tahapanSkripsi.first.status, StatusTahapan.berjalan);
      expect(pembimbingSkripsi.every((pp) => !pp.sudahDitetapkan), isTrue);
    });
  });

  group('AkademikScreen', () {
    testWidgets('menampilkan 3 kelompok menu beserta lencananya', (
      tester,
    ) async {
      // Layar tinggi supaya ketiga kelompok (di dalam ListView) ikut dibangun.
      _pasangLayar(tester, tinggi: 3600);
      await tester.pumpWidget(const MaterialApp(home: AkademikScreen()));
      await tester.pump();

      expect(find.text('Kartu Rencana Studi (KRS)'), findsOneWidget);
      expect(find.text('Hasil Studi & Nilai'), findsOneWidget);
      expect(find.text('Tugas Akhir & Praktik'), findsOneWidget);

      expect(find.text('Entri KRS'), findsOneWidget);
      expect(find.text('Lihat KRS'), findsOneWidget);
      expect(find.text('Lihat KHS'), findsOneWidget);
      expect(find.text('Rekap Nilai'), findsOneWidget);
      expect(find.text('Kerja Praktik (KP)'), findsOneWidget);
      expect(find.text('KKN'), findsOneWidget);
      expect(find.text('Skripsi'), findsOneWidget);

      // lencana status ikut tampil
      expect(find.text('23 SKS'), findsOneWidget);
      expect(find.text('IPS 3.68'), findsOneWidget);
      expect(find.text('116/144'), findsOneWidget);
      expect(find.text('1 judul diajukan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Kerja Praktik memunculkan notifikasi belum tersedia', (
      tester,
    ) async {
      _pasangLayar(tester, tinggi: 3600);
      await tester.pumpWidget(const MaterialApp(home: AkademikScreen()));
      await tester.pump();

      final kp = find.text('Kerja Praktik (KP)');
      await tester.ensureVisible(kp);
      await tester.pump();
      await tester.tap(kp);
      await tester.pump();

      expect(
        find.text('Menu Kerja Praktik belum tersedia'),
        findsOneWidget,
      );
    });

    testWidgets('menu Skripsi membuka halaman Skripsi', (tester) async {
      _pasangLayar(tester, tinggi: 3600);
      await tester.pumpWidget(const MaterialApp(home: AkademikScreen()));
      await tester.pump();

      final skripsi = find.text('Skripsi');
      await tester.ensureVisible(skripsi);
      await tester.pump();
      await tester.tap(skripsi);
      await tester.pumpAndSettle();

      expect(find.byType(SkripsiScreen), findsOneWidget);
      expect(find.text('Tahap 1 dari 6'), findsOneWidget);
    });
  });

  group('SkripsiScreen', () {
    testWidgets('menampilkan tahapan, pembimbing, dan daftar pengajuan', (
      tester,
    ) async {
      _pasangLayar(tester, tinggi: 4200);
      await tester.pumpWidget(const MaterialApp(home: SkripsiScreen()));
      await tester.pump();

      // 'Pengajuan Judul' muncul di kartu tahap DAN di daftar alur
      expect(find.text('Pengajuan Judul'), findsNWidgets(2));
      expect(find.text('Sidang Skripsi'), findsOneWidget);
      expect(find.text('Pembimbing 1'), findsOneWidget);
      expect(find.text('Belum ditetapkan'), findsNWidgets(2));
      expect(find.text('Menunggu Verifikasi'), findsOneWidget);
      expect(find.text('2 dari 3 berkas terisi'), findsOneWidget);
      expect(find.text('Tidak ada berkas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tombol tambah membuka form dan menambah pengajuan', (
      tester,
    ) async {
      _pasangLayar(tester, tinggi: 4200);
      await tester.pumpWidget(const MaterialApp(home: SkripsiScreen()));
      await tester.pump();

      await tester.tap(find.text('Tambah Judul Skripsi'));
      await tester.pumpAndSettle();

      expect(find.byType(TambahJudulSkripsiScreen), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Deteksi Kantuk Pengemudi Menggunakan CNN',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'https://drive.google.com/file/d/contoh/view',
      );
      await tester.pump();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.byType(TambahJudulSkripsiScreen), findsNothing);
      expect(SkripsiStore.pengajuan.value.length, 2);

      final baru = SkripsiStore.pengajuan.value.first;
      expect(baru.judul, 'Deteksi Kantuk Pengemudi Menggunakan CNN');
      // berkas 2 & 3 yang dikosongkan otomatis diisi "-"
      expect(baru.berkas2, '-');
      expect(baru.berkas3, '-');
      expect(baru.jumlahBerkasNyata, 1);
      expect(baru.tanggalDiajukan, formatTanggalSingkat(DateTime.now()));

      expect(find.text('Judul skripsi berhasil diajukan.'), findsOneWidget);
    });
  });

  group('TambahJudulSkripsiScreen', () {
    Future<void> buka(WidgetTester tester) async {
      _pasangLayar(tester, tinggi: 3000);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TambahJudulSkripsiScreen(),
                    ),
                  ),
                  child: const Text('buka'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
    }

    testWidgets('menampilkan pesan aturan dan keempat kolom isian', (
      tester,
    ) async {
      await buka(tester);

      expect(find.text('TAMBAH JUDUL SKRIPSI'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(
        find.text(
          'Mohon melengkapi isian link berkas, minimal 1 pengisian.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Jika link berkas 2 dan 3 tidak ada mohon isi dengan karakter "-" / minus.',
        ),
        findsOneWidget,
      );
      expect(find.text('Judul Skripsi'), findsOneWidget);
      expect(find.text('Link Berkas 1'), findsOneWidget);
      expect(find.text('Link Berkas 2'), findsOneWidget);
      expect(find.text('Link Berkas 3'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Simpan'), findsOneWidget);
      expect(find.text('Wajib'), findsNWidgets(2));
      expect(find.text('Opsional'), findsNWidgets(2));
    });

    testWidgets('menolak simpan kalau judul dan berkas 1 kosong', (
      tester,
    ) async {
      await buka(tester);

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Judul skripsi wajib diisi.'), findsOneWidget);
      expect(find.text('Minimal Link Berkas 1 wajib diisi.'), findsOneWidget);
      expect(SkripsiStore.pengajuan.value.length, 1);
      // halaman form tetap terbuka
      expect(find.byType(TambahJudulSkripsiScreen), findsOneWidget);
    });

    testWidgets('menolak Link Berkas 1 yang diisi "-"', (tester) async {
      await buka(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Sistem Informasi Geografis Kebun Raya',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '-');
      await tester.pump();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text("Link Berkas 1 tidak boleh '-'."), findsOneWidget);
      expect(SkripsiStore.pengajuan.value.length, 1);
    });

    testWidgets('menolak judul yang terlalu pendek', (tester) async {
      await buka(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Skripsi');
      await tester.pump();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Judul minimal 10 karakter.'), findsOneWidget);
    });

    testWidgets('menolak berkas 2 yang bukan tautan dan bukan "-"', (
      tester,
    ) async {
      await buka(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Analisis Sentimen Ulasan Aplikasi Kampus',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'https://a.test/1',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'tidak ada');
      await tester.pump();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(
        find.text('Masukkan tautan yang valid, atau isi dengan "-".'),
        findsOneWidget,
      );
      expect(SkripsiStore.pengajuan.value.length, 1);
    });

    testWidgets('menyimpan 3 berkas kalau semuanya diisi', (tester) async {
      await buka(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Implementasi Blockchain untuk Ijazah Digital',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'https://a.test/1',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'https://a.test/2',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'https://a.test/3',
      );
      await tester.pump();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      final baru = SkripsiStore.pengajuan.value.first;
      expect(baru.jumlahBerkasNyata, 3);
      expect(baru.berkas3, 'https://a.test/3');
    });
  });
}

final DateTime _tanggalTetap = DateTime(2026, 11, 5);
