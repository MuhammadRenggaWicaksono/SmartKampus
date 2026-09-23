import 'package:flutter/material.dart';

class IsiKrsScreen extends StatefulWidget {
  const IsiKrsScreen({Key? key}) : super(key: key);

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
                Navigator.pop(context); // Tutup dialog dulu
                // TODO: Kirim data (_shiftTerpilih) ke API Backend
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Entri KRS Kelas $_shiftTerpilih Berhasil Disimpan!'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Kembali ke halaman akademik setelah berhasil
                Navigator.pop(context); 
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Entri KRS', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pilih shift kelas untuk semester ini. Mata kuliah akan dipaketkan secara otomatis berdasarkan pilihan Anda.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Pilih Shift Kelas:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Pilihan Kelas Pagi
            _buildPilihanCard(
              title: 'Kelas Pagi',
              description: 'Perkuliahan dimulai pagi hingga sore hari.',
              icon: Icons.wb_sunny_outlined,
              iconColor: Colors.orange,
              value: 'Pagi',
            ),
            const SizedBox(height: 16),

            // Pilihan Kelas Malam
            _buildPilihanCard(
              title: 'Kelas Malam',
              description: 'Perkuliahan dimulai sore hingga malam hari.',
              icon: Icons.nights_stay_outlined,
              iconColor: Colors.indigo,
              value: 'Malam',
            ),

            const Spacer(), // Mendorong tombol ke paling bawah layar

            // Tombol Simpan
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
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
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.blue.shade700 : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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