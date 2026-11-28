import 'package:flutter/material.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/lms/providers/lms_session.dart';
import 'package:app_kampus/lms/services/moodle_api_service.dart';

/// Halaman login LMS Moodle kampus.
///
/// Menukar NIM/username + password menjadi token lewat `/login/token.php`,
/// lalu menyimpan tokennya (password tidak pernah disimpan). Setelah sesi
/// tersimpan, [lmsSession] memberi tahu layar gerbang untuk menampilkan
/// beranda daftar kelas.
class LmsLoginScreen extends StatefulWidget {
  const LmsLoginScreen({super.key});

  @override
  State<LmsLoginScreen> createState() => _LmsLoginScreenState();
}

class _LmsLoginScreenState extends State<LmsLoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _sandi = TextEditingController();
  final MoodleApiService _api = MoodleApiService();

  bool _sibuk = false;
  bool _lihatSandi = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _sandi.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    final username = _username.text.trim();
    final sandi = _sandi.text;
    if (username.isEmpty || sandi.isEmpty) {
      setState(() => _error = 'NIM dan kata sandi wajib diisi.');
      return;
    }

    setState(() {
      _sibuk = true;
      _error = null;
    });

    try {
      final token = await _api.login(username: username, password: sandi);
      final user = await _api.getSiteInfo(token);
      await lmsSession.simpan(token, user);
      // Layar gerbang (LmsEntryScreen) mendengarkan lmsSession dan otomatis
      // berpindah ke beranda setelah ini.
    } on MoodleException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Gagal terhubung ke LMS kampus. Cek koneksi.');
      }
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) {
        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'LMS Kampus',
                style: TextStyle(color: p.textPrimary, fontSize: 18),
              ),
              backgroundColor: p.card,
              foregroundColor: p.textPrimary,
              iconTheme: IconThemeData(color: p.textPrimary),
              elevation: 0.5,
            ),
            body: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _kartu(p),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _kartu(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: p.cardDeco(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school_outlined, color: p.accent, size: 32),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Masuk ke LMS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gunakan akun Moodle Lentera Universitas Mulia',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: p.textCardSupport),
          ),
          const SizedBox(height: 24),
          _field(
            p,
            controller: _username,
            label: 'NIM / Username',
            icon: Icons.person_outline,
            enabled: !_sibuk,
          ),
          const SizedBox(height: 14),
          _field(
            p,
            controller: _sandi,
            label: 'Kata Sandi',
            icon: Icons.lock_outline,
            enabled: !_sibuk,
            obscure: !_lihatSandi,
            suffix: IconButton(
              icon: Icon(
                _lihatSandi ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: p.textMuted,
              ),
              onPressed: () => setState(() => _lihatSandi = !_lihatSandi),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 18, color: p.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(fontSize: 12.5, color: p.danger),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _sibuk ? null : _masuk,
              style: ElevatedButton.styleFrom(
                backgroundColor: p.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: p.accent.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _sibuk
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    AppPalette p, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      textInputAction: TextInputAction.next,
      style: TextStyle(color: p.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: p.textCardSupport, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: p.textMuted),
        suffixIcon: suffix,
        filled: true,
        fillColor: p.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.accent, width: 1.6),
        ),
      ),
    );
  }
}
