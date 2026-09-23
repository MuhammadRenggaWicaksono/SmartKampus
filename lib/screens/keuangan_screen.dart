import 'package:flutter/material.dart';

class KeuanganScreen extends StatelessWidget {
  const KeuanganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            const Text(
              'Keuangan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 24),

            // Card Virtual Account
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.account_balance, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('VIRTUAL ACCOUNT BNI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('8001 2345 6789', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: () {},
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Riwayat Tagihan Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RIWAYAT TAGIHAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                  child: const Text('Total: -Rp 3.000.000', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                )
              ],
            ),
            const SizedBox(height: 12),

            // List Transaksi
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildTransaction('UKT S1 IF Pagi Gel II', '6 Sep 2024 • Ganjil', '-Rp 9.000.000', 'Saldo: -Rp 9.000.000', false),
                  _buildTransaction('Pembayaran TF MB...', '8 Sep 2024', '+Rp 9.000.000', 'Saldo: Rp 0', true),
                  _buildTransaction('UKT S1 IF Pagi Gel II', '10 Feb 2025 • Genap', '-Rp 8.500.000', 'Saldo: -Rp 8.500.000', false),
                  _buildTransaction('Pembayaran Via BNI', '14 Feb 2025', '+Rp 8.500.000', 'Saldo: Rp 0', true),
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFF1F5F9)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Lihat Semua Transaksi', style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransaction(String title, String subtitle, String amount, String balance, bool isIncome) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isIncome ? Colors.green.shade50 : Colors.red.shade50, shape: BoxShape.circle),
        child: Icon(isIncome ? Icons.payments : Icons.receipt_long, color: isIncome ? Colors.green : Colors.red, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isIncome ? Colors.green : Colors.red)),
          Text(balance, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}