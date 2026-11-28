/// Info pengguna Moodle — hasil fungsi `core_webservice_get_site_info`.
class MoodleUser {
  const MoodleUser({
    required this.userId,
    required this.fullName,
    required this.username,
    this.avatarUrl,
    this.siteName,
  });

  final int userId;
  final String fullName;
  final String username;

  /// URL foto profil mentah dari Moodle (belum ditempel token).
  final String? avatarUrl;
  final String? siteName;

  factory MoodleUser.fromJson(Map<String, dynamic> json) {
    return MoodleUser(
      userId: (json['userid'] as num?)?.toInt() ?? 0,
      fullName: (json['fullname'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      avatarUrl: json['userpictureurl'] as String?,
      siteName: json['sitename'] as String?,
    );
  }

  /// Inisial untuk avatar cadangan kalau foto profil gagal dimuat.
  String get inisial {
    final bagian = fullName.split(' ').where((k) => k.isNotEmpty).toList();
    if (bagian.isEmpty) return '?';
    if (bagian.length == 1) return bagian.first.substring(0, 1).toUpperCase();
    return (bagian[0].substring(0, 1) + bagian[1].substring(0, 1))
        .toUpperCase();
  }
}
