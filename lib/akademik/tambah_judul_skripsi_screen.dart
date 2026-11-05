import 'package:flutter/material.dart';
import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/skripsi_store.dart';

/// Form "TAMBAH JUDUL SKRIPSI".
///
/// Mengikuti acuan web kampus: judul skripsi + 3 link berkas, dengan aturan
/// minimal 1 berkas terisi dan berkas 2 & 3 diisi "-" kalau tidak ada.
/// Untuk aplikasi mobile, label dipindah ke ATAS kolom input (bukan di
/// samping seperti versi web) supaya tidak sesak di layar sempit, dan tiap
/// kolom diberi penanda Wajib / Opsional.
class TambahJudulSkripsiScreen extends StatefulWidget {
  const TambahJudulSkripsiScreen({super.key});

  @override
  State<TambahJudulSkripsiScreen> createState() =>
      _TambahJudulSkripsiScreenState();
}

class _TambahJudulSkripsiScreenState extends State<TambahJudulSkripsiScreen> {
  static const Color warnaSimpan = Color(0xFF22C55E);

  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _berkas1Ctrl = TextEditingController();
  final _berkas2Ctrl = TextEditingController();
  final _berkas3Ctrl = TextEditingController();

  @override
  void dispose() {
    _judulCtrl.dispose();
    _berkas1Ctrl.dispose();
    _berkas2Ctrl.dispose();
    _berkas3Ctrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- validasi
  bool _terlihatSepertiTautan(String teks) {
    final t = teks.trim();
    if (t.isEmpty || t.contains(' ')) return false;
    final kecil = t.toLowerCase();
    if (kecil.startsWith('http://') || kecil.startsWith('https://')) return true;
    return t.contains('.') && t.length > 3;
  }

  String? _validasiJudul(String? nilai) {
    final teks = (nilai ?? '').trim();
    if (teks.isEmpty) return 'Judul skripsi wajib diisi.';
    if (teks.length < 10) return 'Judul minimal 10 karakter.';
    return null;
  }

  String? _validasiBerkasUtama(String? nilai) {
    final teks = (nilai ?? '').trim();
    if (teks.isEmpty) return 'Minimal Link Berkas 1 wajib diisi.';
    if (teks == '-') return "Link Berkas 1 tidak boleh '-'.";
    if (!_terlihatSepertiTautan(teks)) {
      return 'Masukkan tautan yang valid, contoh: https://drive.google.com/...';
    }
    return null;
  }

  String? _validasiBerkasOpsional(String? nilai) {
    final teks = (nilai ?? '').trim();
    if (teks.isEmpty || teks == '-') return null;
    if (!_terlihatSepertiTautan(teks)) {
      return 'Masukkan tautan yang valid, atau isi dengan "-".';
    }
    return null;
  }

  /// Kolom opsional yang dikosongkan otomatis diisi "-" sesuai aturan kampus.
  String _kosongJadiMinus(String teks) {
    final t = teks.trim();
    return t.isEmpty ? '-' : t;
  }

  void _simpan() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali isian yang ditandai merah.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    SkripsiStore.tambah(
      PengajuanSkripsi(
        judul: _judulCtrl.text.trim(),
        berkas1: _berkas1Ctrl.text.trim(),
        berkas2: _kosongJadiMinus(_berkas2Ctrl.text),
        berkas3: _kosongJadiMinus(_berkas3Ctrl.text),
        diajukan: DateTime.now(),
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder: (context, p) => Container(
        decoration: p.backgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Tambah Judul Skripsi',
              style: TextStyle(color: p.textPrimary, fontSize: 18),
            ),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
          ),
          body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  'TAMBAH JUDUL SKRIPSI',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildPesan(p),
                const SizedBox(height: 20),
                _buildBagianForm(p),
              ],
            ),
          ),
          bottomNavigationBar: _buildFooter(p),
        ),
      ),
    );
  }

  // ----------------------------------------------------------- blok pesan
  Widget _buildPesan(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(
                'Message',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: p.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPoin(p, 'Mohon melengkapi isian link berkas, minimal 1 pengisian.'),
          const SizedBox(height: 6),
          _buildPoin(
            p,
            'Jika link berkas 2 dan 3 tidak ada mohon isi dengan karakter "-" / minus.',
          ),
        ],
      ),
    );
  }

  Widget _buildPoin(AppPalette p, String teks) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            teks,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: p.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- isian form
  Widget _buildBagianForm(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(p, 'Judul Skripsi', wajib: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _judulCtrl,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            validator: _validasiJudul,
            style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            decoration: _dekorasi(
              p,
              hint: 'Tuliskan judul lengkap beserta objek penelitian',
              ikon: Icons.title,
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel(p, 'Link Berkas 1', wajib: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _berkas1Ctrl,
            keyboardType: TextInputType.url,
            validator: _validasiBerkasUtama,
            style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            decoration: _dekorasi(
              p,
              hint: 'https://drive.google.com/...',
              ikon: Icons.link,
              bantuan: 'Wajib diisi. Berkas pendukung judul (proposal / jurnal).',
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel(p, 'Link Berkas 2', opsional: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _berkas2Ctrl,
            keyboardType: TextInputType.url,
            validator: _validasiBerkasOpsional,
            style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            decoration: _dekorasi(
              p,
              hint: 'https://drive.google.com/...',
              ikon: Icons.link,
              bantuan: 'Boleh dikosongkan — otomatis diisi "-" saat disimpan.',
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel(p, 'Link Berkas 3', opsional: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _berkas3Ctrl,
            keyboardType: TextInputType.url,
            validator: _validasiBerkasOpsional,
            style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            decoration: _dekorasi(
              p,
              hint: 'https://drive.google.com/...',
              ikon: Icons.link,
              bantuan: 'Boleh dikosongkan — otomatis diisi "-" saat disimpan.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(
    AppPalette p,
    String teks, {
    bool wajib = false,
    bool opsional = false,
  }) {
    return Row(
      children: [
        Text(
          teks,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: p.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        if (wajib)
          _buildPil(p, 'Wajib', Colors.red)
        else if (opsional)
          _buildPil(p, 'Opsional', p.textMuted),
      ],
    );
  }

  Widget _buildPil(AppPalette p, String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        teks,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: warna,
        ),
      ),
    );
  }

  InputDecoration _dekorasi(
    AppPalette p, {
    required String hint,
    required IconData ikon,
    String? bantuan,
  }) {
    final garis = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: p.border),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12.5, color: p.textMuted),
      helperText: bantuan,
      helperMaxLines: 2,
      helperStyle: TextStyle(fontSize: 11, color: p.textSecondary),
      filled: true,
      fillColor: p.inputFill,
      prefixIcon: Icon(ikon, size: 18, color: p.textSecondary),
      prefixIconConstraints: const BoxConstraints(minWidth: 44),
      border: garis,
      enabledBorder: garis,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.accent, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
    );
  }

  // --------------------------------------------------------------- footer
  Widget _buildFooter(AppPalette p) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: p.card,
          border: Border(top: BorderSide(color: p.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: p.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save, size: 18),
              label: const Text(
                'Simpan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: warnaSimpan,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
