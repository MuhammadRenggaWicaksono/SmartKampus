import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/akademik/kp_screen.dart';
import 'package:app_kampus/akademik/tambah_kp_screen.dart';
import 'package:app_kampus/data/kp_store.dart';
import 'package:app_kampus/screens/akademik_screen.dart';
import 'package:app_kampus/theme_notifier.dart';

void _pasangLayar(WidgetTester tester, {double tinggi = 9000}) {
  tester.view.physicalSize = Size(1080, tinggi);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  // Store bersifat statis — kembalikan ke kondisi awal tiap test.
  final List<DataKp> daftarAwal = KpStore.daftar.value;
  final List<BimbinganKp> bimbinganAwal = KpStore.bimbingan.value;
  tearDown(() {
    KpStore.daftar.value = daftarAwal;
    KpStore.bimbingan.value = bimbinganAwal;
    appThemeNotifier.value = AppThemeMode.light;
  });

  group('PeriodeKp', () {
    test('menormalkan bulan di luar 1..12 ke tahun yang benar', () {
      expect(
        PeriodeKp.normalisasi(13, 2026),
        const PeriodeKp(bulan: 1, tahun: 2027),
      );
      expect(
        PeriodeKp.normalisasi(0, 2026),
        const PeriodeKp(bulan: 12, tahun: 2025),
      );
      expect(
        PeriodeKp.normalisasi(15, 2026),
        const PeriodeKp(bulan: 3, tahun: 2027),
      );
    });

    test('label panjang & singkat memakai nama bulan Indonesia', () {
      const p = PeriodeKp(bulan: 9, tahun: 2026);
      expect(p.label, 'September 2026');
      expect(p.labelSingkat, 'Sep 2026');
      expect(p.namaBulan, 'September');
    });

    test('geser() melewati batas tahun dengan benar', () {
      expect(
        const PeriodeKp(bulan: 11, tahun: 2026).geser(3),
        const PeriodeKp(bulan: 2, tahun: 2027),
      );
      expect(
        const PeriodeKp(bulan: 1, tahun: 2027).geser(-2),
        const PeriodeKp(bulan: 11, tahun: 2026),
      );
    });

    test('selisihBulanKe mengembalikan selisih inklusif', () {
      const awal = PeriodeKp(bulan: 9, tahun: 2026);
      const akhir = PeriodeKp(bulan: 12, tahun: 2026);
      expect(awal.selisihBulanKe(akhir), 3);
      expect(durasiBulanKp(awal, akhir), 4);
      expect(awal.selisihBulanKe(const PeriodeKp(bulan: 7, tahun: 2026)), -2);
    });

    test('durasiBulanKp mengembalikan 0 kalau akhir lebih awal', () {
      expect(
        durasiBulanKp(
          const PeriodeKp(bulan: 12, tahun: 2026),
          const PeriodeKp(bulan: 9, tahun: 2026),
        ),
        0,
      );
    });

    test('urutan periode bisa dibandingkan', () {
      const a = PeriodeKp(bulan: 9, tahun: 2026);
      const b = PeriodeKp(bulan: 1, tahun: 2027);
      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a <= a, isTrue);
      expect(b >= a, isTrue);
      expect(a.compareTo(b), lessThan(0));
    });

    test('dua periode sama dianggap setara', () {
      expect(
        const PeriodeKp(bulan: 9, tahun: 2026) ==
            const PeriodeKp(bulan: 9, tahun: 2026),
        isTrue,
      );
      expect(
        const PeriodeKp(bulan: 9, tahun: 2026) ==
            const PeriodeKp(bulan: 10, tahun: 2026),
        isFalse,
      );
    });
  });

  group('daftarTahunKp', () {
    test('mulai dari 2010 (sama dengan web kampus) sampai tahun+2', () {
      final tahun = daftarTahunKp(tahunSekarang: 2026);
      expect(tahun.first, 2010);
      expect(tahun.last, 2028);
      expect(tahun.contains(2026), isTrue);
      expect(tahun.length, 19);
    });

    test('tidak pernah berakhir sebelum 2010', () {
      final tahun = daftarTahunKp(tahunSekarang: 2005);
      expect(tahun.first, 2010);
      expect(tahun.last, 2010);
    });
  });

  group('DataKp', () {
    DataKp contoh({
      StatusKp status = StatusKp.berjalan,
      String pembimbingKampus = 'Dr. Andi Pratama, M.Kom.',
      Map<String, String> tautan = const <String, String>{},
    }) {
      return DataKp(
        id: 'kp-uji',
        instansi: 'PT Contoh Nusantara',
        judul: 'Sistem Informasi Monitoring Produksi',
        pembimbingLapangan: 'Budi Santoso, S.T.',
        pembimbingKampus: pembimbingKampus,
        awal: const PeriodeKp(bulan: 9, tahun: 2026),
        akhir: const PeriodeKp(bulan: 12, tahun: 2026),
        status: status,
        diajukan: DateTime(2026, 8, 12),
        tautan: tautan,
      );
    }

    test('menghitung durasi dan teks periode', () {
      final kp = contoh();
      expect(kp.durasiBulan, 4);
      expect(kp.periodeTeks, 'September 2026 – Desember 2026');
      expect(kp.periodeSingkat, 'Sep 2026 – Des 2026');
      expect(kp.tanggalDiajukan, '12 Agu 2026');
    });

    test('dokumen kosong dan "-" dianggap belum terisi', () {
      final kp = contoh(
        tautan: const <String, String>{
          'proposal': 'https://a.test/proposal',
          'surat-izin': '-',
          'laporan': '',
        },
      );
      expect(kp.dokumenTerisi('proposal'), isTrue);
      expect(kp.dokumenTerisi('surat-izin'), isFalse);
      expect(kp.dokumenTerisi('laporan'), isFalse);
      expect(kp.dokumenTerisi('penilaian'), isFalse);
      expect(kp.jumlahDokumenTerisi, 1);
      expect(kp.progresDokumen, closeTo(0.2, 0.0001));
    });

    test('keduaPembimbingLengkap butuh pembimbing kampus terisi', () {
      expect(contoh().keduaPembimbingLengkap, isTrue);
      expect(contoh(pembimbingKampus: '  ').keduaPembimbingLengkap, isFalse);
    });

    test('copyWith mengganti satu kolom tanpa menyentuh yang lain', () {
      final ubah = contoh().copyWith(status: StatusKp.selesai);
      expect(ubah.status, StatusKp.selesai);
      expect(ubah.instansi, 'PT Contoh Nusantara');
    });

    test('copyWith mempertahankan tanggal pengajuan asli', () {
      final ubah = contoh().copyWith(catatan: 'catatan baru');
      expect(ubah.diajukan, DateTime(2026, 8, 12));
      expect(ubah.catatan, 'catatan baru');
    });
  });

  group('tahapanKpUntuk', () {
    test('tanpa data KP semua tahap belum dimulai', () {
      final tahapan = tahapanKpUntuk(null);
      expect(tahapan.length, 6);
      expect(tahapan.every((t) => t.status == StatusTahapanKp.belum), isTrue);
      expect(progresTahapanKp(tahapan), 0);
    });

    test('status menunggu: pengajuan selesai, verifikasi berjalan', () {
      final tahapan = tahapanKpUntuk(
        DataKp(
          id: 'k1',
          instansi: 'PT A',
          judul: 'Judul contoh kegiatan',
          pembimbingLapangan: 'Budi',
          awal: const PeriodeKp(bulan: 9, tahun: 2026),
          akhir: const PeriodeKp(bulan: 12, tahun: 2026),
          status: StatusKp.menunggu,
        ),
      );
      expect(tahapan.first.status, StatusTahapanKp.selesai);
      expect(tahapan[1].status, StatusTahapanKp.berjalan);
      expect(tahapan[1].nama, 'Verifikasi Program Studi');
    });

    test('status berjalan: lima tahap selesai, bimbingan berjalan', () {
      final tahapan = tahapanKpUntuk(
        DataKp(
          id: 'k1',
          instansi: 'PT A',
          judul: 'Judul contoh kegiatan',
          pembimbingLapangan: 'Budi',
          pembimbingKampus: 'Dr. Andi',
          awal: const PeriodeKp(bulan: 9, tahun: 2026),
          akhir: const PeriodeKp(bulan: 12, tahun: 2026),
          status: StatusKp.berjalan,
        ),
      );
      expect(tahapan[4].status, StatusTahapanKp.berjalan);
      expect(tahapan[4].nama, 'Bimbingan & Laporan');
      expect(progresTahapanKp(tahapan), closeTo(4.5 / 6, 0.0001));
    });

    test('status selesai: semua tahap selesai dan progres penuh', () {
      final tahapan = tahapanKpUntuk(
        DataKp(
          id: 'k1',
          instansi: 'PT A',
          judul: 'Judul contoh kegiatan',
          pembimbingLapangan: 'Budi',
          awal: const PeriodeKp(bulan: 9, tahun: 2026),
          akhir: const PeriodeKp(bulan: 12, tahun: 2026),
          status: StatusKp.selesai,
        ),
      );
      expect(tahapan.every((t) => t.status == StatusTahapanKp.selesai), isTrue);
      expect(progresTahapanKp(tahapan), 1.0);
    });

    test('status disetujui tanpa pembimbing kampus berhenti di penetapan', () {
      final belumLengkap = tahapanKpUntuk(
        DataKp(
          id: 'k1',
          instansi: 'PT A',
          judul: 'Judul contoh kegiatan',
          pembimbingLapangan: 'Budi',
          awal: const PeriodeKp(bulan: 9, tahun: 2026),
          akhir: const PeriodeKp(bulan: 12, tahun: 2026),
          status: StatusKp.disetujui,
        ),
      );
      expect(belumLengkap[2].status, StatusTahapanKp.berjalan);
      expect(belumLengkap[3].status, StatusTahapanKp.belum);

      final lengkap = tahapanKpUntuk(
        DataKp(
          id: 'k1',
          instansi: 'PT A',
          judul: 'Judul contoh kegiatan',
          pembimbingLapangan: 'Budi',
          pembimbingKampus: 'Dr. Andi',
          awal: const PeriodeKp(bulan: 9, tahun: 2026),
          akhir: const PeriodeKp(bulan: 12, tahun: 2026),
          status: StatusKp.disetujui,
        ),
      );
      expect(lengkap[2].status, StatusTahapanKp.selesai);
      expect(lengkap[3].status, StatusTahapanKp.berjalan);
    });
  });

  group('KpStore', () {
    test('data awal berisi 1 KP berjalan beserta catatan bimbingan', () {
      expect(KpStore.jumlah, 1);
      expect(KpStore.aktif!.status, StatusKp.berjalan);
      expect(KpStore.aktif!.instansi, contains('Telkom'));
      expect(KpStore.bimbingan.value.length, 3);
      expect(KpStore.jumlahDokumenTerisi, 2);
    });

    test('tambah() menaruh data baru di paling atas', () {
      final baru = DataKp(
        id: 'kp-baru',
        instansi: 'Dinas Kominfo Balikpapan',
        judul: 'Digitalisasi Arsip Surat Menyurat',
        pembimbingLapangan: 'Siti Aminah, S.Kom.',
        awal: const PeriodeKp(bulan: 1, tahun: 2027),
        akhir: const PeriodeKp(bulan: 3, tahun: 2027),
      );
      KpStore.tambah(baru);

      expect(KpStore.jumlah, 2);
      expect(KpStore.aktif!.id, 'kp-baru');
      expect(KpStore.riwayat.length, 1);
    });

    test('perbarui() mengganti data tanpa mengubah urutan', () {
      final aktif = KpStore.aktif!;
      KpStore.perbarui(aktif.copyWith(instansi: 'PT Telkom — Balikpapan'));

      expect(KpStore.aktif!.instansi, 'PT Telkom — Balikpapan');
      expect(KpStore.jumlah, 1);
    });

    test('hapus() menghilangkan data dari daftar', () {
      KpStore.hapus(KpStore.aktif!.id);
      expect(KpStore.jumlah, 0);
      expect(KpStore.aktif, isNull);
      expect(KpStore.jumlahDokumenTerisi, 0);
    });

    test('simpanTautan() mengisi, mengganti, dan mengosongkan dokumen', () {
      final id = KpStore.aktif!.id;
      KpStore.simpanTautan(id, 'lembar-bimbingan', 'https://a.test/lb');
      expect(KpStore.aktif!.dokumenTerisi('lembar-bimbingan'), isTrue);
      expect(KpStore.aktif!.jumlahDokumenTerisi, 3);

      KpStore.simpanTautan(id, 'lembar-bimbingan', '   ');
      expect(KpStore.aktif!.dokumenTerisi('lembar-bimbingan'), isFalse);
      expect(KpStore.aktif!.jumlahDokumenTerisi, 2);
    });

    test('jadikanAktif() memindahkan data lama ke paling atas', () {
      final lama = KpStore.aktif!;
      KpStore.tambah(
        DataKp(
          id: 'kp-dua',
          instansi: 'PT Kedua',
          judul: 'Judul kegiatan kedua',
          pembimbingLapangan: 'Ani',
          awal: const PeriodeKp(bulan: 2, tahun: 2027),
          akhir: const PeriodeKp(bulan: 4, tahun: 2027),
        ),
      );
      expect(KpStore.aktif!.id, 'kp-dua');

      KpStore.jadikanAktif(lama.id);
      expect(KpStore.aktif!.id, lama.id);
      expect(KpStore.jumlah, 2);
    });

    test('cari() mengembalikan null untuk id yang tidak ada', () {
      expect(KpStore.cari('tidak-ada'), isNull);
    });

    test('bimbingan bisa ditambah dan dihapus berdasarkan urutan', () {
      final awal = KpStore.bimbingan.value.length;
      KpStore.tambahBimbingan(
        BimbinganKp(tanggal: DateTime(2026, 11, 20), topik: 'Bab 5'),
      );
      expect(KpStore.bimbingan.value.first.topik, 'Bab 5');

      KpStore.hapusBimbingan(0);
      expect(KpStore.bimbingan.value.length, awal);
      expect(KpStore.bimbingan.value.first.topik, isNot('Bab 5'));
    });
  });

  group('AkademikScreen', () {
    testWidgets('lencana KP mengikuti status data aktif', (tester) async {
      _pasangLayar(tester, tinggi: 3600);
      await tester.pumpWidget(const MaterialApp(home: AkademikScreen()));
      await tester.pump();

      expect(find.text('Kerja Praktik (KP)'), findsOneWidget);
      expect(find.text('Berjalan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('menu Kerja Praktik membuka halaman KP', (tester) async {
      _pasangLayar(tester, tinggi: 3600);
      await tester.pumpWidget(const MaterialApp(home: AkademikScreen()));
      await tester.pump();

      final kp = find.text('Kerja Praktik (KP)');
      await tester.ensureVisible(kp);
      await tester.pump();
      await tester.tap(kp);
      await tester.pumpAndSettle();

      expect(find.byType(KpScreen), findsOneWidget);
      expect(find.text('ALUR KERJA PRAKTIK'), findsOneWidget);
    });
  });

  group('KpScreen', () {
    testWidgets('menampilkan hero, alur, data KP, dokumen, dan bimbingan', (
      tester,
    ) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: KpScreen()));
      await tester.pump();

      expect(find.text('Tahap 5 dari 6'), findsOneWidget);
      expect(find.text('ALUR KERJA PRAKTIK'), findsOneWidget);
      expect(find.text('DATA KP'), findsOneWidget);
      expect(find.text('DOKUMEN'), findsOneWidget);
      expect(
        find.text('${KpStore.jumlahDokumenTerisi}/${dokumenKp.length}'),
        findsNWidgets(2),
      );
      expect(find.text('CATATAN BIMBINGAN'), findsOneWidget);
      expect(find.text('3x'), findsOneWidget);
      expect(find.text('Budi Santoso, S.T.'), findsOneWidget);
      expect(find.text('Dr. Andi Pratama, M.Kom.'), findsOneWidget);
      expect(
        find.textContaining('September 2026 – Desember 2026'),
        findsWidgets,
      );
      expect(find.text('Tambah Data KP'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tombol tambah membuka form DATA KP lalu menyimpan', (
      tester,
    ) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: KpScreen()));
      await tester.pump();

      await tester.tap(find.text('Tambah Data KP'));
      await tester.pumpAndSettle();

      expect(find.byType(TambahKpScreen), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Perumda Tirta Manuntung',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Sistem Monitoring Debit Air Berbasis IoT',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Hendra Wijaya, S.T.',
      );
      await tester.pump();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.byType(TambahKpScreen), findsNothing);
      expect(KpStore.jumlah, 2);

      final baru = KpStore.aktif!;
      expect(baru.instansi, 'Perumda Tirta Manuntung');
      expect(baru.judul, 'Sistem Monitoring Debit Air Berbasis IoT');
      expect(baru.pembimbingLapangan, 'Hendra Wijaya, S.T.');
      expect(baru.status, StatusKp.menunggu);
      expect(baru.awal, periodeAwalBawaan());
      expect(baru.akhir, periodeAkhirBawaan());

      expect(find.text('Data KP berhasil disimpan.'), findsOneWidget);
    });

    testWidgets('data KP bisa diubah lewat menu opsi', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: KpScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ubah data KP'));
      await tester.pumpAndSettle();

      expect(find.byType(TambahKpScreen), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'PT Telkom Indonesia — Balikpapan',
      );
      await tester.pump();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(KpStore.jumlah, 1);
      expect(KpStore.aktif!.instansi, 'PT Telkom Indonesia — Balikpapan');
      expect(find.text('Data KP berhasil diperbarui.'), findsOneWidget);
    });

    testWidgets('status bisa diubah dari menu opsi', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: KpScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Status: Selesai'));
      await tester.pumpAndSettle();

      expect(KpStore.aktif!.status, StatusKp.selesai);
      expect(find.text('Status KP: Selesai.'), findsOneWidget);
    });

    testWidgets('hapus data KP minta konfirmasi dulu', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: KpScreen()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus data KP'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus data KP?'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(KpStore.jumlah, 1);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus data KP'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(KpStore.jumlah, 0);
      expect(find.text('Belum ada data KP'), findsWidgets);
    });

    testWidgets('sheet dokumen menyimpan tautan berkas', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: KpScreen()));
      await tester.pump();

      await tester.tap(find.text('Atur dokumen'));
      await tester.pumpAndSettle();

      expect(find.text('DOKUMEN KP'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(dokumenKp.length));

      await tester.enterText(
        find.byType(TextField).at(3),
        'https://a.test/laporan-akhir',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
      await tester.pumpAndSettle();

      expect(
        KpStore.aktif!.tautanDokumen('laporan'),
        'https://a.test/laporan-akhir',
      );
      expect(find.text('Dokumen KP diperbarui.'), findsOneWidget);
    });

    testWidgets('catatan bimbingan bisa ditambah dan dihapus', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: KpScreen()));
      await tester.pump();

      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();
      expect(find.text('Catatan Bimbingan'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField).at(0),
        'Bab 5 — kesimpulan',
      );
      await tester.pump();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(KpStore.bimbingan.value.first.topik, 'Bab 5 — kesimpulan');
      expect(find.text('Catatan bimbingan ditambahkan.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      expect(KpStore.bimbingan.value.first.topik, isNot('Bab 5 — kesimpulan'));
    });

    testWidgets('tanpa data KP halaman menampilkan keadaan kosong', (
      tester,
    ) async {
      KpStore.daftar.value = <DataKp>[];
      _pasangLayar(tester, tinggi: 9000);
      await tester.pumpWidget(const MaterialApp(home: KpScreen()));
      await tester.pump();

      expect(find.text('Belum ada data KP'), findsWidgets);
      expect(find.text('Menunggu pengajuan'), findsOneWidget);
      expect(find.text('Tambah Data KP'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('TambahKpScreen', () {
    Future<void> buka(WidgetTester tester) async {
      _pasangLayar(tester, tinggi: 6000);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TambahKpScreen()),
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

    testWidgets('menampilkan kelima kolom sesuai formulir web', (tester) async {
      await buka(tester);

      expect(find.text('DATA KP'), findsOneWidget);
      expect(find.text('Instansi'), findsOneWidget);
      expect(find.text('Judul KP'), findsOneWidget);
      expect(find.text('Bulan tahun awal KP'), findsOneWidget);
      expect(find.text('Bulan tahun akhir KP'), findsOneWidget);
      expect(find.text('Pembimbing Lapangan'), findsOneWidget);
      // kolom tambahan di luar web
      expect(find.text('Pembimbing Kampus'), findsOneWidget);
      expect(find.text('Catatan'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(4));
      expect(find.text('Simpan'), findsOneWidget);
      expect(find.text('Wajib'), findsNWidgets(5));
      expect(find.text('Opsional'), findsNWidgets(2));
    });

    testWidgets('periode bawaan adalah bulan berjalan + 2 bulan', (
      tester,
    ) async {
      await buka(tester);

      final awal = periodeAwalBawaan();
      final akhir = periodeAkhirBawaan();
      expect(find.text('${awal.label} – ${akhir.label}'), findsOneWidget);
      expect(find.text('Durasi kegiatan 3 bulan.'), findsOneWidget);
    });

    testWidgets('menolak simpan kalau kolom wajib masih kosong', (
      tester,
    ) async {
      await buka(tester);

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Instansi wajib diisi.'), findsOneWidget);
      expect(find.text('Judul KP wajib diisi.'), findsOneWidget);
      expect(find.text('Pembimbing Lapangan wajib diisi.'), findsOneWidget);
      expect(KpStore.jumlah, 1);
      expect(find.byType(TambahKpScreen), findsOneWidget);
    });

    testWidgets('menolak instansi dan judul yang terlalu pendek', (
      tester,
    ) async {
      await buka(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'PT');
      await tester.enterText(find.byType(TextFormField).at(1), 'KP');
      await tester.pump();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Instansi minimal 3 karakter.'), findsOneWidget);
      expect(find.text('Judul KP minimal 10 karakter.'), findsOneWidget);
      expect(KpStore.jumlah, 1);
    });

    testWidgets('bulan & tahun periode bisa diganti lewat dropdown', (
      tester,
    ) async {
      await buka(tester);
      await tester.tap(find.byType(DropdownButtonFormField<int>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Februari').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<int>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('2028').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'PT Pupuk Kaltim',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Otomasi Pencatatan Produksi Harian',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Rina Marlina, S.T.',
      );
      await tester.pump();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      final baru = KpStore.aktif!;
      expect(baru.awal.bulan, 2);
      expect(baru.awal.tahun, periodeAwalBawaan().tahun);
      expect(baru.akhir.tahun, 2028);
      expect(baru.instansi, 'PT Pupuk Kaltim');
    });
  });
}
