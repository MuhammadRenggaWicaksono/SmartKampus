import 'package:flutter/material.dart';

import 'package:app_kampus/core/app_palette.dart';
import 'package:app_kampus/core/konten_layar.dart';
import 'package:app_kampus/core/theme_builder.dart';
import 'package:app_kampus/data/kp_store.dart';

/// Form "DATA KP".
///
/// Mengikuti formulir web kampus persis: Instansi, Judul KP, Bulan tahun awal
/// KP, Bulan tahun akhir KP, dan Pembimbing Lapangan, dengan tombol Simpan
/// hijau. Tiga penyesuaian untuk aplikasi mobile:
///  * label dipindah ke ATAS kolom supaya tidak sesak di layar sempit;
///  * dropdown bulan & tahun ditata berdampingan dalam satu baris;
///  * ditambah Pembimbing Kampus dan Catatan (opsional) karena keduanya
///    memang dibutuhkan saat verifikasi, tapi belum ada di web.
///
/// Dipakai untuk dua hal: menambah data KP baru, atau memperbaiki data yang
/// sudah ada ([awal] tidak null).
class TambahKpScreen extends StatefulWidget {
  const TambahKpScreen({super.key, this.awal});

  /// Data KP yang sedang diperbaiki. Null = tambah data baru.
  final DataKp? awal;

  bool get modeUbah => awal != null;

  @override
  State<TambahKpScreen> createState() => _TambahKpScreenState();
}

class _TambahKpScreenState extends State<TambahKpScreen> {
  static const Color warnaSimpan = Color(0xFF22C55E);

  final _formKey = GlobalKey<FormState>();
  final _instansiCtrl = TextEditingController();
  final _judulCtrl = TextEditingController();
  final _pembimbingLapanganCtrl = TextEditingController();
  final _pembimbingKampusCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();

  late PeriodeKp _awal;
  late PeriodeKp _akhir;
  late List<int> _tahun;

  @override
  void initState() {
    super.initState();
    final kp = widget.awal;
    _instansiCtrl.text = kp?.instansi ?? '';
    _judulCtrl.text = kp?.judul ?? '';
    _pembimbingLapanganCtrl.text = kp?.pembimbingLapangan ?? '';
    _pembimbingKampusCtrl.text = kp?.pembimbingKampus ?? '';
    _catatanCtrl.text = kp?.catatan ?? '';

    _awal = kp?.awal ?? periodeAwalBawaan();
    _akhir = kp?.akhir ?? periodeAkhirBawaan();
    _tahun = daftarTahunKp(tahunSekarang: DateTime.now().year);
    _pastikanTahunAda();
  }

  /// Tahun yang tersimpan harus selalu ada di daftar dropdown — kalau tidak,
  /// DropdownButton melempar error.
  void _pastikanTahunAda() {
    for (final periode in <PeriodeKp>[_awal, _akhir]) {
      if (!_tahun.contains(periode.tahun)) {
        _tahun = <int>[..._tahun, periode.tahun]..sort();
      }
    }
  }

