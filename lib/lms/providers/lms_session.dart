import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:app_kampus/lms/models/moodle_user.dart';

/// Sesi LMS Moodle: menyimpan **token** (bukan password) di secure storage
/// supaya pengguna tidak login ulang setiap membuka aplikasi.
class LmsSession extends ChangeNotifier {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _kToken = 'moodle_token';
  static const String _kUserId = 'moodle_userid';
  static const String _kFullName = 'moodle_fullname';
  static const String _kUsername = 'moodle_username';
  static const String _kAvatar = 'moodle_avatar';
  static const String _kSiteName = 'moodle_sitename';

  String? _token;
  MoodleUser? _user;
  bool _siap = false;

  String? get token => _token;
  MoodleUser? get user => _user;

  /// true setelah percobaan muat pertama selesai (dipakai layar gerbang agar
  /// tidak berkedip ke halaman login sebelum token selesai dibaca).
  bool get siap => _siap;

  bool get sudahMasuk => _token != null && _user != null;

  /// Baca token tersimpan. Aman dipanggil berkali-kali.
  Future<void> muat() async {
    try {
      final token = await _storage.read(key: _kToken);
      final userId = await _storage.read(key: _kUserId);
      if (token != null && userId != null) {
        _token = token;
        _user = MoodleUser(
          userId: int.tryParse(userId) ?? 0,
          fullName: await _storage.read(key: _kFullName) ?? '',
          username: await _storage.read(key: _kUsername) ?? '',
          avatarUrl: await _storage.read(key: _kAvatar),
          siteName: await _storage.read(key: _kSiteName),
        );
      }
    } catch (_) {
      // Secure storage bisa tidak tersedia di sebagian platform. Kegagalan
      // membaca dianggap "belum login", bukan crash — pengguna cukup login.
      _token = null;
      _user = null;
    }
    _siap = true;
    notifyListeners();
  }

  /// Simpan sesi setelah login sukses.
  Future<void> simpan(String token, MoodleUser user) async {
    _token = token;
    _user = user;
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUserId, value: '${user.userId}');
    await _storage.write(key: _kFullName, value: user.fullName);
    await _storage.write(key: _kUsername, value: user.username);
    if (user.avatarUrl != null) {
      await _storage.write(key: _kAvatar, value: user.avatarUrl);
    }
    if (user.siteName != null) {
      await _storage.write(key: _kSiteName, value: user.siteName);
    }
    _siap = true;
    notifyListeners();
  }

  /// Hapus sesi (logout).
  Future<void> keluar() async {
    _token = null;
    _user = null;
    for (final key in <String>[
      _kToken,
      _kUserId,
      _kFullName,
      _kUsername,
      _kAvatar,
      _kSiteName,
    ]) {
      await _storage.delete(key: key);
    }
    notifyListeners();
  }
}

/// Sesi LMS global — satu instance untuk seluruh aplikasi.
final LmsSession lmsSession = LmsSession();
