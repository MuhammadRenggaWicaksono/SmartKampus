/// Forum & diskusi Moodle — hasil `mod_forum_get_forums_by_courses` dan
/// `mod_forum_get_forum_discussions`.
class MoodleForum {
  const MoodleForum({
    required this.id,
    required this.courseId,
    required this.type,
    required this.name,
  });

  final int id;
  final int courseId;

  /// `news` = forum pengumuman, `general` = forum diskusi biasa.
  final String type;
  final String name;

  bool get pengumuman => type == 'news';

  factory MoodleForum.fromJson(Map<String, dynamic> json) => MoodleForum(
    id: (json['id'] as num?)?.toInt() ?? 0,
    courseId: (json['course'] as num?)?.toInt() ?? 0,
    type: (json['type'] as String?) ?? '',
    name: (json['name'] as String?) ?? '',
  );
}

/// Satu topik/postingan di dalam forum.
class ForumDiscussion {
  const ForumDiscussion({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.penulis,
    required this.dibuat,
    required this.jumlahBalasan,
    required this.disematkan,
  });

  final int id;
  final String judul;

  /// Teks mentah dari Moodle — masih berisi HTML. Bersihkan dengan
  /// `bersihkanHtml()` sebelum ditampilkan.
  final String pesan;
  final String penulis;

  /// Unix epoch (detik).
  final int? dibuat;
  final int jumlahBalasan;
  final bool disematkan;

  factory ForumDiscussion.fromJson(Map<String, dynamic> json) =>
      ForumDiscussion(
        id: (json['id'] as num?)?.toInt() ?? 0,
        judul: (json['name'] as String?) ?? '',
        pesan: (json['message'] as String?) ?? '',
        penulis: (json['userfullname'] as String?) ?? '',
        dibuat: _epoch(json['created']),
        jumlahBalasan: (json['numreplies'] as num?)?.toInt() ?? 0,
        disematkan: json['pinned'] == true,
      );
}

int? _epoch(dynamic nilai) {
  final angka = (nilai as num?)?.toInt();
  if (angka == null || angka <= 0) return null;
  return angka;
}