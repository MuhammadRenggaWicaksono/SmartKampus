# 🎓 Kampus APP (SmartKampus) - Portal Akademik Mahasiswa

Sebuah aplikasi *mobile* berbasis **Flutter** yang dirancang khusus untuk memudahkan mahasiswa dalam mengakses informasi akademik seperti Jadwal Kuliah, Kartu Rencana Studi (KRS), dan Kartu Hasil Studi (KHS) secara cepat, responsif, dan interaktif.

---

## ✨ Fitur Utama

- **📊 Dashboard Interaktif:** Menampilkan ringkasan informasi akademik seperti IPK, SKS diambil beserta total terhadap target kelulusan, status tagihan, serta jadwal kuliah hari ini dengan penanda kelas yang sedang berjalan.
- **📉 Statistik Akademik:** Satu kartu grafik dengan tiga tampilan yang bisa diganti lewat tombol tepat di atas grafik:
  - **IPS 1–8** — grafik garis Indeks Prestasi per semester beserta garis target.
  - **Tatap Muka** — realisasi rencana 16 kali pertemuan untuk setiap mata kuliah.
  - **Absensi** — komposisi hadir / sakit / izin / alpa per mata kuliah.
- **📚 Kartu Rencana Studi (KRS):** Memudahkan mahasiswa melihat daftar mata kuliah yang diambil pada semester berjalan.
- **📈 Kartu Hasil Studi (KHS):** Menampilkan rincian nilai per mata kuliah beserta Indeks Prestasi dengan visualisasi *badge* warna yang intuitif.
- **🗓️ Presensi:** Rekap kehadiran per mata kuliah dengan bar bertumpuk hadir/sakit/izin/alpa dan penanda "RAWAN" untuk kehadiran di bawah 75%.
- **🖨️ Cetak KHS (PDF):** Simulasi fitur untuk mengunduh Kartu Hasil Studi ke dalam format PDF.
- **🎨 Global Theme Switcher:** Mendukung kustomisasi tampilan tingkat lanjut dengan 3 mode warna (menggunakan `ValueNotifier`):
  - ☀️ **Light Mode:** Tampilan terang yang bersih dan minimalis.
  - 🌙 **Dark Mode:** Tampilan gelap yang nyaman untuk mata.
  - 🌈 **LGBT Mode:** Tampilan eksperimental dengan *gradient background* pelangi dan elemen *glassmorphism*.🤣🤣🤣

---

## 📱 Tangkapan Layar (Screenshots)

*(Tangkapan layar akan ditambahkan pada pembaruan mendatang)*

| Dashboard (Light) | KHS (Dark) | KHS (LGBT Mode) |
| :---: | :---: | :---: |
| `[Gambar 1]` | `[Gambar 2]` | `[Gambar 3]` |

---

## 🛠️ Teknologi yang Digunakan

Aplikasi ini dibangun menggunakan ekosistem Flutter. Untuk saat ini, data yang digunakan masih berupa simulasi (*dummy data*) secara lokal sambil menunggu kepastian arsitektur *backend* dari pihak kampus.

- **Framework:** [Flutter](https://flutter.dev/)
- **Bahasa Pemrograman:** Dart
- **State Management:** `ValueNotifier` (bawaan Flutter) untuk *state* global tema, plus `StatefulWidget` untuk *state* per halaman.
- **Arsitektur UI:** Material Design 3.
- **Grafik:** `CustomPainter` — tanpa *package* tambahan, sehingga tidak ada dependensi baru.
- **Backend & Database:** *TBD (To Be Determined - Menyesuaikan ketersediaan API kampus).*

---

## 🎨 Sistem Tema (Penting untuk Kontributor)

Seluruh warna diambil dari satu sumber: **`lib/core/app_palette.dart`**.

```dart
return ThemeBuilder(
  builder: (context, p) => Container(
    decoration: p.backgroundDecoration,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Judul', style: TextStyle(color: p.textPrimary)),
        backgroundColor: p.card,
        iconTheme: IconThemeData(color: p.textPrimary),
      ),
      body: const SizedBox(),
    ),
  ),
);
```

**Jangan** menulis `Colors.white`, `Color(0xFFF8F9FA)`, atau `Colors.black87` secara langsung
untuk warna tema — itulah yang sebelumnya membuat Dark Mode dan LGBT Mode rusak di
sebagian halaman. Pakai getter `AppPalette` (`p.card`, `p.textPrimary`, `p.border`, dst.).

Warna *brand* untuk ikon/tombol (`Colors.blue`, `Colors.red`, `Colors.orange`, ...) tetap
boleh dipakai langsung.

---

## 🧪 Pengujian

```bash
flutter test      # 12 test: grafik, dashboard, 3 tema, perhitungan SKS/IPS/absensi
flutter analyze   # harus bersih
```

---

## 📂 Struktur Folder Proyek

```text
lib/
├── main.dart
├── theme_notifier.dart            # sumber tema global (light/dark/lgbt)
├── core/
│   ├── app_palette.dart           # palet warna terpusat
│   ├── theme_builder.dart         # rebuild otomatis saat tema berubah
│   └── main_screen.dart           # bottom navigation (5 tab)
├── data/
│   └── app_data.dart              # SUMBER DATA TUNGGAL (dummy -> API nanti)
├── widgets/
│   └── statistik_chart.dart       # grafik IPS / Tatap Muka / Absensi
├── screens/
│   ├── dashboard_screen.dart
│   ├── akademik_screen.dart
│   ├── perkuliahan_screen.dart
│   ├── keuangan_screen.dart
│   └── akun_screen.dart
├── auth/
│   └── login_screen.dart
├── admin/
│   ├── ganti_password_screen.dart
│   └── ganti_password_wifi_screen.dart
├── akademik/
│   └── kalender_akademik_screen.dart
├── perkuliahan/
│   ├── jadwal_kuliah_screen.dart
│   ├── jadwal_ujian_screen.dart
│   └── presensi_screen.dart
├── profil/                        # (folder: profile/)
│   ├── biodata_mahasiswa_screen.dart
│   └── biodata_keluarga_screen.dart
├── studi/
│   ├── entri_krs_screen.dart
│   ├── isi_krs_screen.dart
│   ├── lihat_krs_screen.dart
│   ├── lihat_khs_screen.dart
│   ├── khs_screen.dart
│   └── transkrip_screen.dart
└── komunikasi/
    └── pesan_baru_screen.dart
```

### Catatan data

Semua data simulasi (nama mahasiswa, NIM, jadwal mingguan, riwayat IPS, rekap presensi,
SKS per semester) berada di **`lib/data/app_data.dart`**. Dashboard, Jadwal Kuliah,
dan Presensi membaca dari sumber yang sama, jadi angkanya tidak lagi saling bertentangan
antar halaman. Saat API kampus tersedia, cukup mengganti isi file itu.
