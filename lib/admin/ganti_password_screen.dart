import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';

class GantiPasswordScreen extends StatefulWidget {
  const GantiPasswordScreen({super.key});

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final _nimCtrl = TextEditingController(text: '2411044');
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // Status untuk menampilkan/menyembunyikan password
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nimCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _simpanPassword() {
    // Validasi sederhana
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom password harus diisi!'), backgroundColor: Colors.red));
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password baru tidak cocok!'), backgroundColor: Colors.red));
      return;
    }

    // TODO: Kirim data ke API ganti password
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah!'), backgroundColor: Colors.green));
    Navigator.pop(context); // Kembali ke halaman akun
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Ganti Password', style: TextStyle(color: p.textPrimary, fontSize: 18)),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // KARTU FORM
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: p.cardDeco(radius: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AKUN (NIM) - Read Only
                      Text('AKUN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: p.textSecondary)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nimCtrl,
                        enabled: false,
                        style: TextStyle(color: p.textSecondary, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.badge, color: p.textSecondary),
                          filled: true,
                          fillColor: p.inputFill,
                          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // PASSWORD LAMA
                      Text('PASSWORD LAMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: p.textSecondary)),
                      const SizedBox(height: 8),
                      _buildPasswordField(p, 'Masukkan password lama', _oldPassCtrl, _obscureOld, () {
                        setState(() => _obscureOld = !_obscureOld);
                      }),
                      const SizedBox(height: 20),

                      // PASSWORD BARU
                      Text('PASSWORD BARU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: p.textSecondary)),
                      const SizedBox(height: 8),
                      _buildPasswordField(p, 'Masukkan password baru', _newPassCtrl, _obscureNew, () {
                        setState(() => _obscureNew = !_obscureNew);
                      }),
                      const SizedBox(height: 20),

                      // RE-PASSWORD BARU
                      Text('ULANGI PASSWORD BARU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: p.textSecondary)),
                      const SizedBox(height: 8),
                      _buildPasswordField(p, 'Ketik ulang password baru', _confirmPassCtrl, _obscureConfirm, () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // KARTU PERHATIAN
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PERHATIAN', style: TextStyle(color: p.warning, fontWeight: FontWeight.bold)),
                            Text('Catat dan simpan dengan baik password baru Anda.', style: TextStyle(color: p.warning, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // TOMBOL SIMPAN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _simpanPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Simpan Password Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget khusus untuk form password (ada tombol mata)
  Widget _buildPasswordField(AppPalette p, String hint, TextEditingController controller, bool isObscure, VoidCallback toggleObscure) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.textSecondary, fontSize: 14),
        prefixIcon: Icon(Icons.lock_outline, color: p.accent),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: p.textSecondary),
          onPressed: toggleObscure,
        ),
        filled: true,
        fillColor: p.inputFill,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.accent, width: 2)),
      ),
    );
  }
}
