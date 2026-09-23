import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Ganti Password', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // KARTU FORM
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AKUN (NIM) - Read Only
                  const Text('AKUN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nimCtrl,
                    enabled: false,
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.badge, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PASSWORD LAMA
                  const Text('PASSWORD LAMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildPasswordField('Masukkan password lama', _oldPassCtrl, _obscureOld, () {
                    setState(() => _obscureOld = !_obscureOld);
                  }),
                  const SizedBox(height: 20),

                  // PASSWORD BARU
                  const Text('PASSWORD BARU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildPasswordField('Masukkan password baru', _newPassCtrl, _obscureNew, () {
                    setState(() => _obscureNew = !_obscureNew);
                  }),
                  const SizedBox(height: 20),

                  // RE-PASSWORD BARU
                  const Text('ULANGI PASSWORD BARU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildPasswordField('Ketik ulang password baru', _confirmPassCtrl, _obscureConfirm, () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // KARTU PERHATIAN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PERHATIAN', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        Text('Catat dan simpan dengan baik password baru Anda.', style: TextStyle(color: Colors.orange, fontSize: 13)),
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
    );
  }

  // Widget khusus untuk form password (ada tombol mata)
  Widget _buildPasswordField(String hint, TextEditingController controller, bool isObscure, VoidCallback toggleObscure) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: toggleObscure,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
      ),
    );
  }
}