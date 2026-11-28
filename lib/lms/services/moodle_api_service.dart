import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:app_kampus/lms/models/moodle_course.dart';
import 'package:app_kampus/lms/models/moodle_forum.dart';
import 'package:app_kampus/lms/models/moodle_materi.dart';
import 'package:app_kampus/lms/models/moodle_kuis.dart';
import 'package:app_kampus/lms/models/moodle_pengumpulan.dart';
import 'package:app_kampus/lms/models/moodle_tugas.dart';
import 'package:app_kampus/lms/models/moodle_user.dart';

/// Saklar pengiriman tugas untuk dinilai.
///
/// Tahap 3 hanya menyimpan **draf**: seluruh alur (pilih berkas → unggah →
/// `mod_assign_save_submission`) aktif, tapi `mod_assign_submit_for_grading`
/// sengaja tidak dipanggil supaya tidak ada tugas yang benar-benar terkirim.
/// Ubah ke `true` kalau memang ingin mengaktifkan pengiriman sungguhan.
const bool kKirimTugasAktif = false;

/// Error yang berasal dari Moodle (`errorcode` / `exception`) atau dari
/// koneksi. Pesannya sudah siap ditampilkan ke pengguna.
class MoodleException implements Exception {
  MoodleException({required this.message, this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => errorCode == null ? message : '$message ($errorCode)';
}

/// Klien tipis untuk Moodle REST API (lentera.universitasmulia.ac.id).
///
/// Aturan penting:
/// * Moodle TIDAK menerima body JSON. Semua parameter dikirim sebagai
///   `application/x-www-form-urlencoded` (default `http.post` saat [body]
///   berupa `Map<String, String>`), response-nya JSON.
/// * Response error dikenali lewat key `exception` atau `errorcode`.
class MoodleApiService {
  MoodleApiService({http.Client? client, this.baseUrl = kMoodleBaseUrl})
    : _client = client ?? http.Client();

  /// Base URL LMS kampus.
  static const String kMoodleBaseUrl = 'https://lentera.universitasmulia.ac.id';

  /// Service yang dipakai untuk menukar username+password menjadi token.
  static const String kMobileService = 'moodle_mobile_app';

  final String baseUrl;
  final http.Client _client;

  Uri get _restUri => Uri.parse('$baseUrl/webservice/rest/server.php');
  Uri get _tokenUri => Uri.parse('$baseUrl/login/token.php');
  Uri get _uploadUri => Uri.parse('$baseUrl/webservice/upload.php');

  /// Tukar username + password menjadi `wstoken`. Password tidak pernah
  /// disimpan — hanya tokennya.
  Future<String> login({
    required String username,
    required String password,
  }) async {
    final res = await _client.post(
      _tokenUri,
      body: <String, String>{
        'username': username,
        'password': password,
        'service': kMobileService,
      },
    );
    final json = _decode(res);
    if (json is Map && json['token'] is String) {
      return json['token'] as String;
    }
    throw MoodleException(
      message: (json is Map ? json['error'] as String? : null) ?? 'Login gagal',
      errorCode: json is Map ? json['errorcode'] as String? : null,
    );
  }

  /// Panggilan REST generik. [params] dikirim form-urlencoded.
  Future<dynamic> _call(
    String wsfunction,
    Map<String, dynamic> params,
    String token,
  ) async {
    final body = <String, String>{
      'wstoken': token,
      'wsfunction': wsfunction,
      'moodlewsrestformat': 'json',
      for (final entry in params.entries) entry.key: '${entry.value}',
    };
    final res = await _client.post(_restUri, body: body);
    final json = _decode(res);
    if (json is Map &&
        (json.containsKey('exception') || json.containsKey('errorcode'))) {
      throw MoodleException(
        message: (json['message'] as String?) ?? 'Permintaan Moodle gagal',
        errorCode: json['errorcode'] as String?,
      );
    }
    return json;
  }

  /// Profil pengguna aktif (userid, fullname, userpictureurl).
  Future<MoodleUser> getSiteInfo(String token) async {
    final json = await _call('core_webservice_get_site_info', const {}, token);
    return MoodleUser.fromJson(_asMap(json));
  }

  /// Daftar mata kuliah yang diikuti [userId].
  Future<List<MoodleCourse>> getUserCourses({
    required String token,
    required int userId,
  }) async {
    final json = await _call(
      'core_enrol_get_users_courses',
      <String, dynamic>{'userid': userId},
      token,
    );
    if (json is! List) return const <MoodleCourse>[];
    return json
        .map((e) => MoodleCourse.fromJson(_asMap(e)))
        .toList(growable: false);
  }

  /// Forum pengumuman & diskusi di satu mata kuliah.
  Future<List<MoodleForum>> getForums({
    required String token,
    required int courseId,
  }) async {
    final json = await _call(
      'mod_forum_get_forums_by_courses',
      <String, dynamic>{'courseids[0]': courseId},
      token,
    );
    if (json is! List) return const <MoodleForum>[];
    return json
        .map((e) => MoodleForum.fromJson(_asMap(e)))
        .toList(growable: false);
  }

  /// Postingan di dalam satu forum.
  Future<List<ForumDiscussion>> getForumDiscussions({
    required String token,
    required int forumId,
  }) async {
    final json = await _call(
      'mod_forum_get_forum_discussions',
      <String, dynamic>{'forumid': forumId},
      token,
    );
    final daftar = json is Map ? json['discussions'] : null;
    if (daftar is! List) return const <ForumDiscussion>[];
    return daftar
        .map((e) => ForumDiscussion.fromJson(_asMap(e)))
        .toList(growable: false);
  }

  /// Isi mata kuliah: pertemuan/topik → modul → berkas.
  Future<List<CourseSection>> getCourseContents({
    required String token,
    required int courseId,
  }) async {
    final json = await _call(
      'core_course_get_contents',
      <String, dynamic>{'courseid': courseId},
      token,
    );
    if (json is! List) return const <CourseSection>[];
    return json
        .map((e) => CourseSection.fromJson(_asMap(e)))
        .toList(growable: false);
  }

  /// Daftar tugas mata kuliah. Moodle membalas `{"courses": [...]}` —
  /// tugasnya diratakan jadi satu list datar.
  Future<List<Assignment>> getAssignments({
    required String token,
    required int courseId,
  }) async {
    final json = await _call(
      'mod_assign_get_assignments',
      <String, dynamic>{'courseids[0]': courseId},
      token,
    );
    final kursus = json is Map ? json['courses'] : null;
    if (kursus is! List) return const <Assignment>[];

    final hasil = <Assignment>[];
    for (final item in kursus) {
      final tugas = _asMap(item)['assignments'];
      if (tugas is! List) continue;
      for (final t in tugas) {
        hasil.add(Assignment.fromJson(_asMap(t)));
      }
    }
    return hasil;
  }

  /// Status pengumpulan tugas milik pengguna yang sedang login.
  Future<MoodleSubmission> getSubmissionStatus({
    required String token,
    required int assignmentId,
  }) async {
    final json = await _call(
      'mod_assign_get_submission_status',
      <String, dynamic>{'assignid': assignmentId},
      token,
    );
    return MoodleSubmission.fromJson(_asMap(json));
  }

  /// Unggah satu berkas ke area draf Moodle lewat `/webservice/upload.php`.
  ///
  /// Endpoint ini satu-satunya yang memakai `multipart/form-data`, bukan
  /// form-urlencoded. [itemId] harus dipakai ulang untuk berkas kedua dan
  /// seterusnya supaya semuanya masuk ke satu area draf yang sama.
  Future<UploadResult> uploadFile({
    required String token,
    required String path,
    int itemId = 0,
    String? namaBerkas,
  }) async {
    final uri = Uri.parse(
      '${_uploadUri.toString()}?token=${Uri.encodeQueryComponent(token)}',
    );
    final permintaan = http.MultipartRequest('POST', uri)
      ..fields['itemid'] = '$itemId'
      ..fields['filearea'] = 'draft'
      ..files.add(
        await http.MultipartFile.fromPath('file', path, filename: namaBerkas),
      );

    final balasan = await http.Response.fromStream(
      await _client.send(permintaan),
    );
    final json = _decode(balasan);

    final data = json is List && json.isNotEmpty
        ? _asMap(json.first)
        : _asMap(json);
    if (data.containsKey('exception') || data.containsKey('error')) {
      throw MoodleException(
        message:
            (data['message'] as String?) ??
            (data['error'] as String?) ??
            'Unggahan berkas gagal',
        errorCode: data['errorcode'] as String?,
      );
    }
    if (data['itemid'] == null) {
      throw MoodleException(message: 'Unggahan berkas gagal');
    }
    return UploadResult.fromJson(data);
  }

  /// Simpan berkas yang sudah diunggah sebagai pengumpulan (masih draf,
  /// belum dikirim untuk dinilai).
  Future<void> saveSubmission({
    required String token,
    required int assignmentId,
    required int itemId,
  }) async {
    await _call(
      'mod_assign_save_submission',
      <String, dynamic>{
        'assignmentid': assignmentId,
        'plugindata[files_filemanager]': itemId,
      },
      token,
    );
  }

  /// Kirim tugas **untuk dinilai**.
  ///
  /// Implementasinya lengkap, tapi UI tidak pernah memanggilnya selama
  /// [kKirimTugasAktif] masih `false` — supaya tidak ada tugas yang
  /// benar-benar terkirim selama pengujian.
  Future<void> submitForGrading({
    required String token,
    required int assignmentId,
  }) async {
    await _call(
      'mod_assign_submit_for_grading',
      <String, dynamic>{
        'assignmentid': assignmentId,
        'acceptsubmissionstatement': 1,
      },
      token,
    );
  }

  /// Daftar kuis di satu mata kuliah.
  ///
  /// Kuis (`mod_quiz`) adalah tipe aktivitas terpisah dari tugas
  /// (`mod_assign`) — kuis tidak akan pernah muncul di `getAssignments`.
  Future<List<MoodleQuiz>> getQuizzes({
    required String token,
    required int courseId,
  }) async {
    final json = await _call(
      'mod_quiz_get_quizzes_by_courses',
      <String, dynamic>{'courseids[0]': courseId},
      token,
    );
    final daftar = json is Map ? json['quizzes'] : null;
    if (daftar is! List) return const <MoodleQuiz>[];
    return daftar
        .map((e) => MoodleQuiz.fromJson(_asMap(e)))
        .toList(growable: false);
  }

  /// Nilai akhir kuis milik [userId]. `null` kalau belum ada nilai.
  Future<double?> getNilaiKuis({
    required String token,
    required int quizId,
    required int userId,
  }) async {
    final json = await _call(
      'mod_quiz_get_user_best_grade',
      <String, dynamic>{'quizid': quizId, 'userid': userId},
      token,
    );
    final map = _asMap(json);
    if (map['hasgrade'] != true) return null;
    final nilai = map['grade'];
    if (nilai is num) return nilai.toDouble();
    if (nilai is String) return double.tryParse(nilai);
    return null;
  }

  /// Kuis + nilai akhirnya, siap ditampilkan di tab Kuis.
  ///
  /// Satu kuis yang gagal dibaca nilainya tidak boleh menggagalkan seluruh
  /// tab — nilainya cukup dibiarkan kosong.
  Future<List<KuisRingkas>> getKuisKelas({
    required String token,
    required int courseId,
    required int userId,
  }) async {
    final daftar = await getQuizzes(token: token, courseId: courseId);
    final hasil = <KuisRingkas>[];
    for (final kuis in daftar) {
      double? nilai;
      try {
        nilai = await getNilaiKuis(
          token: token,
          quizId: kuis.id,
          userId: userId,
        );
      } catch (_) {
        nilai = null;
      }
      hasil.add(KuisRingkas(kuis: kuis, nilai: nilai));
    }
    return hasil;
  }

  /// URL halaman web sebuah modul, mis. `/mod/quiz/view.php?id=123`.
  ///
  /// Dipakai untuk aktivitas yang memang harus dibuka di browser (kuis dengan
  /// Safe Exam Browser tidak mungkin dan tidak boleh dijalankan di dalam app).
  String urlModul(String jenis, int moduleId) =>
      '$baseUrl/mod/$jenis/view.php?id=$moduleId';

  /// Menempelkan `?token=` ke URL `pluginfile.php` supaya file bisa diunduh.
  String withToken(String url, String token) {
    if (token.isEmpty || url.isEmpty) return url;
    final pemisah = url.contains('?') ? '&' : '?';
    return '$url$pemisah' 'token=$token';
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? value.cast<String, dynamic>() : <String, dynamic>{};

  dynamic _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MoodleException(
        message: 'Server LMS membalas ${res.statusCode}',
      );
    }
    try {
      return jsonDecode(res.body);
    } on FormatException {
      throw MoodleException(message: 'Balasan LMS tidak dapat dibaca');
    }
  }
}
