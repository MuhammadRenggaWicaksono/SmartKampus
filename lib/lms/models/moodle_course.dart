/// Satu mata kuliah Moodle — hasil fungsi `core_enrol_get_users_courses`.
class MoodleCourse {
  const MoodleCourse({
    required this.id,
    required this.fullName,
    required this.shortName,
    required this.progress,
    this.summary,
    this.categoryId,
  });

  final int id;
  final String fullName;
  final String shortName;

  /// Progres penyelesaian 0-100 sesuai yang dilaporkan Moodle.
  final double progress;
  final String? summary;
  final int? categoryId;

  factory MoodleCourse.fromJson(Map<String, dynamic> json) {
    final rawProgress = json['progress'];
    return MoodleCourse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: (json['fullname'] as String?) ?? '',
      shortName: (json['shortname'] as String?) ?? '',
      progress: rawProgress is num ? rawProgress.toDouble() : 0,
      summary: json['summary'] as String?,
      categoryId: (json['category'] as num?)?.toInt(),
    );
  }
}
