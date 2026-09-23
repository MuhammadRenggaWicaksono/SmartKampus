import 'package:flutter/material.dart';

class BiodataMahasiswaScreen extends StatefulWidget {
  const BiodataMahasiswaScreen({super.key});

  @override
  State<BiodataMahasiswaScreen> createState() => _BiodataMahasiswaScreenState();
}

class _BiodataMahasiswaScreenState extends State<BiodataMahasiswaScreen> {
  // Status apakah form bisa diedit atau tidak
  bool _isEditing = false;

  // Controllers untuk menyimpan data (Nanti data ini diisi dari API)
  final _namaCtrl = TextEditingController(text: 'Rengga');
  final _prodiCtrl = TextEditingController(text: 'Teknik Informatika (S1)');
  final _nimCtrl = TextEditingController(text: '2026101234');
  final _dosenCtrl = TextEditingController(text: 'Dr. Budi Santoso, M.Kom');
  final _emailOffCtrl = TextEditingController(text: 'rengga@student.kampus.ac.id');
  final _emailPersCtrl = TextEditingController(text: 'rengga.pribadi@gmail.com');
  final _tempatLahirCtrl = TextEditingController(text: 'Balikpapan');
  final _tglLahirCtrl = TextEditingController(text: '15 Agustus 2005');
  final _statusCtrl = TextEditingController(text: 'Mahasiswa Aktif');
  final _jkCtrl = TextEditingController(text: 'Laki-laki');
  final _agamaCtrl = TextEditingController(text: 'Islam');
  final _alamatAsalCtrl = TextEditingController(text: 'Jl. Sudirman No. 45, Balikpapan');
  final _alamatSkrgCtrl = TextEditingController(text: 'Kos Mawar, Jl. Kampus Raya No. 2');
  final _telpCtrl = TextEditingController(text: '081234567890');

  @override
  void dispose() {
    // Bersihkan memory saat halaman ditutup
    _namaCtrl.dispose();
    _prodiCtrl.dispose();
    _nimCtrl.dispose();
    _dosenCtrl.dispose();
    _emailOffCtrl.dispose();
    _emailPersCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _tglLahirCtrl.dispose();
    _statusCtrl.dispose();
    _jkCtrl.dispose();
    _agamaCtrl.dispose();
    _alamatAsalCtrl.dispose();
    _alamatSkrgCtrl.dispose();
    _telpCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // TODO: Taruh logika API untuk Update/Save data di sini
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan!'),
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
        title: const Text('Biodata Mahasiswa', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
        actions: [
          // Tombol Edit / Simpan di Kanan Atas
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
                    Expanded(child: Text('Mode edit aktif. Ubah data lalu tekan Simpan.', style: TextStyle(color: Colors.blue))),
                  ],
                ),
              ),

            // KELOMPOK 1: INFORMASI AKADEMIK
            _buildSectionTitle('INFORMASI AKADEMIK'),
            _buildCardGroup([
              _buildTextField('NIM', _nimCtrl, Icons.badge_outlined, isReadOnly: true), // NIM biasanya gak bisa diedit
              _buildTextField('Program Studi', _prodiCtrl, Icons.school_outlined, isReadOnly: true),
              _buildTextField('Status Registrasi', _statusCtrl, Icons.verified_user_outlined, isReadOnly: true),
              _buildTextField('Dosen Pembimbing Akademik', _dosenCtrl, Icons.supervisor_account_outlined, isReadOnly: true),
            ]),
            const SizedBox(height: 20),

            // KELOMPOK 2: DATA PRIBADI
            _buildSectionTitle('DATA PRIBADI'),
            _buildCardGroup([
              _buildTextField('Nama Lengkap', _namaCtrl, Icons.person_outline),
              _buildTextField('Tempat Lahir', _tempatLahirCtrl, Icons.location_city),
              _buildTextField('Tanggal Lahir', _tglLahirCtrl, Icons.calendar_today),
              _buildTextField('Jenis Kelamin', _jkCtrl, Icons.wc),
              _buildTextField('Agama', _agamaCtrl, Icons.favorite_border),
            ]),
            const SizedBox(height: 20),

            // KELOMPOK 3: KONTAK & ALAMAT
            _buildSectionTitle('KONTAK & ALAMAT'),
            _buildCardGroup([
              _buildTextField('Email (Official)', _emailOffCtrl, Icons.email_outlined, isReadOnly: true),
              _buildTextField('Email (Personal)', _emailPersCtrl, Icons.alternate_email),
              _buildTextField('Nomor Telepon', _telpCtrl, Icons.phone_outlined, keyboardType: TextInputType.phone),
              _buildTextField('Alamat Asal', _alamatAsalCtrl, Icons.home_outlined, maxLines: 2),
              _buildTextField('Alamat Sekarang', _alamatSkrgCtrl, Icons.location_on_outlined, maxLines: 2),
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
    bool isReadOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    // Jika data sifatnya "Read Only" (seperti NIM), maka tidak bisa diedit meski mode Edit menyala
    bool enabled = _isEditing && !isReadOnly;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: enabled ? Colors.black : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: enabled ? Colors.blue : Colors.grey.shade400),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade50,
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