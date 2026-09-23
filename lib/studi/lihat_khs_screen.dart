import 'package:flutter/material.dart';

class LihatKhsScreen extends StatefulWidget {
  const LihatKhsScreen({Key? key}) : super(key: key);

  @override
  State<LihatKhsScreen> createState() => _LihatKhsScreenState();
}

class _LihatKhsScreenState extends State<LihatKhsScreen> {
  String _tahunTerpilih = '2024/2025';
  String _semesterTerpilih = 'Ganjil';
  bool _isLoading = false;
  bool _isDataTampil = false;

  final List<String> _listTahun = ['2024/2025', '2025/2026', '2026/2027'];
  final List<String> _listSemester = ['Ganjil', 'Genap', 'Genap-P'];

  // --- DATABASE DUMMY DARI SCREENSHOT KHS ---
  final Map<String, dynamic> _databaseKhs = {
    '2024/2025_Ganjil': {
      'ips': 3.68,
      'ipk': 3.68,
      'total_sks': 23,
      'matkul': [
        {'kode': '110100', 'nama': 'ALGORITMA DAN PEMROGRAMAN', 'sks': 3, 'nilai': 'A'},
        {'kode': '000100', 'nama': 'BAHASA INDONESIA', 'sks': 2, 'nilai': 'A-'},
        {'kode': '110300', 'nama': 'BAHASA INGGRIS', 'sks': 3, 'nilai': 'B'},
        {'kode': '110401', 'nama': 'ETIKA PROFESI', 'sks': 2, 'nilai': 'A'},
        {'kode': '110501', 'nama': 'INTERAKSI MANUSIA DAN KOMPUTER', 'sks': 3, 'nilai': 'A'},
        {'kode': '110800', 'nama': 'LOGIKA INFORMATIKA', 'sks': 3, 'nilai': 'A-'},
        {'kode': '110900', 'nama': 'MATEMATIKA I', 'sks': 2, 'nilai': 'B'},
        {'kode': '000400', 'nama': 'PANCASILA', 'sks': 2, 'nilai': 'B+'},
        {'kode': '001000', 'nama': 'TEKNOLOGI INFORMASI', 'sks': 3, 'nilai': 'A'},
      ]
    },
  };

  void _prosesData() {
    setState(() {
      _isLoading = true;
      _isDataTampil = false;
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isDataTampil = true;
        });
      }
    });
  }

  void _cetakPdf() {
    // Tampilkan notifikasi loading unduh PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.picture_as_pdf, color: Colors.white),
            SizedBox(width: 12),
            Text('Menyiapkan dokumen PDF...'),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulasi file berhasil diunduh setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KHS berhasil diunduh: KHS_2411044_Ganjil_2024.pdf'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  // Fungsi pembantu warna badge nilai
  Color _getWarnaNilai(String nilai) {
    if (nilai.startsWith('A')) return Colors.green;
    if (nilai.startsWith('B')) return Colors.blue;
    if (nilai.startsWith('C')) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    String keyData = '${_tahunTerpilih}_$_semesterTerpilih';
    Map<String, dynamic>? dataKhs = _databaseKhs[keyData];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Kartu Hasil Studi', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        centerTitle: true,
      ),
      
      // Menampilkan tombol Print PDF hanya jika data tersedia
      floatingActionButton: _isDataTampil && dataKhs != null
          ? FloatingActionButton.extended(
              onPressed: _cetakPdf,
              backgroundColor: Colors.red.shade700,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Cetak PDF', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,

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
                      : const Text('Tampilkan Data KHS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          
          // --- HASIL SECTION ---
          Expanded(
            child: !_isDataTampil 
                ? _buildEmptyState() 
                : (dataKhs == null) 
                    ? _buildErrorState() 
                    : _buildListKhs(dataKhs),
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
          Icon(Icons.school_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('Silakan pilih filter dan klik Tampilkan', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_page_break_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Data KHS Tidak Tersedia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Belum ada data nilai untuk Semester $_semesterTerpilih $_tahunTerpilih.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildListKhs(Map<String, dynamic> data) {
    List matkulList = data['matkul'];

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // Bottom padding extra for FAB
      children: [
        // --- PROFIL MAHASISWA & IPK ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade800,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MUHAMMAD RENGGA WICAKSONO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('NIM: 2411044  |  $_semesterTerpilih $_tahunTerpilih', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Divider(color: Colors.white24, height: 24, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('IPS', data['ips'].toString()),
                  _buildStatColumn('IPK', data['ipk'].toString()),
                  _buildStatColumn('SKS', data['total_sks'].toString()),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        Text('Detail Nilai Mata Kuliah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 12),

        // --- LIST MATA KULIAH ---
        ...matkulList.map((matkul) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(matkul['nama'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text('Kode: ${matkul['kode']}  •  ${matkul['sks']} SKS', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ),
              trailing: Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _getWarnaNilai(matkul['nilai']).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _getWarnaNilai(matkul['nilai']).withOpacity(0.5), width: 2),
                ),
                child: Text(
                  matkul['nilai'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getWarnaNilai(matkul['nilai']),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}