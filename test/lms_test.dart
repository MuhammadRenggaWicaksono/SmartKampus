import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_kampus/lms/models/course_group.dart';
import 'package:app_kampus/lms/models/moodle_course.dart';
import 'package:app_kampus/lms/models/moodle_user.dart';
import 'package:app_kampus/lms/services/moodle_api_service.dart';

void main() {
  group('MoodleCourse.fromJson', () {
    test('membaca id, nama, dan progress', () {
      final mk = MoodleCourse.fromJson(<String, dynamic>{
        'id': 12,
        'fullname': 'Robotika',
        'shortname': 'ROB',
        'progress': 42.5,
      });
      expect(mk.id, 12);
      expect(mk.fullName, 'Robotika');
      expect(mk.progress, 42.5);
    });

    test('progress yang tidak ada menjadi 0', () {
      final mk = MoodleCourse.fromJson(<String, dynamic>{
        'id': 1,
        'fullname': 'X',
        'shortname': 'X',
      });
      expect(mk.progress, 0);
    });
  });

  group('MoodleUser.fromJson', () {
    test('membaca userid, avatar, dan inisial', () {
      final u = MoodleUser.fromJson(<String, dynamic>{
        'userid': 7,
        'fullname': 'Rengga Wicaksono',
        'username': 'rengga',
        'userpictureurl': 'https://lentera/user/p.png',
        'sitename': 'Lentera',
      });
      expect(u.userId, 7);
      expect(u.inisial, 'RW');
      expect(u.avatarUrl, 'https://lentera/user/p.png');
      expect(u.siteName, 'Lentera');
    });
  });

  group('MoodleApiService', () {
    test('login mengirim form-urlencoded dan mengembalikan token', () async {
      late http.Request kiriman;
      final api = MoodleApiService(
        client: MockClient((req) async {
          kiriman = req;
          return http.Response(jsonEncode(<String, String>{'token': 'abc123'}), 200);
        }),
      );

      final token = await api.login(username: '2411044', password: 'rahasia');

      expect(token, 'abc123');
      expect(
        kiriman.headers['content-type'],
        contains('application/x-www-form-urlencoded'),
      );
      final body = Uri.splitQueryString(kiriman.body);
      expect(body['username'], '2411044');
      expect(body['password'], 'rahasia');
      expect(body['service'], 'moodle_mobile_app');
    });

    test('login gagal melempar MoodleException berisi errorcode', () async {
      final api = MoodleApiService(
        client: MockClient((req) async {
          return http.Response(
            jsonEncode(<String, String>{
              'error': 'Invalid login, please try again',
              'errorcode': 'invalidlogin',
            }),
            200,
          );
        }),
      );

      await expectLater(
        api.login(username: 'x', password: 'y'),
        throwsA(
          isA<MoodleException>().having(
            (e) => e.errorCode,
            'errorCode',
            'invalidlogin',
          ),
        ),
      );
    });

    test('getUserCourses mem-parse daftar mata kuliah', () async {
      final api = MoodleApiService(
        client: MockClient((req) async {
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              {'id': 1, 'fullname': 'Robotika', 'shortname': 'ROB', 'progress': 50},
              {'id': 2, 'fullname': 'Jaringan', 'shortname': 'JAR', 'progress': 75},
            ]),
            200,
          );
        }),
      );

      final courses = await api.getUserCourses(token: 't', userId: 7);
      expect(courses.length, 2);
      expect(courses[1].fullName, 'Jaringan');
      expect(courses[0].progress, 50);
    });

    test('errorcode pada response REST dilempar', () async {
      final api = MoodleApiService(
        client: MockClient((req) async {
          return http.Response(
            jsonEncode(<String, String>{
              'exception': 'moodle_exception',
              'errorcode': 'invalidtoken',
              'message': 'Invalid token',
            }),
            200,
          );
        }),
      );

      await expectLater(
        api.getSiteInfo('token-basi'),
        throwsA(
          isA<MoodleException>().having(
            (e) => e.errorCode,
            'errorCode',
            'invalidtoken',
          ),
        ),
      );
    });

    test('withToken menempelkan token ke URL pluginfile', () {
      final api = MoodleApiService(
        client: MockClient((req) async => http.Response('{}', 200)),
      );
      expect(
        api.withToken('https://lentera/pluginfile.php/1/a.pdf', 'T'),
        'https://lentera/pluginfile.php/1/a.pdf?token=T',
      );
      expect(
        api.withToken('https://lentera/f.php?a=1', 'T'),
        'https://lentera/f.php?a=1&token=T',
      );
    });
  });

  group('groupCoursesBySemester', () {
    MoodleCourse mk(String kode, {String? nama, int id = 0}) =>
        MoodleCourse.fromJson(<String, dynamic>{
          'id': id,
          'fullname': nama ?? kode,
          'shortname': kode,
        });

    test('semester dibaca dari kode dalam kurung nama MK (data asli Moodle)', () {
      // Di kampus ini shortname cuma angka polos; kode kelas ada di fullname.
      final course = MoodleCourse.fromJson(<String, dynamic>{
        'id': 1,
        'fullname': 'BAHASA INGGRIS BISNIS (IFB4B)',
        'shortname': '35303',
      });
      expect(semesterOfCourse(course), 4);
    });

    test('memisahkan tiap semester jadi grup, urut turun (terbaru di kiri)', () {
      final grup = groupCoursesBySemester(<MoodleCourse>[
        mk('IFB5B', id: 5),
        mk('IFB1B', id: 1),
        mk('IFB3A', id: 3),
        mk('IFB3B', id: 4),
        mk('IFB2B', id: 2),
      ]);

      expect(grup.map((g) => g.label), <String>[
        'Semester 5',
        'Semester 3',
        'Semester 2',
        'Semester 1',
      ]);
      expect(grup[1].courses.length, 2); // IFB3A + IFB3B digabung
      expect(grup[1].courses.map((c) => c.shortName), <String>['IFB3A', 'IFB3B']);
    });

    test('kode tanpa angka masuk "Lainnya" di paling akhir', () {
      final grup = groupCoursesBySemester(<MoodleCourse>[
        mk('X', id: 9),
        mk('IFB2B', id: 2),
      ]);

      expect(grup.last.label, 'Lainnya');
      expect(grup.last.courses.single.shortName, 'X');
    });

    test('semesterOfCourse membaca angka pertama kode kelas', () {
      expect(semesterOfCourse(mk('IFB4A')), 4);
      expect(semesterOfCourse(mk('')), isNull);
      expect(semesterOfCourse(mk('35303')), isNull); // angka polos > 8
    });
  });
}
