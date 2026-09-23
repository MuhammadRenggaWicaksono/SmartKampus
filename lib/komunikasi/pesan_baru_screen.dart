import 'package:flutter/material.dart';

class PesanBaruScreen extends StatefulWidget {
  const PesanBaruScreen({super.key});

  @override
  State<PesanBaruScreen> createState() => _PesanBaruScreenState();
}

class _PesanBaruScreenState extends State<PesanBaruScreen> {
  // --- Controller & Variabel ---
  String? _tujuanTerpilih; // Awalnya null agar menampilkan '-----'
  
  final _penerimaSpesifikCtrl = TextEditingController(); // Untuk NIM atau Nama Dosen
  final _isiPesanCtrl = TextEditingController();

  final List<String> _pilihanTujuan = [
    'SIAM (MAHASISWA)',
    'SIMA (DOSEN)',
    'SIRAK (PROGRAM STUDI)'
  ];

  @override
  void dispose() {
    _penerimaSpesifikCtrl.dispose();
    _isiPesanCtrl.dispose();
    super.dispose();
  }

  void _kirimPesan() {
    // Validasi pengecekan form
    if (_tujuanTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tujuan kategori terlebih dahulu!'), backgroundColor: Colors.red));
      return;
    }
    if (_penerimaSpesifikCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Detail penerima (NIM/Nama) harus diisi!'), backgroundColor: Colors.red));
      return;
    }
    if (_isiPesanCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi pesan tidak boleh kosong!'), backgroundColor: Colors.red));
      return;
    }

    // TODO: Kirim data (_tujuanTerpilih, _penerimaSpesifikCtrl.text, _isiPesanCtrl.text) ke API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesan berhasil dikirim!'), backgroundColor: Colors.green),
    );
    
    // Reset form
    setState(() {
      _tujuanTerpilih = null;
      _penerimaSpesifikCtrl.clear();
      _isiPesanCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Pesan', style: TextStyle(color: Colors.black, fontSize: 18)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0.5,
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.inbox), text: 'Kotak Masuk'),
              Tab(icon: Icon(Icons.edit_square), text: 'Tulis Pesan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildKotakMasukTab(),
            _buildTulisPesanTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildKotakMasukTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.drafts_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Tidak Ada Pesan Masuk', style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Pesan dari dosen atau kampus akan muncul di sini', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildTulisPesanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tujuan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            // --- DROPDOWN KATEGORI ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _tujuanTerpilih,
                  hint: const Text('-----', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), // Sesuai website
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                  items: _pilihanTujuan.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _tujuanTerpilih = newValue;
                      _penerimaSpesifikCtrl.clear(); // Bersihkan text spesifik jika kategori diubah
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- KOLOM DINAMIS (Muncul sesuai pilihan dropdown) ---
            _buildKolomPenerimaDinamis(),

            const Text('Isi Pesan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            // --- FORM ISI PESAN ---
            TextFormField(
              controller: _isiPesanCtrl,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Tulis pesan Anda di sini...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
              ),
            ),
            const SizedBox(height: 24),

            // --- TOMBOL ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _tujuanTerpilih = null;
                        _penerimaSpesifikCtrl.clear();
                        _isiPesanCtrl.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _kirimPesan,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA MUNCULNYA KOLOM BARU ---
  Widget _buildKolomPenerimaDinamis() {
    // Jika belum memilih apapun, tidak ada kolom tambahan yang muncul
    if (_tujuanTerpilih == null) return const SizedBox.shrink();

    String labelText = '';
    String hintText = '';
    IconData iconData = Icons.person;
    TextInputType keyboardType = TextInputType.text;

    // Logika menyesuaikan UI textfield berdasarkan kategori
    if (_tujuanTerpilih == 'SIAM (MAHASISWA)') {
      labelText = 'NIM Mahasiswa';
      hintText = 'Ketik NIM Mahasiswa tujuan';
      iconData = Icons.badge_outlined;
      keyboardType = TextInputType.number; // Biar keyboard yang muncul angka
    } else if (_tujuanTerpilih == 'SIMA (DOSEN)') {
      labelText = 'Nama Lengkap Dosen';
      hintText = 'Ketik nama dosen beserta gelar';
      iconData = Icons.school_outlined;
    } else if (_tujuanTerpilih == 'SIRAK (PROGRAM STUDI)') {
      labelText = 'Dosen / Staf Program Studi';
      hintText = 'Ketik nama dosen tertentu';
      iconData = Icons.account_balance_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _penerimaSpesifikCtrl,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(iconData, color: Colors.blue),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
            ),
          ),
        ],
      ),
    );
  }
}