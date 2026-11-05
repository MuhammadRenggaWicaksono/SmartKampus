import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/main_screen.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/supabase_config.dart';
import 'package:app_kampus/data/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _memuat = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Format email belum benar.');
      return;
    }
    if (!SupabaseService.siap) {
      setState(
        () => _error =
            'Supabase belum terhubung. Isi dulu '
            'lib/data/supabase_config.dart, atau pakai Mode Demo.',
      );
      return;
    }

    setState(() {
      _memuat = true;
      _error = null;
    });

    final pesan = await SupabaseService.masuk(email: email, password: password);

    if (!mounted) return;

    if (pesan != null) {
      setState(() {
        _memuat = false;
        _error = pesan;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _modeDemo() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kampus Pintar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masuk untuk mengakses layanan akademik',
                      style: TextStyle(color: p.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    _buildKartuLogin(p),
                    const SizedBox(height: 18),
                    TextButton.icon(
                      onPressed: _memuat ? null : _modeDemo,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Masuk Mode Demo (data dummy)'),
                      style: TextButton.styleFrom(
                        foregroundColor: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // JANGAN pakai `dynamic p` di sini. Dengan dynamic, literal `radius: 20`
  // dikirim sebagai int (tanpa konversi int->double), lalu meledak saat
  // runtime: "type 'int' is not a subtype of type 'double' of 'radius'".
  Widget _buildKartuLogin(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: p.cardDeco(radius: 20),
      child: Column(
        children: [
          if (!SupabaseConfig.terkonfigurasi) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Supabase belum dikonfigurasi. Isi Project URL dan anon '
                      'key di lib/data/supabase_config.dart, atau masuk lewat '
                      'Mode Demo di bawah.',
                      style: TextStyle(fontSize: 11.5, color: p.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'nama@kampus.ac.id',
              prefixIcon: const Icon(Icons.mail_outline, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 18),

          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _memuat ? null : _masuk(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _memuat ? null : _masuk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _memuat
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
