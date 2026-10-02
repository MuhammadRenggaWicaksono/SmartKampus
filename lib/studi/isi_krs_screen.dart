import 'package:flutter/material.dart';
import 'package:app_kampus/theme_notifier.dart';

class PilihMataKuliahScreen extends StatefulWidget {
  final String shift;

  const PilihMataKuliahScreen({super.key, required this.shift});

  @override
  State<PilihMataKuliahScreen> createState() => _PilihMataKuliahScreenState();
}

class _PilihMataKuliahScreenState extends State<PilihMataKuliahScreen> {
  late List<Map<String, dynamic>> _daftarMatkul;
  final Set<String> _selectedKode = {};

  @override
  void initState() {
    super.initState();
    final bool isPagi = widget.shift == 'Pagi';

    // Dummy Data Mata Kuliah Semester 5
    _daftarMatkul = [
      {
        'kode': '000800',
        'nama': 'PENULISAN DAN PUBLIKASI ILMIAH',
        'sks': 2,
        'prasyarat': 'Metodologi Penelitian',
        'jenis': 'WAJIB',
        'kelas': 'IFB5A',
        'dosen': 'Dr. Aris, M.T.',
        'hari': 'Senin',
        'jam': isPagi ? '08:00 - 09:40' : '17:00 - 18:40',
        'terisi': 20,
        'max': 25,
      },
      {
        'kode': '110700',
        'nama': 'KRIPTOGRAFI',
        'sks': 3,
        'prasyarat': '-',
        'jenis': 'PILIHAN',
        'kelas': 'IFB5A',
        'dosen': 'Budi Santoso, M.Kom',
        'hari': 'Senin',
        'jam': isPagi ? '10:00 - 12:30' : '18:40 - 21:10',
        'terisi': 18,
        'max': 25,
      },
      {
        'kode': '111100',
        'nama': 'PENALARAN KOMPUTER',
        'sks': 3,
        'prasyarat': 'Kecerdasan Buatan',
        'jenis': 'PILIHAN',
        'kelas': 'IFB5A',
        'dosen': 'Prof. Maya',
        'hari': 'Selasa',
        'jam': isPagi ? '08:00 - 10:30' : '17:00 - 19:30',
        'terisi': 22,
        'max': 25,
      },
      {
        'kode': '111300',
        'nama': 'ROBOTIKA',
        'sks': 3,
        'prasyarat': 'Mikrokontroler',
        'jenis': 'PILIHAN',
        'kelas': 'IFB5A',
        'dosen': 'Ir. Eko, M.T.',
        'hari': 'Selasa',
        'jam': isPagi ? '10:30 - 13:00' : '19:30 - 22:00',
        'terisi': 25, // Kelas Penuh
        'max': 25,
      },
      {
        'kode': '111400',
        'nama': 'SIMULASI DAN GAME KOMPUTER',
        'sks': 3,
        'prasyarat': 'Algoritma dan Pemrograman',
        'jenis': 'PILIHAN',
        'kelas': 'IFB5A',
        'dosen': 'Dian S., M.T.',
        'hari': 'Rabu',
        'jam': isPagi ? '08:00 - 10:30' : '17:00 - 19:30',
        'terisi': 15,
        'max': 25,
      },
      {
        'kode': '110600',
        'nama': 'JARINGAN NIRKABEL',
        'sks': 3,
        'prasyarat': 'Jaringan Komputer',
        'jenis': 'PILIHAN',
        'kelas': 'IFB5A',
        'dosen': 'Ahmad Fauzi, M.Kom',
        'hari': 'Rabu',
        'jam': isPagi ? '10:30 - 13:00' : '19:30 - 22:00',
        'terisi': 24,
        'max': 25,
      },
      {
        'kode': '111000',
        'nama': 'PEMROGRAMAN APLIKASI BERGERAK',
        'sks': 3,
        'prasyarat': 'Algoritme dan Pemrograman',
        'jenis': 'PILIHAN',
        'kelas': 'IFB5A',
        'dosen': 'Riza H., M.T.',
        'hari': 'Kamis',
        'jam': isPagi ? '08:00 - 10:30' : '17:00 - 19:30',
        'terisi': 19,
        'max': 25,
      },
      {
        'kode': '111600',
        'nama': 'TEKNOLOGI APLIKASI BERGERAK',
        'sks': 3,
        'prasyarat': 'Komunikasi Data',
        'jenis': 'PILIHAN',
        'kelas': 'IFB5A',
        'dosen': 'Riza H., M.T.',
        'hari': 'Kamis',
        'jam': isPagi ? '10:30 - 13:00' : '19:30 - 22:00',
        'terisi': 12,
        'max': 25,
      },
      {
        'kode': '111500',
        'nama': 'SISTEM MANAJEMEN BASIS DATA',
        'sks': 3,
        'prasyarat': 'Sistem Basis Data',
        'jenis': 'PILIHAN',
        'kelas': 'IFB5A',
        'dosen': 'Siti Aminah, M.Kom',
        'hari': 'Jumat',
        'jam': isPagi ? '08:00 - 10:30' : '17:00 - 19:30',
        'terisi': 21,
        'max': 25,
      },
    ];

    // Otomatis centang matkul Wajib
    for (var item in _daftarMatkul) {
      if (item['jenis'] == 'WAJIB') {
        _selectedKode.add(item['kode'] as String);
      }
    }
  }