  @override
  void dispose() {
    _instansiCtrl.dispose();
    _judulCtrl.dispose();
    _pembimbingLapanganCtrl.dispose();
    _pembimbingKampusCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- validasi
  String? _wajib(String? nilai, String label, {int minimal = 3}) {
    final teks = (nilai ?? '').trim();
    if (teks.isEmpty) return '$label wajib diisi.';
    if (teks.length < minimal) return '$label minimal $minimal karakter.';
    return null;
  }

  String? _validasiJudul(String? nilai) {
    final teks = (nilai ?? '').trim();
    if (teks.isEmpty) return 'Judul KP wajib diisi.';
    if (teks.length < 10) return 'Judul KP minimal 10 karakter.';
    return null;
  }

  String? _validasiPeriode() {
    if (_akhir < _awal) {
      return 'Bulan tahun akhir KP tidak boleh lebih awal dari periode awal.';
    }
    if (durasiBulanKp(_awal, _akhir) > 24) {
      return 'Durasi KP maksimal 24 bulan.';
    }
    return null;
  }

  void _simpan() {
    FocusScope.of(context).unfocus();
    final pesanPeriode = _validasiPeriode();
    final formValid = _formKey.currentState?.validate() ?? false;

    if (!formValid || pesanPeriode != null) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            pesanPeriode ?? 'Periksa kembali isian yang ditandai merah.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final lama = widget.awal;
    final data = DataKp(
      id: lama?.id ?? idKpBaru(),
      instansi: _instansiCtrl.text.trim(),
      judul: _judulCtrl.text.trim(),
      pembimbingLapangan: _pembimbingLapanganCtrl.text.trim(),
      pembimbingKampus: _pembimbingKampusCtrl.text.trim(),
      awal: _awal,
      akhir: _akhir,
      status: lama?.status ?? StatusKp.menunggu,
      diajukan: lama?.diajukan ?? DateTime.now(),
      catatan: _catatanCtrl.text.trim(),
      tautan: lama?.tautan ?? const <String, String>{},
    );

    if (lama == null) {
      KpStore.tambah(data);
    } else {
      KpStore.perbarui(data);
    }

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
              widget.modeUbah ? 'Ubah Data KP' : 'Tambah Data KP',
              style: TextStyle(color: p.textPrimary, fontSize: 18),
            ),
            backgroundColor: p.card,
            foregroundColor: p.textPrimary,
            iconTheme: IconThemeData(color: p.textPrimary),
            elevation: 0.5,
          ),
          body: KontenLayar(
            paddingHp: EdgeInsets.zero,
            paddingLebar: EdgeInsets.zero,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Text(
                    'DATA KP',
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
                  _buildIsian(p),
                  const SizedBox(height: 16),
                  _buildKartuDurasi(p),
                ],
              ),
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
        color: Colors.teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.teal),
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
          _buildPoin(
            p,
            'Isi data KP sesuai surat balasan instansi — instansi, judul '
            'kegiatan, periode, dan pembimbing lapangan.',
          ),
          const SizedBox(height: 6),
          _buildPoin(
            p,
            'Periode akhir tidak boleh lebih awal dari periode awal. '
            'Durasi KP paling lama 24 bulan.',
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
              color: Colors.teal,
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

  // -------------------------------------------------------------- isian
  Widget _buildIsian(AppPalette p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: p.cardDeco(borderColor: p.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(p, 'Instansi', wajib: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _instansiCtrl,
            textCapitalization: TextCapitalization.words,
            validator: (v) => _wajib(v, 'Instansi'),
            style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            decoration: _dekorasi(
              p,
              hint: 'Contoh: PT Telkom Indonesia — Balikpapan',
              ikon: Icons.apartment,
              bantuan: 'Nama lengkap instansi tempat KP dilaksanakan.',
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel(p, 'Judul KP', wajib: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _judulCtrl,
            minLines: 2,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            validator: _validasiJudul,
            style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            decoration: _dekorasi(
              p,
              hint: 'Tuliskan judul kegiatan kerja praktik',
              ikon: Icons.title,
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel(p, 'Bulan tahun awal KP', wajib: true),
          const SizedBox(height: 8),
          _buildPemilihPeriode(p, awal: true),
          const SizedBox(height: 20),

          _buildLabel(p, 'Bulan tahun akhir KP', wajib: true),
          const SizedBox(height: 8),
          _buildPemilihPeriode(p, awal: false),
          const SizedBox(height: 20),

          _buildLabel(p, 'Pembimbing Lapangan', wajib: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _pembimbingLapanganCtrl,
            textCapitalization: TextCapitalization.words,
            validator: (v) => _wajib(v, 'Pembimbing Lapangan'),
            style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            decoration: _dekorasi(
              p,
              hint: 'Nama pembimbing dari pihak instansi',
              ikon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel(p, 'Pembimbing Kampus', opsional: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _pembimbingKampusCtrl,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            decoration: _dekorasi(
              p,
              hint: 'Nama dosen pembimbing KP',
              ikon: Icons.school_outlined,
              bantuan: 'Boleh dikosongkan — biasanya ditetapkan setelah ACC.',
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel(p, 'Catatan', opsional: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _catatanCtrl,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            decoration: _dekorasi(
              p,
              hint: 'Keterangan tambahan untuk Koordinator KP',
              ikon: Icons.sticky_note_2_outlined,
            ),
          ),
        ],
      ),
    );
  }

  /// Sepasang dropdown bulan + tahun — satu baris, mengikuti dua pilihan
  /// berdampingan pada formulir web.
  Widget _buildPemilihPeriode(AppPalette p, {required bool awal}) {
    final nilai = awal ? _awal : _akhir;
    final salahUrut = awal && _akhir < _awal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _buildDropdown<int>(
            p,
            nilai: nilai.bulan,
            item: <int>[for (var b = 1; b <= 12; b++) b],
            labelDari: (b) => namaBulanPanjang[b - 1],
            ikon: Icons.calendar_month_outlined,
            onPilih: (b) => setState(() {
              final baru = PeriodeKp(bulan: b, tahun: nilai.tahun);
              if (awal) {
                _awal = baru;
              } else {
                _akhir = baru;
              }
            }),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: _buildDropdown<int>(
            p,
            nilai: nilai.tahun,
            item: _tahun,
            labelDari: (t) => '$t',
            ikon: Icons.event_outlined,
            onPilih: (t) => setState(() {
              final baru = PeriodeKp(bulan: nilai.bulan, tahun: t);
              if (awal) {
                _awal = baru;
              } else {
                _akhir = baru;
              }
            }),
          ),
        ),
        if (salahUrut) ...[
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(top: 14),
            child: Icon(Icons.error_outline, size: 18, color: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown<T>(
    AppPalette p, {
    required T nilai,
    required List<T> item,
    required String Function(T) labelDari,
    required IconData ikon,
    required ValueChanged<T> onPilih,
  }) {
    final garis = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: p.border),
    );

    return DropdownButtonFormField<T>(
      initialValue: nilai,
      isExpanded: true,
      icon: Icon(Icons.expand_more, size: 18, color: p.textSecondary),
      dropdownColor: p.card,
      style: TextStyle(fontSize: 13.5, color: p.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: p.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        prefixIcon: Icon(ikon, size: 18, color: p.textSecondary),
        prefixIconConstraints: const BoxConstraints(minWidth: 38),
        border: garis,
        enabledBorder: garis,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.accent, width: 1.6),
        ),
      ),
      items: <DropdownMenuItem<T>>[
        for (final satu in item)
          DropdownMenuItem<T>(
            value: satu,
            child: Text(
              labelDari(satu),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.5, color: p.textPrimary),
            ),
          ),
      ],
      onChanged: (baru) {
        if (baru != null) onPilih(baru);
      },
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
        Flexible(
          child: Text(
            teks,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: p.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (wajib)
          _buildPil('Wajib', Colors.red)
        else if (opsional)
          _buildPil('Opsional', p.textMuted),
      ],
    );
  }

  Widget _buildPil(String teks, Color warna) {
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

  /// Ringkasan hidup: memperlihatkan durasi & rentang periode terpilih
  /// sebelum data disimpan.
  Widget _buildKartuDurasi(AppPalette p) {
    final durasi = durasiBulanKp(_awal, _akhir);
    final salah = _akhir < _awal;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (salah ? Colors.red : Colors.teal).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (salah ? Colors.red : Colors.teal).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            salah ? Icons.error_outline : Icons.timelapse_outlined,
            size: 18,
            color: salah ? Colors.red : Colors.teal,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_awal.label} – ${_akhir.label}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  salah
                      ? 'Periode akhir lebih awal dari periode awal.'
                      : 'Durasi kegiatan $durasi bulan.',
                  style: TextStyle(fontSize: 11.5, color: p.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- footer
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
