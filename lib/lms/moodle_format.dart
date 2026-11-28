/// Helper teks & waktu untuk data Moodle.
///
/// File ini sengaja **tidak** mengimpor Flutter supaya seluruh logikanya bisa
/// diuji dengan `flutter test` biasa tanpa memompa widget.
library;

const List<String> _bulan = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Angka dua digit untuk jam/menit.
String duaDigit(int nilai) => nilai.toString().padLeft(2, '0');

/// Moodle mengirim waktu sebagai Unix epoch (detik). Nilai `0`/`null` berarti
/// "tidak ada" — jangan pernah tampilkan sebagai 1 Jan 1970.
int? epochDari(dynamic nilai) {
  final angka = (nilai as num?)?.toInt();
  if (angka == null || angka <= 0) return null;
  return angka;
}

DateTime? _waktu(int? epoch) {
  if (epoch == null || epoch <= 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
}

/// "12 Nov 2026"
String tanggalMoodle(int? epoch) {
  final waktu = _waktu(epoch);
  if (waktu == null) return '';
  return '${waktu.day} ${_bulan[waktu.month - 1]} ${waktu.year}';
}

/// "12 Nov 2026, 23:59"
String tanggalJamMoodle(int? epoch) {
  final waktu = _waktu(epoch);
  if (waktu == null) return '';
  return '${tanggalMoodle(epoch)}, '
      '${duaDigit(waktu.hour)}:${duaDigit(waktu.minute)}';
}

/// Selisih hari menuju [epoch]. Negatif = sudah lewat, `0` = hari ini.
/// Dibandingkan per tanggal (bukan per jam) supaya "besok" tidak jadi "0 hari".
int? sisaHari(int? epoch, {DateTime? sekarang}) {
  final tenggat = _waktu(epoch);
  if (tenggat == null) return null;
  final kini = sekarang ?? DateTime.now();
  final awalTenggat = DateTime(tenggat.year, tenggat.month, tenggat.day);
  final awalKini = DateTime(kini.year, kini.month, kini.day);
  return awalTenggat.difference(awalKini).inDays;
}

/// "824 B", "12 KB", "1.4 MB"
String ukuranBerkas(int bytes) {
  if (bytes <= 0) return '';
  const int kb = 1024;
  if (bytes < kb) return '$bytes B';
  if (bytes < kb * kb) return '${(bytes / kb).toStringAsFixed(0)} KB';
  return '${(bytes / (kb * kb)).toStringAsFixed(1)} MB';
}

/// Buang tag HTML dari intro/summary/forum Moodle dan rapikan spasinya.
///
/// Moodle mengirim HTML mentah (`<p>`, `<br>`, `&amp;`, ...). Menampilkannya
/// apa adanya membuat kartu penuh tag; membuang semuanya membuat paragraf
/// menempel. Jadi `<br>`/`</p>` jadi baris baru dulu, baru tag dibuang.
String bersihkanHtml(String teks) {
  if (teks.isEmpty) return '';
  var hasil = teks
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<\s*/\s*p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<\s*li[^>]*>', caseSensitive: false), '\n• ')
      .replaceAll(RegExp(r'<[^>]*>'), '');

  hasil = _entitas(hasil);
  hasil = hasil
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r' *\n *'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
  return hasil;
}

String _entitas(String teks) {
  var hasil = teks
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&hellip;', '…')
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '–')
      .replaceAll('&lsquo;', '‘')
      .replaceAll('&rsquo;', '’')
      .replaceAll('&ldquo;', '“')
      .replaceAll('&rdquo;', '”')
      .replaceAll('&amp;', '&');

  return hasil.replaceAllMapped(RegExp(r'&#(\d+);'), (cocok) {
    final kode = int.tryParse(cocok.group(1)!);
    if (kode == null || kode <= 0 || kode > 0x10FFFF) return cocok.group(0)!;
    return String.fromCharCode(kode);
  });
}