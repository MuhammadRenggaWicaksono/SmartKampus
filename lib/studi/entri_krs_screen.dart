import 'package:flutter/material.dart';
import 'package:app_kampus/theme_notifier.dart'; // Import pusat tema global
import 'package:app_kampus/studi/isi_krs_screen.dart'; // Import layar Entri KRS

class IsiKrsScreen extends StatefulWidget {
  const IsiKrsScreen({super.key});

  @override
  State<IsiKrsScreen> createState() => _IsiKrsScreenState();
}

class _IsiKrsScreenState extends State<IsiKrsScreen> {
  // Variabel untuk menyimpan pilihan (Pagi / Malam)
  String? _shiftTerpilih;

  // Fungsi saat tombol simpan ditekan
  void _prosesSimpanKrs() {
    if (_shiftTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih jadwal shift (Pagi/Malam) terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tampilkan Dialog Peringatan
    showDialog(
      context: context,
      barrierDismissible: false, // User harus klik tombol untuk menutup dialog
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 8),
              const Text('Konfirmasi KRS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
              children: [
                const TextSpan(text: 'Anda memilih untuk masuk '),
                TextSpan(text: 'Kelas $_shiftTerpilih', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                const TextSpan(text: ' pada semester ini.\n\n'),
                const TextSpan(
                  text: 'PERHATIAN:\n',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const TextSpan(
                  text: 'Pilihan yang sudah disimpan ',
                ),
                const TextSpan(
                  text: 'TIDAK DAPAT DIUBAH',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const TextSpan(
                  text: ' oleh mahasiswa. Perubahan jadwal setelah persetujuan ini hanya dapat dilakukan dengan menghubungi pihak akademik kampus.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog konfirmasi
                
                // Buka layar Pilih Mata Kuliah sesuai shift yang dipilih
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PilihMataKuliahScreen(shift: _shiftTerpilih!),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Ya, Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // [DIUBAH 1] Bungkus paling luar dengan ValueListenableBuilder
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentTheme, child) {
        
        // [DIUBAH 1] Deklarasikan variabel warna dinamis
        final bool isDark = currentTheme == AppThemeMode.dark;
        final bool isLgbt = currentTheme == AppThemeMode.lgbt;

        final Color scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
        final Color textColor = isDark ? Colors.white : Colors.black87;
        final Color cardColor = isDark 
            ? const Color(0xFF1E1E1E) 
            : (isLgbt ? Colors.white.withValues(alpha: 0.85) : Colors.white);
        final Color infoBoxBg = isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : Colors.blue.shade50;

        // [DIUBAH 2] Bungkus Container untuk gradasi LGBT (jika aktif)
        return Container(
          decoration: isLgbt
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
                  ),
                )
              : BoxDecoration(color: scaffoldBg),
          child: Scaffold(
            backgroundColor: Colors.transparent, // [DIUBAH 2] Dibuat transparan
            appBar: AppBar(
              // [DIUBAH 2] Warna AppBar & Teks dinamis (hapus const)
              title: Text('Entri KRS', style: TextStyle(color: textColor, fontSize: 18)),
              backgroundColor: cardColor,
              iconTheme: IconThemeData(color: textColor),
              elevation: 0.5,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: infoBoxBg, // [DIUBAH 3] Background dinamis
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.blue.shade700 : Colors.blue.shade100),
                    ),
                    child: Row( // [DIUBAH 4] Hapus keyword 'const'
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pilih shift kelas untuk semester ini. Mata kuliah akan dipaketkan secara otomatis berdasarkan pilihan Anda.',
                            style: TextStyle(fontSize: 13, color: textColor), // [DIUBAH 3] Warna teks dinamis
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text( // [DIUBAH 4] Hapus keyword 'const'
                    'Pilih Shift Kelas:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor), // [DIUBAH 3] Warna teks dinamis
                  ),
                  const SizedBox(height: 16),

                  // Pilihan Kelas Pagi (Sama)
                  _buildPilihanCard(
                    title: 'Kelas Pagi',
                    description: 'Perkuliahan dimulai pagi hingga sore hari.',
                    icon: Icons.wb_sunny_outlined,
                    iconColor: Colors.orange,
                    value: 'Pagi',
                  ),
                  const SizedBox(height: 16),

                  // Pilihan Kelas Malam (Sama)
                  _buildPilihanCard(
                    title: 'Kelas Malam',
                    description: 'Perkuliahan dimulai sore hingga malam hari.',
                    icon: Icons.nights_stay_outlined,
                    iconColor: Colors.indigo,
                    value: 'Malam',
                  ),

                  const Spacer(), // Mendorong tombol ke paling bawah layar (Sama)

                  // Tombol Simpan (Sama)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _prosesSimpanKrs,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Simpan KRS',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget untuk mendesain Kartu Pilihan yang bisa diklik
  Widget _buildPilihanCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String value,
  }) {
    bool isSelected = _shiftTerpilih == value;

    // 1. Baca tema saat ini langsung dari notifier
    final currentTheme = appThemeNotifier.value;
    final bool isDark = currentTheme == AppThemeMode.dark;
    final bool isLgbt = currentTheme == AppThemeMode.lgbt;

    // 2. Tentukan warna dinamis berdasarkan tema & status terpilih (selected)
    final Color cardBgColor = isDark
        ? (isSelected ? Colors.blue.shade900.withValues(alpha: 0.3) : const Color(0xFF1E1E1E))
        : (isSelected
            ? Colors.blue.shade50
            : (isLgbt ? Colors.white.withValues(alpha: 0.85) : Colors.white));

    final Color borderColor = isSelected
        ? Colors.blue
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300);

    final Color titleColor = isSelected
        ? (isDark ? Colors.blueAccent : Colors.blue.shade700)
        : (isDark ? Colors.white : Colors.black87);

    final Color descColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    
    final Color radioColor = isSelected
        ? Colors.blue
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400);

    return InkWell(
      onTap: () {
        setState(() {
          _shiftTerpilih = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? []
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 12, color: descColor)),
                ],
              ),
            ),
            // Indikator Check/Radio Button
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}