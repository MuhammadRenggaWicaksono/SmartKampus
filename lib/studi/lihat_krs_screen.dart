import 'package:flutter/material.dart';

class LihatKrsScreen extends StatefulWidget {
  const LihatKrsScreen({Key? key}) : super(key: key);

  @override
  State<LihatKrsScreen> createState() => _LihatKrsScreenState();
}

class _LihatKrsScreenState extends State<LihatKrsScreen> {
  // Nilai default
  String _tahunTerpilih = '2026/2027';
  String _semesterTerpilih = 'Ganjil';
  bool _isLoading = false;
  bool _isDataTampil = false;

  final List<String> _listTahun = ['2024/2025', '2025/2026', '2026/2027'];
  final List<String> _listSemester = ['Ganjil', 'Genap', 'Genap-P'];

  // --- DATABASE DUMMY DARI SCREENSHOT KRS ---
  final Map<String, List<Map<String, dynamic>>> _databaseKrs = {
    '2024/2025_Ganjil': [
      {'kode': '110100', 'nama': 'ALGORITMA DAN PEMROGRAMAN', 'sks': 3, 'kelas': 'IFB1B'},
      {'kode': '000100', 'nama': 'BAHASA INDONESIA', 'sks': 2, 'kelas': 'IFB1B'},
      {'kode': '110300', 'nama': 'BAHASA INGGRIS', 'sks': 3, 'kelas': 'IFB1B'},
      {'kode': '110401', 'nama': 'ETIKA PROFESI', 'sks': 2, 'kelas': 'IFB1B'},
      {'kode': '110501', 'nama': 'INTERAKSI MANUSIA DAN KOMPUTER', 'sks': 3, 'kelas': 'IFB1B'},
      {'kode': '110800', 'nama': 'LOGIKA INFORMATIKA', 'sks': 3, 'kelas': 'IFB1B'},
      {'kode': '110900', 'nama': 'MATEMATIKA I', 'sks': 2, 'kelas': 'IFB1B'},
      {'kode': '000400', 'nama': 'PANCASILA', 'sks': 2, 'kelas': 'IFB1B'},
      {'kode': '001000', 'nama': 'TEKNOLOGI INFORMASI', 'sks': 3, 'kelas': 'IFB1B'},
    ],
    '2024/2025_Genap': [
      {'kode': '111700', 'nama': 'ALJABAR LINIER DAN MATRIKS', 'sks': 2, 'kelas': 'IFB2B'},
      {'kode': '112400', 'nama': 'KOMUNIKASI DATA', 'sks': 3, 'kelas': 'IFB2B'},
      {'kode': '112600', 'nama': 'MATEMATIKA II', 'sks': 2, 'kelas': 'IFB2B'},
      {'kode': '113100', 'nama': 'PEMROGRAMAN JAVA', 'sks': 3, 'kelas': 'IFB2B'},
      {'kode': '113200', 'nama': 'PEMROGRAMAN VISUAL', 'sks': 3, 'kelas': 'IFB2B'},
      {'kode': '000700', 'nama': 'PENDIDIKAN KEWARGANEGARAAN', 'sks': 2, 'kelas': 'IFB2A'},
      {'kode': '113400', 'nama': 'PERANGKAT KERAS KOMPUTER', 'sks': 3, 'kelas': 'IFB2B'},
      {'kode': '113700', 'nama': 'SISTEM DIGITAL', 'sks': 3, 'kelas': 'IFB2B'},
      {'kode': '114100', 'nama': 'STRUKTUR DATA', 'sks': 3, 'kelas': 'IFB2B'},
    ],
    '2025/2026_Ganjil': [
      {'kode': '110200', 'nama': 'ANALISIS DESAIN BERORIENTASI OBJEK', 'sks': 3, 'kelas': 'IFB3J'},
      {'kode': '010100', 'nama': 'JARINGAN KOMPUTER', 'sks': 3, 'kelas': 'IFB3J'},
      {'kode': '010500', 'nama': 'PEMROGRAMAN WEB', 'sks': 3, 'kelas': 'IFB3J'},
      {'kode': '000500', 'nama': 'PENDIDIKAN AGAMA', 'sks': 2, 'kelas': 'IFB3J'},
      {'kode': '000600', 'nama': 'PENDIDIKAN ANTI KORUPSI', 'sks': 2, 'kelas': 'IFB3J'},
      {'kode': '010600', 'nama': 'SISTEM BASIS DATA', 'sks': 3, 'kelas': 'IFB3J'},
      {'kode': '010700', 'nama': 'SISTEM OPERASI', 'sks': 3, 'kelas': 'IFB3J'},
      {'kode': '001200', 'nama': 'WIRAUSAHA BERBASIS TEKNOLOGI', 'sks': 4, 'kelas': 'IFB3J'},
    ],
    '2025/2026_Genap': [
      {'kode': '111800', 'nama': 'ARSITEKTUR DAN ORGANISASI KOMPUTER', 'sks': 3, 'kelas': 'IFB4B'},
      {'kode': '000200', 'nama': 'BAHASA INGGRIS BISNIS', 'sks': 3, 'kelas': 'IFB4B'},
      {'kode': '111900', 'nama': 'GRAFIKA KOMPUTER', 'sks': 3, 'kelas': 'IFB4B'},
      {'kode': '112000', 'nama': 'INTERNET OF THINGS', 'sks': 3, 'kelas': 'IFB4B'},
      {'kode': '112200', 'nama': 'KECERDASAN BUATAN', 'sks': 3, 'kelas': 'IFB4B'},
      {'kode': '112700', 'nama': 'METODE NUMERIK', 'sks': 2, 'kelas': 'IFB4B'},
      {'kode': '010400', 'nama': 'METODOLOGI PENELITIAN', 'sks': 3, 'kelas': 'IFB4B'},
      {'kode': '113600', 'nama': 'REKAYASA PERANGKAT LUNAK', 'sks': 3, 'kelas': 'IFB4B'},
    ],
    '2026/2027_Ganjil': [
      {'kode': '110600', 'nama': 'JARINGAN NIRKABEL', 'sks': 3, 'kelas': 'IFB5A'},
      {'kode': '111000', 'nama': 'PEMROGRAMAN APLIKASI BERGERAK', 'sks': 3, 'kelas': 'IFB5A'},
      {'kode': '111100', 'nama': 'PENALARAN KOMPUTER', 'sks': 3, 'kelas': 'IFB5A'},
      {'kode': '000800', 'nama': 'PENULISAN DAN PUBLIKASI ILMIAH', 'sks': 2, 'kelas': 'IFB5A'},
      {'kode': '111300', 'nama': 'ROBOTIKA', 'sks': 3, 'kelas': 'IFB5J'},
      {'kode': '111400', 'nama': 'SIMULASI DAN GAME KOMPUTER', 'sks': 3, 'kelas': 'IFB5A'},
      {'kode': '111500', 'nama': 'SISTEM MANAJEMEN BASIS DATA', 'sks': 3, 'kelas': 'IFB5A'},
      {'kode': '111600', 'nama': 'TEKNOLOGI APLIKASI BERGERAK', 'sks': 3, 'kelas': 'IFB5A'},
    ],
  };

