import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';

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
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Biodata Keluarga', style: TextStyle(color: p.textPrimary, fontSize: 18)),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
            actions: [
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
                        Expanded(child: Text('Ubah data orang tua lalu tekan Simpan.', style: TextStyle(color: p.accentText))),
                      ],
                    ),
                  ),

                // KELOMPOK 1: DATA AYAH
                _buildSectionTitle('DATA AYAH KANDUNG', p),
                _buildCardGroup(p, [
                  _buildTextField(p, 'Nama Ayah', _namaAyahCtrl, Icons.person_outline),
                  _buildTextField(p, 'Pekerjaan Ayah', _pekerjaanAyahCtrl, Icons.work_outline),
                  _buildTextField(p, 'Penghasilan Ayah', _penghasilanAyahCtrl, Icons.monetization_on_outlined, keyboardType: TextInputType.number),
                ]),
                const SizedBox(height: 20),

                // KELOMPOK 2: DATA IBU
                _buildSectionTitle('DATA IBU KANDUNG', p),
                _buildCardGroup(p, [
                  _buildTextField(p, 'Nama Ibu', _namaIbuCtrl, Icons.person_outline),
                  _buildTextField(p, 'Pekerjaan Ibu', _pekerjaanIbuCtrl, Icons.work_outline),
                  _buildTextField(p, 'Penghasilan Ibu', _penghasilanIbuCtrl, Icons.monetization_on_outlined, keyboardType: TextInputType.number),
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
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing, // Hanya bisa diisi jika _isEditing true
        keyboardType: keyboardType,
        style: TextStyle(
          color: _isEditing ? p.textPrimary : p.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: p.textSecondary),
          prefixIcon: Icon(icon, color: _isEditing ? p.accent : p.textSecondary),
          filled: true,
          fillColor: _isEditing ? p.inputFill : p.surfaceAlt,
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
