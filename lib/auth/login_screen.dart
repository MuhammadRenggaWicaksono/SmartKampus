import 'package:flutter/material.dart';
import 'package:app_kampus/core/main_screen.dart'; // Kita akan arahkan ke MainScreen jika berhasil login

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nimCtrl = TextEditingController(text: '2411044'); // Default NIM terisi
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  void _loginLangsung() {
    // Bypass login, langsung masuk ke aplikasi utama
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / Icon Kampus
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.school, size: 80, color: Colors.blue),
                ),
                const SizedBox(height: 24),
                const Text('Kampus Pintar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 8),
                const Text('Masuk untuk mengakses layanan akademik', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),

                // Form Login
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      // Form NIM
                      TextFormField(
                        controller: _nimCtrl,
                        decoration: InputDecoration(
                          labelText: 'NIM',
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form Password
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        decoration: InputDecoration(
                          labelText: 'Password (Abaikan dulu)',
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Tombol Login
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loginLangsung, // Tombol ini langsung bypass ke MainScreen
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}