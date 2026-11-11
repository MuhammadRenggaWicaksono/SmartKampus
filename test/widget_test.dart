import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/main_screen.dart';
import 'package:app_kampus/data/app_data.dart';
import 'package:app_kampus/screens/dashboard_screen.dart';
import 'package:app_kampus/theme_notifier.dart';
import 'package:app_kampus/widgets/statistik_chart.dart';

/// Ukuran layar ponsel biasa (360 x 800 dp) supaya overflow ketahuan.
void _pasangLayar(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  tearDown(() => appThemeNotifier.value = AppThemeMode.light);

  group('StatistikChart', () {
    Future<void> pumpChart(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: SizedBox(width: 360, child: StatistikChart())),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('menampilkan 3 tombol dan grafik IPS secara default', (
      tester,
    ) async {
      _pasangLayar(tester);
      await pumpChart(tester);

      expect(find.text('Statistik Akademik'), findsOneWidget);
      expect(find.text('IPS 1-8'), findsOneWidget);
      expect(find.text('Tatap Muka'), findsOneWidget);
      expect(find.text('Absensi'), findsOneWidget);
      // legenda mode IPS
      expect(find.textContaining('Tertinggi 3.76'), findsOneWidget);
      expect(find.textContaining('Terendah 3.58'), findsOneWidget);
    });

    testWidgets('tombol Tatap Muka mengganti isi grafik', (tester) async {
      _pasangLayar(tester);
      await pumpChart(tester);

      await tester.tap(find.text('Tatap Muka'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('dari rencana 16x per mata kuliah'),
        findsOneWidget,
      );
      expect(find.textContaining('75/128 terlaksana'), findsOneWidget);
      expect(find.textContaining('Tertinggi 3.76'), findsNothing);
    });

    testWidgets('tombol Absensi mengganti isi grafik', (tester) async {
      _pasangLayar(tester);
      await pumpChart(tester);

      await tester.tap(find.text('Absensi'));
      await tester.pumpAndSettle();

      expect(find.text('Hadir ${AppData.totalHadir}'), findsOneWidget);
      expect(find.text('Sakit ${AppData.totalSakit}'), findsOneWidget);
      expect(find.text('Izin ${AppData.totalIzin}'), findsOneWidget);
      expect(find.text('Alpa ${AppData.totalAlpa}'), findsOneWidget);
    });

    testWidgets('digambar tanpa error di ketiga tema', (tester) async {
      _pasangLayar(tester);
      await pumpChart(tester);

      for (final mode in AppThemeMode.values) {
        appThemeNotifier.value = mode;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('DashboardScreen', () {
    Future<void> pumpDashboard(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DashboardScreen())),
      );
      await tester.pump();
    }

    testWidgets('kartu SKS menampilkan total terhadap target', (tester) async {
      _pasangLayar(tester);
      await pumpDashboard(tester);

      expect(find.text('SKS DIAMBIL'), findsOneWidget);
      expect(find.text('sisa ${AppData.sksSisa} SKS'), findsOneWidget);
      expect(find.text(AppData.labelSksTotal), findsOneWidget);
      expect(find.text('${AppData.sksDitempuh} / $kSksTargetLulus'), findsOneWidget);
      expect(find.text('116 / 144'), findsOneWidget);

      // sel bento: bar SKS, chip tagihan, dan selisih terhadap target IPS
      expect(find.text('${AppData.persenTerbayar}% dibayar'), findsOneWidget);
      expect(
        find.text(AppData.tagihanLunas ? 'LUNAS' : 'BELUM LUNAS'),
        findsOneWidget,
      );
      expect(
        find.text(
          '${AppData.selisihTargetIps >= 0 ? '+' : '-'}'
          '${AppData.selisihTargetIps.abs().toStringAsFixed(2)}',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Target ${AppData.targetIps.toStringAsFixed(2)}'),
        findsOneWidget,
      );

      // matikan timer periodik di dalam dashboard
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('menampilkan statistik, pengumuman, dan info IPK', (
      tester,
    ) async {
      _pasangLayar(tester);
      await pumpDashboard(tester);

      expect(find.text('Pengumuman'), findsOneWidget);
      expect(find.text('Statistik Akademik'), findsOneWidget);
      expect(find.text('IPK'), findsOneWidget);
      expect(find.text(AppData.ipk.toStringAsFixed(2)), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('render bersih di Light, Dark, dan LGBT', (tester) async {
      _pasangLayar(tester);
      await pumpDashboard(tester);

      for (final mode in AppThemeMode.values) {
        appThemeNotifier.value = mode;
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
        expect(find.text('Pengumuman'), findsOneWidget);
      }

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('MainScreen', () {
    testWidgets('5 tab terpasang tanpa error di ketiga tema', (tester) async {
      _pasangLayar(tester);
      await tester.pumpWidget(const MaterialApp(home: MainScreen()));
      await tester.pump();

      for (final mode in AppThemeMode.values) {
        appThemeNotifier.value = mode;
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
      }

      // IndexedStack harus menyimpan kelima halaman sekaligus.
      expect(find.byType(IndexedStack), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('AppPalette', () {
    test('kontras teks tidak sama dengan latar di tiap tema', () {
      for (final mode in AppThemeMode.values) {
        final p = AppPalette(mode);
        expect(p.textPrimary, isNot(equals(p.background)));
        expect(p.textPrimary, isNot(equals(p.card)));
        expect(p.card, isNot(equals(p.surfaceAlt)));
      }
    });

    test('perhitungan SKS dan IPK konsisten', () {
      expect(AppData.sksSemesterIni, 23);
      expect(AppData.sksDitempuh, 116);
      expect(AppData.sksSisa, kSksTargetLulus - 116);
      expect(AppData.ipk, 3.68);
      expect(AppData.rasioSks, closeTo(116 / 144, 0.0001));
    });

    test('rekap absensi mata kuliah konsisten', () {
      for (final mk in AppData.mataKuliahAktif) {
        expect(mk.terlaksana, lessThanOrEqualTo(kRencanaTatapMuka));
        expect(mk.terlaksana, mk.hadir + mk.sakit + mk.izin + mk.alpa);
      }
      expect(AppData.totalPertemuanTerlaksana, 75);
      expect(AppData.totalHadir, 69);
      expect(AppData.persenKehadiran, 92);
    });

    test('jadwal terdekat selalu mengembalikan kelas', () {
      // 1 Jan 2026 = Kamis
      final kamis = AppData.jadwalTerdekat(DateTime(2026, 1, 1));
      expect(kamis.hariIni, isTrue);
      expect(kamis.hari, 'Kamis');
      expect(kamis.kelas, isNotEmpty);

      // Minggu tidak ada kelas -> harus lompat ke hari berikutnya yang ada.
      final minggu = AppData.jadwalTerdekat(DateTime(2026, 1, 4));
      expect(minggu.hariIni, isFalse);
      expect(minggu.kelas, isNotEmpty);
      expect(minggu.hari, 'Senin');
    });
  });
}
