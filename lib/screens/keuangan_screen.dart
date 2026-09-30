import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk fungsi Clipboard
import 'package:app_kampus/theme_notifier.dart';// Import pusat tema global

class KeuanganScreen extends StatefulWidget {
  const KeuanganScreen({super.key});

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> {
  // Status untuk mengontrol apakah daftar transaksi diperpanjang atau tidak
  bool _isExpanded = false;

  // Nomor VA BNI asli (tanpa spasi untuk disalin)
  final String _vaNumber = '800123456789';

  // Master Data Riwayat Transaksi
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'UKT S1 IF Pagi Gel II',
      'subtitle': '6 Sep 2024 • Ganjil',
      'amount': '-Rp 9.000.000',
      'balance': 'Saldo: -Rp 9.000.000',
      'isIncome': false,
    },
    {
      'title': 'Pembayaran TF MB...',
      'subtitle': '8 Sep 2024',
      'amount': '+Rp 9.000.000',
      'balance': 'Saldo: Rp 0',
      'isIncome': true,
    },
    {
      'title': 'UKT S1 IF Pagi Gel II',
      'subtitle': '10 Feb 2025 • Genap',
      'amount': '-Rp 8.500.000',
      'balance': 'Saldo: -Rp 8.500.000',
      'isIncome': false,
    },
    {
      'title': 'Pembayaran Via BNI',
      'subtitle': '14 Feb 2025',
      'amount': '+Rp 8.500.000',
      'balance': 'Saldo: Rp 0',
      'isIncome': true,
    },
    // Transaksi tambahan yang muncul saat tombol "Lihat Semua" ditekan
    {
      'title': 'Biaya Praktikum Lab',
      'subtitle': '20 Ags 2025 • Ganjil',
      'amount': '-Rp 500.000',
      'balance': 'Saldo: -Rp 500.000',
      'isIncome': false,
    },
    {
      'title': 'Pembayaran Via BNI',
      'subtitle': '21 Ags 2025',
      'amount': '+Rp 500.000',
      'balance': 'Saldo: Rp 0',
      'isIncome': true,
    },
    {
      'title': 'Denda Keterlambatan KRS',
      'subtitle': '15 Sep 2025',
      'amount': '-Rp 100.000',
      'balance': 'Saldo: -Rp 100.000',
      'isIncome': false,
    },
    {
      'title': 'Pembayaran Via BNI',
      'subtitle': '16 Sep 2025',
      'amount': '+Rp 100.000',
      'balance': 'Saldo: Rp 0',
      'isIncome': true,
    },
  ];

  // Fungsi untuk menyalin nomor VA ke Clipboard & menampilkan SnackBar
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _vaNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Nomor VA BNI berhasil disalin!'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, currentTheme, child) {
        // Penyesuaian Warna Tema (Light, Dark, LGBT)
        final bool isDark = currentTheme == AppThemeMode.dark;
        final bool isLgbt = currentTheme == AppThemeMode.lgbt;

        final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
        final Color subTextColor = isDark ? Colors.grey.shade400 : const Color(0xFF94A3B8);
        final Color cardColor = isDark
            ? const Color(0xFF1E1E1E)
            : (isLgbt ? Colors.white.withOpacity(0.85) : Colors.white);

        // Menentukan berapa banyak transaksi yang ditampilkan
        final visibleTransactions =
            _isExpanded ? _allTransactions : _allTransactions.take(3).toList();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              children: [
                Text(
                  'Keuangan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),

                // --- CARD VIRTUAL ACCOUNT BNI ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.account_balance, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'VIRTUAL ACCOUNT BNI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          // Badge Status Aktif
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'AKTIF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '8001 2345 6789',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          // Tombol Salin VA
                          InkWell(
                            onTap: _copyToClipboard,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.copy, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- HEADER RIWAYAT TAGIHAN ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RIWAYAT TAGIHAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: subTextColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Total Tagihan: Rp 0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.greenAccent : Colors.black54,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                // --- LIST TRANSAKSI (EXPANDABLE) ---
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Render daftar transaksi yang terlihat
                      ...visibleTransactions.map((item) {
                        return _buildTransaction(
                          item['title'],
                          item['subtitle'],
                          item['amount'],
                          item['balance'],
                          item['isIncome'],
                          textColor,
                          subTextColor,
                        );
                      }),

                      const Divider(height: 1, thickness: 0.5, color: Color(0xFFF1F5F9)),

                      // Tombol Toggle "Lihat Semua" / "Sembunyikan"
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isExpanded
                                    ? 'Sembunyikan Transaksi'
                                    : 'Lihat Semua Transaksi (${_allTransactions.length})',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.blue.shade600,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransaction(
    String title,
    String subtitle,
    String amount,
    String balance,
    bool isIncome,
    Color textColor,
    Color subTextColor,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isIncome ? Icons.payments : Icons.receipt_long,
          color: isIncome ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: subTextColor),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          Text(
            balance,
            style: TextStyle(fontSize: 10, color: subTextColor),
          ),
        ],
      ),
    );
  }
}