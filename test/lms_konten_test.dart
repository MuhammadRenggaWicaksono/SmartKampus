import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:app_kampus/lms/models/moodle_forum.dart';
import 'package:app_kampus/lms/models/moodle_materi.dart';
import 'package:app_kampus/lms/models/moodle_tugas.dart';
import 'package:app_kampus/lms/moodle_format.dart';
import 'package:app_kampus/lms/services/moodle_api_service.dart';

/// Unix epoch (detik) dari waktu lokal — supaya tes tidak tergantung zona waktu.
int _epoch(DateTime waktu) => waktu.millisecondsSinceEpoch ~/ 1000;

void main() {
  group('moodle_format', () {
    test('bersihkanHtml membuang tag dan menjaga baris', () {
      expect(
        bersihkanHtml('<p>Halo <b>dunia</b></p><p>Baris 2</p>'),
        'Halo dunia\n\nBaris 2',
      );
      expect(bersihkanHtml('A<br>B'), 'A\nB');
      expect(bersihkanHtml('<ul><li>Satu</li><li>Dua</li></ul>'), '• Satu\n• Dua');
      expect(bersihkanHtml('   '), '');
    });

    test('bersihkanHtml membuka entitas HTML', () {
      expect(bersihkanHtml('R&amp;D &#39;x&#39; &lt;y&gt;'), "R&D 'x' <y>");
      expect(bersihkanHtml('a&nbsp;b'), 'a b');
    });

    test('tanggal & jam dari epoch', () {
      final waktu = DateTime(2026, 11, 12, 23, 59);
      expect(tanggalMoodle(_epoch(waktu)), '12 Nov 2026');
      expect(tanggalJamMoodle(_epoch(waktu)), '12 Nov 2026, 23:59');
      expect(tanggalMoodle(0), '');
      expect(tanggalMoodle(null), '');
    });

    test('epochDari menolak nilai kosong', () {
      expect(epochDari(0), isNull);
      expect(epochDari(null), isNull);
      expect(epochDari(1700000000), 1700000000);
    });

    test('sisaHari dihitung per tanggal', () {
      final kini = DateTime(2026, 11, 27, 10, 30);
      expect(sisaHari(_epoch(DateTime(2026, 11, 28, 8)), sekarang: kini), 1);
      expect(sisaHari(_epoch(DateTime(2026, 11, 27, 23)), sekarang: kini), 0);
      expect(sisaHari(_epoch(DateTime(2026, 11, 25)), sekarang: kini), -2);
      expect(sisaHari(null), isNull);
    });

    test('ukuranBerkas', () {
      expect(ukuranBerkas(0), '');
      expect(ukuranBerkas(500), '500 B');
      expect(ukuranBerkas(2048), '2 KB');
      expect(ukuranBerkas(1536 * 1024), '1.5 MB');
    });
  });

  group('MoodleForum', () {
    test('menandai forum bertipe news sebagai pengumuman', () {
      final berita = MoodleForum.fromJson(<String, dynamic>{
        'id': 10,
        'course': 3,
        'type': 'news',
        'name': 'Pengumuman',
      });
      final biasa = MoodleForum.fromJson(<String, dynamic>{
        'id': 11,
        'course': 3,
        'type': 'general',
        'name': 'Diskusi',
      });
      expect(berita.pengumuman, isTrue);
      expect(biasa.pengumuman, isFalse);
    });
  });

  group('ForumDiscussion', () {
    test('membaca judul, penulis, waktu, dan jumlah balasan', () {
      final d = ForumDiscussion.fromJson(<String, dynamic>{
        'id': 1,
        'name': 'UAS praktikum',
        'message': '<p>Dikumpul Jumat</p>',
        'userfullname': 'Dosen A',
        'created': 1700000000,
        'numreplies': 3,
        'pinned': true,
      });
      expect(d.judul, 'UAS praktikum');
      expect(d.penulis, 'Dosen A');
      expect(d.dibuat, 1700000000);
      expect(d.jumlahBalasan, 3);
      expect(d.disematkan, isTrue);
      expect(bersihkanHtml(d.pesan), 'Dikumpul Jumat');
    });
  });

  group('CourseSection', () {
    test('membaca section → module → berkas', () {
      final section = CourseSection.fromJson(<String, dynamic>{
        'id': 5,
        'name': 'Pertemuan 1',
        'summary': '<p>Pengantar</p>',
        'modules': <Map<String, dynamic>>[
          {
            'id': 21,
            'name': 'Modul PDF',
            'modname': 'resource',
            'url': 'https://lentera/mod/resource/view.php?id=21',
            'description': 'Materi awal',
            'contents': <Map<String, dynamic>>[
              {
                'filename': 'materi1.pdf',
                'fileurl': 'https://lentera/pluginfile.php/1/materi1.pdf',
                'filesize': 2048,
                'mimetype': 'application/pdf',
              },
            ],
          },
        ],
      });

      expect(section.nama, 'Pertemuan 1');
      expect(section.kosong, isFalse);
      expect(section.modules.single.jenis, 'resource');
      expect(section.modules.single.adaBerkas, isTrue);

      final berkas = section.modules.single.berkas.single;
      expect(berkas.nama, 'materi1.pdf');
      expect(berkas.ukuran, 2048);
      expect(berkas.pdf, isTrue);
    });
  });

  group('Assignment', () {
    test('membaca tenggat dan nilai maksimal', () {
      final tenggat = _epoch(DateTime(2026, 12, 1, 23, 59));
      final tugas = Assignment.fromJson(<String, dynamic>{
        'id': 7,
        'course': 3,
        'name': 'Laporan 1',
        'intro': '<p>Buat laporan</p>',
        'duedate': tenggat,
        'grade': 100,
        'cutoffdate': 0,
      });
      expect(tugas.nama, 'Laporan 1');
      expect(tugas.tenggat, tenggat);
      expect(tugas.nilaiMaks, 100);
      expect(tugas.bolehTerlambat, isTrue);
      expect(bersihkanHtml(tugas.intro), 'Buat laporan');
    });

    test('unggah berkas aktif kalau config file enabled', () {
      final aktif = Assignment.fromJson(<String, dynamic>{
        'id': 1,
        'configs': <Map<String, dynamic>>[
          {
            'plugin': 'file',
            'subtype': 'assignsubmission',
            'name': 'enabled',
            'value': 1,
          },
        ],
      });
      final mati = Assignment.fromJson(<String, dynamic>{
        'id': 2,
        'configs': <Map<String, dynamic>>[],
      });
      expect(aktif.unggahBerkas, isTrue);
      expect(mati.unggahBerkas, isFalse);
    });
  });

  group('MoodleApiService — konten kelas', () {
    test('getForums mengirim courseids[0] dan membaca tipe forum', () async {
      late http.Request kiriman;
      final api = MoodleApiService(
        client: MockClient((req) async {
          kiriman = req;
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              {'id': 10, 'course': 3, 'type': 'news', 'name': 'Pengumuman'},
            ]),
            200,
          );
        }),
      );

      final forums = await api.getForums(token: 't', courseId: 3);

      final body = Uri.splitQueryString(kiriman.body);
      expect(body['wsfunction'], 'mod_forum_get_forums_by_courses');
      expect(body['courseids[0]'], '3');
      expect(forums.single.pengumuman, isTrue);
    });

    test('getForumDiscussions membaca key "discussions"', () async {
      final api = MoodleApiService(
        client: MockClient(
          (req) async => http.Response(
            jsonEncode(<String, dynamic>{
              'discussions': <Map<String, dynamic>>[
                {'id': 1, 'name': 'Halo', 'message': '<p>x</p>'},
              ],
            }),
            200,
          ),
        ),
      );

      final hasil = await api.getForumDiscussions(token: 't', forumId: 10);
      expect(hasil.length, 1);
      expect(hasil.single.judul, 'Halo');
    });

    test('getCourseContents mem-parse daftar section', () async {
      late http.Request kiriman;
      final api = MoodleApiService(
        client: MockClient((req) async {
          kiriman = req;
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[
              {'id': 1, 'name': 'Pertemuan 1', 'modules': <dynamic>[]},
              {'id': 2, 'name': 'Pertemuan 2', 'modules': <dynamic>[]},
            ]),
            200,
          );
        }),
      );

      final isi = await api.getCourseContents(token: 't', courseId: 3);
      final body = Uri.splitQueryString(kiriman.body);
      expect(body['wsfunction'], 'core_course_get_contents');
      expect(body['courseid'], '3');
      expect(isi.length, 2);
      expect(isi[1].nama, 'Pertemuan 2');
    });

    test('getAssignments meratakan {"courses": [...]}', () async {
      final api = MoodleApiService(
        client: MockClient(
          (req) async => http.Response(
            jsonEncode(<String, dynamic>{
              'courses': <Map<String, dynamic>>[
                {
                  'id': 3,
                  'assignments': <Map<String, dynamic>>[
                    {'id': 1, 'course': 3, 'name': 'Tugas A', 'duedate': 0},
                    {'id': 2, 'course': 3, 'name': 'Tugas B', 'duedate': 0},
                  ],
                },
              ],
            }),
            200,
          ),
        ),
      );

      final tugas = await api.getAssignments(token: 't', courseId: 3);
      expect(tugas.map((t) => t.nama), <String>['Tugas A', 'Tugas B']);
      expect(tugas.every((t) => t.tenggat == null), isTrue);
    });
  });
}