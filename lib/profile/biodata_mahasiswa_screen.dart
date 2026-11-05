import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';

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
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Biodata Mahasiswa', style: TextStyle(color: p.textPrimary, fontSize: 18)),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
            actions: [
              // Tombol Edit / Simpan di Kanan Atas
              TextButton.icon(
                onPressed: _toggleEdit,
                icon: Icon(
                  _isEditing ? Icons.check_circle : Icons.edit,
                  color: _isEditing ? p.success : p.accentText,
                ),
                label: Text(
                  _isEditing ? 'Simpan' : 'Edit',
                  style: TextStyle(
                    color: _isEditing ? p.success : p.accentText,
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
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: p.accentText),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Mode edit aktif. Ubah data lalu tekan Simpan.', style: TextStyle(color: p.accentText))),
                      ],
                    ),
                  ),

                // KELOMPOK 1: INFORMASI AKADEMIK
                _buildSectionTitle('INFORMASI AKADEMIK', p),
                _buildCardGroup(p, [
                  _buildTextField(p, 'NIM', _nimCtrl, Icons.badge_outlined, isReadOnly: true), // NIM biasanya gak bisa diedit
                  _buildTextField(p, 'Program Studi', _prodiCtrl, Icons.school_outlined, isReadOnly: true),
                  _buildTextField(p, 'Status Registrasi', _statusCtrl, Icons.verified_user_outlined, isReadOnly: true),
                  _buildTextField(p, 'Dosen Pembimbing Akademik', _dosenCtrl, Icons.supervisor_account_outlined, isReadOnly: true),
                ]),
                const SizedBox(height: 20),

                // KELOMPOK 2: DATA PRIBADI
                _buildSectionTitle('DATA PRIBADI', p),
                _buildCardGroup(p, [
                  _buildTextField(p, 'Nama Lengkap', _namaCtrl, Icons.person_outline),
                  _buildTextField(p, 'Tempat Lahir', _tempatLahirCtrl, Icons.location_city),
                  _buildTextField(p, 'Tanggal Lahir', _tglLahirCtrl, Icons.calendar_today),
                  _buildTextField(p, 'Jenis Kelamin', _jkCtrl, Icons.wc),
                  _buildTextField(p, 'Agama', _agamaCtrl, Icons.favorite_border),
                ]),
                const SizedBox(height: 20),

                // KELOMPOK 3: KONTAK & ALAMAT
                _buildSectionTitle('KONTAK & ALAMAT', p),
                _buildCardGroup(p, [
                  _buildTextField(p, 'Email (Official)', _emailOffCtrl, Icons.email_outlined, isReadOnly: true),
                  _buildTextField(p, 'Email (Personal)', _emailPersCtrl, Icons.alternate_email),
                  _buildTextField(p, 'Nomor Telepon', _telpCtrl, Icons.phone_outlined, keyboardType: TextInputType.phone),
                  _buildTextField(p, 'Alamat Asal', _alamatAsalCtrl, Icons.home_outlined, maxLines: 2),
                  _buildTextField(p, 'Alamat Sekarang', _alamatSkrgCtrl, Icons.location_on_outlined, maxLines: 2),
                ]),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header tiap kelompok
  Widget _buildSectionTitle(String title, AppPalette p) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: p.textSecondary),
      ),
    );
  }

  // Kartu pembungkus form
  Widget _buildCardGroup(AppPalette p, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(radius: 16),
      child: Column(children: children),
    );
  }

  // Desain Form Field
  Widget _buildTextField(
    AppPalette p,
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
          color: enabled ? p.textPrimary : p.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: p.textSecondary),
          prefixIcon: Icon(icon, color: enabled ? p.accent : p.textSecondary),
          filled: true,
          fillColor: enabled ? p.inputFill : p.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: p.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: p.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: p.accent, width: 2),
          ),
        ),
      ),
    );
  }
}
