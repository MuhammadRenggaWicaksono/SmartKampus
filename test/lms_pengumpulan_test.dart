import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_kampus/lms/models/moodle_pengumpulan.dart';
import 'package:app_kampus/lms/services/moodle_api_service.dart';

/// Jawaban khas `mod_assign_get_submission_status`.
Map<String, dynamic> _statusJson({
  String status = 'draft',
  bool canedit = true,
  bool graded = false,
  num? grade,
  List<Map<String, dynamic>>? berkas,
}) {
  return <String, dynamic>{
    'lastattempt': <String, dynamic>{
      'submission': <String, dynamic>{
        'id': 55,
        'status': status,
        'timemodified': 1700000000,
        'plugins': <Map<String, dynamic>>[
          {
            'type': 'file',
            'fileareas': <Map<String, dynamic>>[
              {'files': berkas ?? <Map<String, dynamic>>[]},
            ],
          },
        ],
      },
      'canedit': canedit,
      'graded': graded,
      'locked': false,
    },
    'gradingsummary': <String, dynamic>{'grade': grade},
  };
}

void main() {
  group('MoodleSubmission', () {
    test('membaca status draf, hak edit, dan waktu ubah', () {
      final sub = MoodleSubmission.fromJson(_statusJson());
      expect(sub.status, 'draft');
      expect(sub.masihDraf, isTrue);
      expect(sub.sudahDikumpul, isFalse);
      expect(sub.dapatDiubah, isTrue);
      expect(sub.sudahDinilai, isFalse);
      expect(sub.diubahPada, 1700000000);
      expect(sub.labelStatus, 'Draf tersimpan');
    });

    test('membaca berkas yang sudah diunggah dari plugins/fileareas', () {
      final sub = MoodleSubmission.fromJson(
        _statusJson(
          berkas: <Map<String, dynamic>>[
            {
              'filename': 'laporan.pdf',
              'fileurl': 'https://lentera/pluginfile.php/9/laporan.pdf',
              'filesize': 4096,
              'mimetype': 'application/pdf',
            },
          ],
        ),
      );
      expect(sub.berkas.length, 1);
      expect(sub.berkas.single.nama, 'laporan.pdf');
      expect(sub.berkas.single.ukuran, 4096);
    });

    test('label status mengikuti status + penilaian', () {
      expect(
        MoodleSubmission.fromJson(_statusJson(status: 'new')).labelStatus,
        'Belum dikumpulkan',
      );
      expect(
        MoodleSubmission.fromJson(_statusJson(status: 'submitted')).labelStatus,
        'Sudah dikumpulkan',
      );
      expect(
        MoodleSubmission.fromJson(
          _statusJson(status: 'submitted', graded: true, grade: 88),
        ).labelStatus,
        'Sudah dinilai',
      );
      expect(
        MoodleSubmission.fromJson(
          _statusJson(status: 'reopened'),
        ).labelStatus,
        'Dibuka ulang untuk perbaikan',
      );
    });

    test('balasan kosong tidak dianggap sudah dikumpulkan', () {
      final sub = MoodleSubmission.fromJson(<String, dynamic>{});
      expect(sub.adaPercobaan, isFalse);
      expect(sub.sudahDikumpul, isFalse);
      expect(sub.berkas, isEmpty);
      expect(sub.nilai, isNull);
    });

    test('nilai dibaca dari gradingsummary', () {
      final sub = MoodleSubmission.fromJson(
        _statusJson(status: 'submitted', graded: true, grade: 91),
      );
      expect(sub.nilai, 91);
      expect(sub.sudahDinilai, isTrue);
    });
  });

  group('MoodleApiService — pengumpulan tugas', () {
    test('getSubmissionStatus mengirim assignid', () async {
      late http.Request kiriman;
      final api = MoodleApiService(
        client: MockClient((req) async {
          kiriman = req;
          return http.Response(jsonEncode(_statusJson()), 200);
        }),
      );

      final sub = await api.getSubmissionStatus(
        token: 't',
        assignmentId: 42,
      );

      final body = Uri.splitQueryString(kiriman.body);
      expect(body['wsfunction'], 'mod_assign_get_submission_status');
      expect(body['assignid'], '42');
      expect(body['moodlewsrestformat'], 'json');
      expect(sub.status, 'draft');
    });

    test('saveSubmission mengirim assignmentid + plugindata files_filemanager',
        () async {
      late http.Request kiriman;
      final api = MoodleApiService(
        client: MockClient((req) async {
          kiriman = req;
          return http.Response(jsonEncode(<String, dynamic>{}), 200);
        }),
      );

      await api.saveSubmission(token: 't', assignmentId: 42, itemId: 998877);

      final body = Uri.splitQueryString(kiriman.body);
      expect(body['wsfunction'], 'mod_assign_save_submission');
      expect(body['assignmentid'], '42');
      expect(body['plugindata[files_filemanager]'], '998877');
    });

    test('submitForGrading lengkap, tapi saklar pengiriman masih mati', () async {
      late http.Request kiriman;
      final api = MoodleApiService(
        client: MockClient((req) async {
          kiriman = req;
          return http.Response(jsonEncode(<String, dynamic>{}), 200);
        }),
      );

      await api.submitForGrading(token: 't', assignmentId: 42);

      final body = Uri.splitQueryString(kiriman.body);
      expect(body['wsfunction'], 'mod_assign_submit_for_grading');
      expect(body['assignmentid'], '42');
      expect(body['acceptsubmissionstatement'], '1');

      // Selama saklar mati, UI tidak pernah memanggil ini.
      expect(kKirimTugasAktif, isFalse);
    });

    test('menerjemahkan errorcode Moodle jadi MoodleException', () async {
      final api = MoodleApiService(
        client: MockClient(
          (req) async => http.Response(
            jsonEncode(<String, dynamic>{
              'exception': 'moodle_exception',
              'errorcode': 'nopermissions',
              'message': 'Tidak punya izin',
            }),
            200,
          ),
        ),
      );

      expect(
        () => api.saveSubmission(token: 't', assignmentId: 1, itemId: 2),
        throwsA(
          isA<MoodleException>()
              .having((e) => e.errorCode, 'errorCode', 'nopermissions')
              .having((e) => e.message, 'message', 'Tidak punya izin'),
        ),
      );
    });
  });

  group('MoodleApiService — unggah berkas', () {
    late Directory tmp;
    late String pathBerkas;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('lms_upload_');
      final f = File('${tmp.path}/tugas.txt')..writeAsStringSync('isi tugas');
      pathBerkas = f.path;
    });

    tearDown(() {
      if (tmp.existsSync()) tmp.deleteSync(recursive: true);
    });

    test('uploadFile memakai multipart + token di query', () async {
      late http.Request kiriman;
      final api = MoodleApiService(
        client: MockClient((req) async {
          kiriman = req;
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              {
                'itemid': 314159,
                'filename': 'tugas.txt',
                'fileurl': 'https://lentera/draftfile.php/314159/tugas.txt',
                'filesize': 9,
              },
            ]),
            200,
          );
        }),
      );

      final hasil = await api.uploadFile(
        token: 'rahasia',
        path: pathBerkas,
        namaBerkas: 'tugas.txt',
      );

      expect(kiriman.method, 'POST');
      expect(kiriman.url.path, '/webservice/upload.php');
      expect(kiriman.url.queryParameters['token'], 'rahasia');
      expect(
        kiriman.headers['content-type'],
        startsWith('multipart/form-data'),
      );
      expect(kiriman.body, contains('name="file"'));
      expect(kiriman.body, contains('filename="tugas.txt"'));
      expect(kiriman.body, contains('itemid'));

      expect(hasil.itemId, 314159);
      expect(hasil.nama, 'tugas.txt');
      expect(hasil.ukuran, 9);
    });

    test('uploadFile mengirim itemid area draf yang sama', () async {
      late http.Request kiriman;
      final api = MoodleApiService(
        client: MockClient((req) async {
          kiriman = req;
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              {'itemid': 777, 'filename': 'tugas.txt'},
            ]),
            200,
          );
        }),
      );

      await api.uploadFile(token: 't', path: pathBerkas, itemId: 777);

      final teks = kiriman.body;
      final potongan = teks.substring(
        teks.indexOf('name="itemid"'),
        teks.indexOf('name="itemid"') + 60,
      );
      expect(potongan, contains('777'));
    });

    test('uploadFile melempar MoodleException kalau server menolak', () async {
      final api = MoodleApiService(
        client: MockClient(
          (req) async => http.Response(
            jsonEncode(<String, dynamic>{
              'error': 'Berkas terlalu besar',
              'errorcode': 'maxbytesexceeded',
            }),
            200,
          ),
        ),
      );

      expect(
        () => api.uploadFile(token: 't', path: pathBerkas),
        throwsA(
          isA<MoodleException>()
              .having((e) => e.errorCode, 'errorCode', 'maxbytesexceeded')
              .having((e) => e.message, 'message', 'Berkas terlalu besar'),
        ),
      );
    });
  });

  group('UploadResult', () {
    test('fromJson memberi nilai aman kalau field hilang', () {
      final hasil = UploadResult.fromJson(<String, dynamic>{'filename': 'x'});
      expect(hasil.itemId, 0);
      expect(hasil.nama, 'x');
      expect(hasil.ukuran, 0);
    });
  });
}