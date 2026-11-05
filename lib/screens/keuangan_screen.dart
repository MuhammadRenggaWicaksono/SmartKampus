import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk fungsi Clipboard
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';

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

  /// Ambil angka dari string rupiah, mis. "-Rp 9.000.000" -> 9000000.
  int _angka(String teks) {
    final bersih = teks.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(bersih) ?? 0;
  }

  /// Sisa tagihan = total tagihan - total pembayaran.
  ///
  /// Sebelumnya nilai ini di-hardcode `'Total Tagihan: Rp 0'` sehingga tidak
  /// pernah berubah walau daftar transaksinya ditambah/dikurangi.
  int get _sisaTagihan {
    var tagihan = 0;
    var dibayar = 0;
    for (final t in _allTransactions) {
      final nilai = _angka(t['amount'] as String);
      if (t['isIncome'] as bool) {
        dibayar += nilai;
      } else {
        tagihan += nilai;
      }
    }
    final sisa = tagihan - dibayar;
    return sisa < 0 ? 0 : sisa;
  }

  String _rupiah(int nilai) {
    final teks = nilai.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < teks.length; i++) {
      if (i > 0 && (teks.length - i) % 3 == 0) buffer.write('.');
      buffer.write(teks[i]);
    }
    return 'Rp $buffer';
  }

  // Fungsi untuk menyalin nomor VA ke Clipboard & menampilkan SnackBar
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _vaNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
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
    return ThemeBuilder(
      builder: (context, p) {
        // Menentukan berapa banyak transaksi yang ditampilkan
        final visibleTransactions = _isExpanded
            ? _allTransactions
            : _allTransactions.take(3).toList();

        return Container(
          decoration: p.backgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    Text(
                      'Keuangan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: p.textPrimary,
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
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'VIRTUAL ACCOUNT BNI',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Badge Status Aktif
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '8001 2345 6789',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                              // Tombol Salin VA
                              InkWell(
                                onTap: _copyToClipboard,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.copy,
                                    color: Colors.white,
                                    size: 20,
                                  ),
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
                        Expanded(
                          child: Text(
                            'RIWAYAT TAGIHAN',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: p.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: p.chipBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Total Tagihan: ${_rupiah(_sisaTagihan)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _sisaTagihan == 0 ? p.success : p.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- LIST TRANSAKSI (EXPANDABLE) ---
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: p.cardDeco(),
                      child: Column(
                        children: [
                          // Render daftar transaksi yang terlihat
                          ...visibleTransactions.map(
                            (item) => _buildTransaction(
                              p,
                              item['title'],
                              item['subtitle'],
                              item['amount'],
                              item['balance'],
                              item['isIncome'],
                            ),
                          ),

                          Divider(height: 1, thickness: 0.5, color: p.divider),

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
                                  Flexible(
                                    child: Text(
                                      _isExpanded
                                          ? 'Sembunyikan Transaksi'
                                          : 'Lihat Semua Transaksi (${_allTransactions.length})',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: p.accentText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: p.accentText,
                                  ),
                                ],
                              ),
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
      },
    );
  }

  Widget _buildTransaction(
    AppPalette p,
    String title,
    String subtitle,
    String amount,
    String balance,
    bool isIncome,
  ) {
    final warna = isIncome ? kHadir : kAlpa;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // Sebelumnya Colors.green.shade50 / red.shade50 — nyaris hilang
          // di Dark Mode. Sekarang pakai alpha supaya tetap terlihat.
          color: warna.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isIncome ? Icons.payments : Icons.receipt_long,
          color: warna,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: p.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: p.textSecondary),
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
              color: warna,
            ),
          ),
          Text(balance, style: TextStyle(fontSize: 10, color: p.textSecondary)),
        ],
      ),
    );
  }
}
