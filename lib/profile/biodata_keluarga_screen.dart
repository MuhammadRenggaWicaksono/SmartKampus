import 'package:flutter/material.dart';

class BiodataKeluargaScreen extends StatefulWidget {
  const BiodataKeluargaScreen({super.key});

  @override
  State<BiodataKeluargaScreen> createState() => _BiodataKeluargaScreenState();
}

class _BiodataKeluargaScreenState extends State<BiodataKeluargaScreen> {
  // Status edit
  bool _isEditing = false;

  // Controllers untuk menyimpan data (Bisa diisi dari API nanti)
  final _namaAyahCtrl = TextEditingController(text: 'Budi Santoso');
  final _pekerjaanAyahCtrl = TextEditingController(text: 'Pegawai Negeri Sipil (PNS)');
  final _penghasilanAyahCtrl = TextEditingController(text: 'Rp 5.000.000 - Rp 10.000.000');
  
  final _namaIbuCtrl = TextEditingController(text: 'Siti Aminah');
  final _pekerjaanIbuCtrl = TextEditingController(text: 'Ibu Rumah Tangga');
  final _penghasilanIbuCtrl = TextEditingController(text: '< Rp 1.000.000');

  @override
  void dispose() {
    // Bersihkan memory
    _namaAyahCtrl.dispose();
    _pekerjaanAyahCtrl.dispose();
    _penghasilanAyahCtrl.dispose();
    _namaIbuCtrl.dispose();
    _pekerjaanIbuCtrl.dispose();
    _penghasilanIbuCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // TODO: Taruh logika API untuk Update/Save data keluarga di sini
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data keluarga berhasil disimpan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Biodata Keluarga', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
        actions: [
          TextButton.icon(
            onPressed: _toggleEdit,
            icon: Icon(
              _isEditing ? Icons.check_circle : Icons.edit,
              color: _isEditing ? Colors.green : Colors.blue,
            ),
            label: Text(
              _isEditing ? 'Simpan' : 'Edit',
              style: TextStyle(
                color: _isEditing ? Colors.green : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(child: Text('Ubah data orang tua lalu tekan Simpan.', style: TextStyle(color: Colors.blue))),
                  ],
                ),
              ),

            // KELOMPOK 1: DATA AYAH
            _buildSectionTitle('DATA AYAH KANDUNG'),
            _buildCardGroup([
              _buildTextField('Nama Ayah', _namaAyahCtrl, Icons.person_outline),
              _buildTextField('Pekerjaan Ayah', _pekerjaanAyahCtrl, Icons.work_outline),
              _buildTextField('Penghasilan Ayah', _penghasilanAyahCtrl, Icons.monetization_on_outlined, keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: 20),

            // KELOMPOK 2: DATA IBU
            _buildSectionTitle('DATA IBU KANDUNG'),
            _buildCardGroup([
              _buildTextField('Nama Ibu', _namaIbuCtrl, Icons.person_outline),
              _buildTextField('Pekerjaan Ibu', _pekerjaanIbuCtrl, Icons.work_outline),
              _buildTextField('Penghasilan Ibu', _penghasilanIbuCtrl, Icons.monetization_on_outlined, keyboardType: TextInputType.number),
            ]),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Header tiap kelompok
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  // Kartu putih pembungkus form
  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Desain Form Field
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing, // Hanya bisa diisi jika _isEditing true
        keyboardType: keyboardType,
        style: TextStyle(
          color: _isEditing ? Colors.black : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: _isEditing ? Colors.blue : Colors.grey.shade400),
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }
}