  void _prosesData() {
    setState(() {
      _isLoading = true;
      _isDataTampil = false;
    });
    
    // Simulasi loading 0.8 detik biar UI kerasa natural
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isDataTampil = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String keyData = '${_tahunTerpilih}_$_semesterTerpilih';
    List<Map<String, dynamic>>? dataKrs = _databaseKrs[keyData];
    
    // Hitung total SKS jika data tersedia
    int totalSks = 0;
    if (dataKrs != null) {
      for (var item in dataKrs) {
        totalSks += item['sks'] as int;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Kartu Rencana Studi', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- FILTER SECTION ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tahun Akademik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 6),
                          _buildDropdown(
                            value: _tahunTerpilih,
                            items: _listTahun,
                            onChanged: (val) {
                              setState(() {
                                _tahunTerpilih = val!;
                                _isDataTampil = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Semester', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 6),
                          _buildDropdown(
                            value: _semesterTerpilih,
                            items: _listSemester,
                            onChanged: (val) {
                              setState(() {
                                _semesterTerpilih = val!;
                                _isDataTampil = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _prosesData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Tampilkan Data KRS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          
          // --- HASIL SECTION ---
          Expanded(
            child: !_isDataTampil 
                ? _buildEmptyState() 
                : (dataKrs == null || dataKrs.isEmpty) 
                    ? _buildErrorState() 
                    : _buildListKrs(dataKrs),
          ),
          
          // --- FOOTER TOTAL SKS (Hanya tampil jika ada data) ---
          if (_isDataTampil && dataKrs != null && dataKrs.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Beban SKS:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$totalSks SKS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Silakan pilih filter dan klik Tampilkan', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // Tampilan ketika data kosong (Meniru persis peringatan di screenshot terakhir)
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text('DATA TIDAK TERSEDIA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 14)),
                  ],
                ),
                const Divider(height: 24),
                const Text('Mungkin disebabkan oleh:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Text('1) Belum ada data KRS pada Semester $_semesterTerpilih ${_tahunTerpilih.split('/')[0]}.', style: const TextStyle(fontSize: 13, height: 1.5)),
                Text('2) KRS Semester $_semesterTerpilih ${_tahunTerpilih.split('/')[0]} belum divalidasi (Silakan hubungi dosen PA).', style: const TextStyle(fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListKrs(List<Map<String, dynamic>> data) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final matkul = data[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                      child: Text('Kode: ${matkul['kode']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                    ),
                    Text('${matkul['sks']} SKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  matkul['nama'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.meeting_room_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text('Kelas: ${matkul['kelas']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}