  int get _totalSksTerpilih {
    int total = 0;
    for (var item in _daftarMatkul) {
      if (_selectedKode.contains(item['kode'])) {
        total += item['sks'] as int;
      }
    }
    return total;
  }

  void _ajukanKrs() {
    if (_selectedKode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 mata kuliah!'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ajukan KRS', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Kamu memilih $_totalSksTerpilih SKS. Kirim ke Dosen Pembimbing Akademik untuk di-ACC?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup Dialog
              Navigator.pop(context); // Kembali ke menu utama
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('KRS berhasil diajukan! Menunggu ACC Dosen Pembimbing.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Ya, Ajukan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentTheme, child) {
        final bool isDark = currentTheme == AppThemeMode.dark;
        final bool isLgbt = currentTheme == AppThemeMode.lgbt;

        final Color scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
        final Color textColor = isDark ? Colors.white : Colors.black87;
        final Color cardColor = isDark
            ? const Color(0xFF1E1E1E)
            : (isLgbt ? Colors.white.withValues(alpha: 0.85) : Colors.white);

        return Container(
          decoration: isLgbt
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
                  ),
                )
              : BoxDecoration(color: scaffoldBg),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Pilih Mata Kuliah (${widget.shift})', style: TextStyle(color: textColor, fontSize: 18)),
              backgroundColor: cardColor,
              iconTheme: IconThemeData(color: textColor),
              elevation: 0.5,
            ),
            body: Column(
              children: [
                // Info Bar SKS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: isDark ? Colors.blue.shade900.withValues(alpha: 0.4) : Colors.blue.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Semester 5 (IFB5A)', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      Text(
                        'Terpilih: $_totalSksTerpilih / 26 SKS',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                ),

                // List Mata Kuliah
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _daftarMatkul.length,
                    itemBuilder: (context, index) {
                      final item = _daftarMatkul[index];
                      final bool isSelected = _selectedKode.contains(item['kode']);
                      final bool isWajib = item['jenis'] == 'WAJIB';
                      final bool isPenuh = item['terisi'] >= item['max'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              activeColor: Colors.blue,
                              onChanged: (isWajib || isPenuh)
                                  ? null
                                  : (bool? checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedKode.add(item['kode']);
                                        } else {
                                          _selectedKode.remove(item['kode']);
                                        }
                                      });
                                    },
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isWajib ? Colors.red.shade100 : Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item['jenis'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isWajib ? Colors.red.shade800 : Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item['kode'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    item['nama'],
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('SKS: ${item['sks']} | Prasyarat: ${item['prasyarat']}', style: const TextStyle(fontSize: 12)),
                                  Text('Dosen: ${item['dosen']}', style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${item['hari']}, ${item['jam']}', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.w600)),
                                      Text(
                                        'Kuota: ${item['terisi']}/${item['max']} ${isPenuh ? '(PENUH)' : ''}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPenuh ? Colors.red : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Tombol Ajukan
                Container(
                  padding: const EdgeInsets.all(16),
                  color: cardColor,
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _ajukanKrs,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Ajukan KRS Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}