import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_kampus/lms/models/moodle_kuis.dart';
import 'package:app_kampus/lms/models/moodle_materi.dart';
import 'package:app_kampus/lms/services/moodle_api_service.dart';

Map<String, dynamic> _kuisJson({
  int id = 10,
  int courseModule = 77,
  String nama = 'Uji Ketuntasan CPMK3',
  int timelimit = 3600,
  int attempts = 1,
  num grade = 100,
  int timeopen = 1795512000,
  int timeclose = 1797320340,
}) {
  return <String, dynamic>{
    'id': id,
    'course': 3,
    'coursemodule': courseModule,
    'name': nama,
    'intro': '<p>Kerjakan dengan SEB</p>',
    'timeopen': timeopen,
    'timeclose': timeclose,
    'timelimit': timelimit,
    'attempts': attempts,
    'grade': grade,
  };
}

CourseModule _modul(String jenis, {int id = 1, String nama = 'X'}) {
  return CourseModule.fromJson(<String, dynamic>{
    'id': id,
    'name': nama,
    'modname': jenis,
    'url': 'https://lentera/mod/$jenis/view.php?id=$id',
  });
}

void main() {
  group('MoodleQuiz', () {
    test('membaca kuis: coursemodule, batas waktu, percobaan', () {
      final kuis = MoodleQuiz.fromJson(_kuisJson());
      expect(kuis.id, 10);
      expect(kuis.courseId, 3);
      expect(kuis.moduleId, 77);
      expect(kuis.nama, 'Uji Ketuntasan CPMK3');
      expect(kuis.batasWaktu, 3600);
      expect(kuis.jumlahPercobaan, 1);
      expect(kuis.nilaiMaks, 100);
      expect(kuis.buka, 1795512000);
      expect(kuis.tutup, 1797320340);
      expect(kuis.terbatasWaktu, isTrue);
    });

    test('labelBatasWaktu dibaca dalam menit / jam', () {
      String label(int detik) =>
          MoodleQuiz.fromJson(_kuisJson(timelimit: detik)).labelBatasWaktu;

      expect(label(0), 'Tanpa batas waktu');
      expect(label(2700), '45 menit');
      expect(label(3600), '1 jam');
      expect(label(5400), '1 jam 30 menit');
    });

    test('labelPercobaan: 0 berarti tak terbatas', () {
      expect(
        MoodleQuiz.fromJson(_kuisJson(attempts: 0)).labelPercobaan,
        'Tanpa batas percobaan',
      );
      expect(
        MoodleQuiz.fromJson(_kuisJson(attempts: 2)).labelPercobaan,
        '2 percobaan',
      );
    });

    test('nilaiMaks dibaca walau Moodle mengirim String', () {
      final kuis = MoodleQuiz.fromJson(
        <String, dynamic>{'id': 1, 'grade': '100'},
      );
      expect(kuis.nilaiMaks, 100);
    });

    test('tanpa coursemodule tetap aman', () {
      final kuis = MoodleQuiz.fromJson(<String, dynamic>{'id': 5});
      expect(kuis.moduleId, 0);
      expect(kuis.batasWaktu, 0);
      expect(kuis.buka, isNull);
      expect(kuis.tutup, isNull);
    });
  });

  group('MoodleApiService — kuis', () {
    test('getQuizzes membaca key "quizzes" + courseids[0]', () async {
      late http.Request kiriman;
      final api = MoodleApiService(
        client: MockClient((req) async {
          kiriman = req;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'quizzes': <Map<String, dynamic>>[_kuisJson()],
            }),
            200,
          );
        }),
      );

      final daftar = await api.getQuizzes(token: 't', courseId: 3);

      final body = Uri.splitQueryString(kiriman.body);
      expect(body['wsfunction'], 'mod_quiz_get_quizzes_by_courses');
      expect(body['courseids[0]'], '3');
      expect(daftar.single.nama, 'Uji Ketuntasan CPMK3');
    });

    test('getNilaiKuis mengubah grade String jadi angka', () async {
      final api = MoodleApiService(
        client: MockClient(
          (req) async => http.Response(
            jsonEncode(<String, dynamic>{
              'hasgrade': true,
              'grade': '71.67',
            }),
            200,
          ),
        ),
      );

      expect(
        await api.getNilaiKuis(token: 't', quizId: 10, userId: 2411044),
        71.67,
      );
    });

    test('getNilaiKuis mengembalikan null kalau belum ada nilai', () async {
      final api = MoodleApiService(
        client: MockClient(
          (req) async => http.Response(
            jsonEncode(<String, dynamic>{'hasgrade': false}),
            200,
          ),
        ),
      );

      expect(
        await api.getNilaiKuis(token: 't', quizId: 10, userId: 2411044),
        isNull,
      );
    });

    test('getKuisKelas: satu nilai gagal tidak menjatuhkan seluruh tab',
        () async {
      final api = MoodleApiService(
        client: MockClient((req) async {
          final body = Uri.splitQueryString(req.body);
          if (body['wsfunction'] == 'mod_quiz_get_quizzes_by_courses') {
            return http.Response(
              jsonEncode(<String, dynamic>{
                'quizzes': <Map<String, dynamic>>[
                  _kuisJson(id: 10, nama: 'Kuis A'),
                  _kuisJson(id: 20, nama: 'Kuis B'),
                ],
              }),
              200,
            );
          }
          if (body['quizid'] == '10') {
            return http.Response(
              jsonEncode(<String, dynamic>{
                'hasgrade': true,
                'grade': 71.67,
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode(<String, dynamic>{
              'exception': 'moodle_exception',
              'errorcode': 'nopermissions',
              'message': 'Tidak punya izin',
            }),
            200,
          );
        }),
      );

      final hasil = await api.getKuisKelas(
        token: 't',
        courseId: 3,
        userId: 2411044,
      );

      expect(hasil.length, 2);
      expect(hasil.first.nilai, 71.67);
      expect(hasil.first.sudahAdaNilai, isTrue);
      expect(hasil.last.nilai, isNull);
      expect(hasil.last.sudahAdaNilai, isFalse);
    });

    test('urlModul menyusun URL view.php yang benar', () {
      final api = MoodleApiService();
      expect(
        api.urlModul('quiz', 77),
        '${MoodleApiService.kMoodleBaseUrl}/mod/quiz/view.php?id=77',
      );
    });
  });

  group('CourseSection.tanpaJenis', () {
    test('membuang tugas/kuis/forum, menyisakan materi', () {
      final section = CourseSection(
        id: 1,
        nama: 'Pertemuan 1',
        ringkasan: '<p>Pengantar</p>',
        modules: <CourseModule>[
          _modul('resource', id: 1, nama: 'Slide.pdf'),
          _modul('quiz', id: 2, nama: 'Uji Ketuntasan'),
          _modul('assign', id: 3, nama: 'Laporan'),
          _modul('forum', id: 4, nama: 'Diskusi'),
          _modul('url', id: 5, nama: 'Tautan luar'),
        ],
      );

      final bersih = section.tanpaJenis(<String>{'assign', 'quiz', 'forum'});

      expect(bersih.modules.map((m) => m.jenis), <String>['resource', 'url']);
      expect(bersih.modules.map((m) => m.nama), <String>['Slide.pdf', 'Tautan luar']);
      expect(bersih.nama, 'Pertemuan 1');
      expect(section.modules.length, 5, reason: 'aslinya tidak diubah');
    });

    test('tidak mengganti objek kalau tidak ada yang dibuang', () {
      final section = CourseSection(
        id: 1,
        nama: 'Pertemuan 1',
        ringkasan: '',
        modules: <CourseModule>[_modul('resource')],
      );

      expect(section.tanpaJenis(<String>{'assign'}), same(section));
    });

    test('section yang isinya cuma kuis jadi kosong', () {
      final section = CourseSection(
        id: 2,
        nama: 'Pertemuan 2',
        ringkasan: '',
        modules: <CourseModule>[_modul('quiz')],
      );

      expect(section.tanpaJenis(<String>{'quiz'}).kosong, isTrue);
    });
  });
}