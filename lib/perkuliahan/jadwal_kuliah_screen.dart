import 'package:flutter/material.dart';

class JadwalKuliahScreen extends StatefulWidget {
  const JadwalKuliahScreen({super.key});

  @override
  State<JadwalKuliahScreen> createState() => _JadwalKuliahScreenState();
}

class _JadwalKuliahScreenState extends State<JadwalKuliahScreen> {
  String _semesterTerpilih = 'SEMESTER GANJIL 2026';

  // Struktur data jadwal mengikuti gambar 1000039200.jpg
  final List<Map<String, dynamic>> _jadwal = [
    {
      'hari': 'Senin',
      'kelas': [
        {'jam': '08:00 - 10:30', 'kode': '111500', 'nama': 'SISTEM MANAJEMEN BASIS DATA', 'sks': 3, 'ruang': 'LAB D (FIKOM)', 'dosen': 'NASRUDDIN BIN IDRIS, S.Kom., M.Kom.', 'adaLink': true},
        {'jam': '10:30 - 13:00', 'kode': '111400', 'nama': 'SIMULASI DAN GAME KOMPUTER', 'sks': 3, 'ruang': 'LAB A (FIKOM)', 'dosen': 'HERUZULKIFLI ROWA, S.Kom, M.Kom', 'adaLink': false},
        {'jam': '13:00 - 15:30', 'kode': '111600', 'nama': 'TEKNOLOGI APLIKASI BERGERAK', 'sks': 3, 'ruang': 'LAB B (FIKOM)', 'dosen': 'ISTIA BUDI, S.T., M.M.', 'adaLink': false},
      ]
    },
    {
      'hari': 'Selasa',
      'kelas': [
        {'jam': '13:00 - 15:30', 'kode': '111100', 'nama': 'PENALARAN KOMPUTER', 'sks': 3, 'ruang': 'A201', 'dosen': 'ISA ROSITA, S.Kom., M.Cs.', 'adaLink': false},
      ]
    },
    {
      'hari': 'Rabu',
      'kelas': [
        {'jam': '19:00 - 20:30', 'kode': '111300', 'nama': 'ROBOTIKA', 'sks': 3, 'ruang': 'LAB ROBOTIK (FIKOM)', 'dosen': 'MUHAMMAD SAFI\'I, S.Kom., M.Kom.', 'adaLink': false},
      ]
    },
    {
      'hari': 'Kamis',
      'kelas': [
        {'jam': '08:00 - 10:30', 'kode': '110600', 'nama': 'JARINGAN NIRKABEL', 'sks': 3, 'ruang': 'LAB JARINGAN (FIKOM)', 'dosen': 'WISNU HERA PAMUNGKAS, S.T.P., M.Eng', 'adaLink': false},
        {'jam': '13:00 - 15:30', 'kode': '111000', 'nama': 'PEMROGRAMAN APLIKASI BERGERAK', 'sks': 3, 'ruang': 'LAB A (FIKOM)', 'dosen': 'PRAMUDYA PRIMA INSAN, S.Kom., M.Kom.', 'adaLink': false},
      ]
    },
    {
      'hari': 'Jumat',
      'kelas': [
        {'jam': '08:00 - 09:40', 'kode': '000800', 'nama': 'PENULISAN DAN PUBLIKASI ILMIAH', 'sks': 2, 'ruang': 'A202', 'dosen': 'YUSUF WIBISONO, S.E., M.T.I.', 'adaLink': true},
      ]
    },
  ];

  void _downloadJadwal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunduh jadwal dalam format PDF...'), backgroundColor: Colors.blue),
    );
  }

  void _downloadMateri(String namaMatkul) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membuka tautan materi $namaMatkul...'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Jadwal Kuliah', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: 'Download Jadwal PDF',
            onPressed: _downloadJadwal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Dropdown Semester
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _semesterTerpilih,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
                items: ['SEMESTER GANJIL 2026', 'SEMESTER GENAP 2025'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _semesterTerpilih = newValue!);
                },
              ),
            ),
          ),
          
          // List Jadwal
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _jadwal.length,
              itemBuilder: (context, index) {
                final hariJadwal = _jadwal[index];
                return _buildHariSection(hariJadwal['hari'], hariJadwal['kelas']);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHariSection(String hari, List<Map<String, dynamic>> kelasi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            hari.toUpperCase(),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700, letterSpacing: 1),
          ),
        ),
        ...kelasi.map((mk) => _buildKartuMatkul(mk)),
      ],
    );
  }

  Widget _buildKartuMatkul(Map<String, dynamic> mk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Jam & Kode
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(mk['jam'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Text(mk['kode'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                ),
              ],
            ),
          ),
          
          // Body: Nama, Ruang, Dosen
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mk['nama'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.3)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.room_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(mk['ruang'], style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Icon(Icons.menu_book_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text('${mk['sks']} SKS', style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(mk['dosen'], style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer: Link Materi
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Link Materi', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                mk['adaLink'] 
                  ? ElevatedButton.icon(
                      onPressed: () => _downloadMateri(mk['nama']),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download Materi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50), // Warna hijau sesuai tombol di website
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  : Text('Tidak Ada Link...', style: TextStyle(fontSize: 13, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}