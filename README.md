# 🎓 Kampus APP (SmartKampus) - Portal Akademik Mahasiswa

Sebuah aplikasi *mobile* berbasis **Flutter** yang dirancang khusus untuk memudahkan mahasiswa dalam mengakses informasi akademik seperti Jadwal Kuliah, Kartu Rencana Studi (KRS), dan Kartu Hasil Studi (KHS) secara cepat, responsif, dan interaktif.

---

## ✨ Fitur Utama

- **📊 Dashboard Interaktif:** Menampilkan ringkasan informasi akademik seperti IPK, total SKS, status tagihan, serta cuplikan jadwal kuliah hari ini.
- **📚 Kartu Rencana Studi (KRS):** Memudahkan mahasiswa melihat daftar mata kuliah yang diambil pada semester berjalan.
- **📈 Kartu Hasil Studi (KHS):** Menampilkan rincian nilai per mata kuliah beserta Indeks Prestasi dengan visualisasi *badge* warna yang intuitif.
- **🖨️ Cetak KHS (PDF):** Simulasi fitur untuk mengunduh Kartu Hasil Studi ke dalam format PDF.
- **🎨 Global Theme Switcher:** Mendukung kustomisasi tampilan tingkat lanjut dengan 3 mode warna (menggunakan `ValueNotifier`):
  - ☀️ **Light Mode:** Tampilan terang yang bersih dan minimalis.
  - 🌙 **Dark Mode:** Tampilan gelap yang nyaman untuk mata.
  - 🌈 **LGBT Mode:** Tampilan eksperimental dengan *gradient background* pelangi dan elemen *glassmorphism*.

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
- **State Management:** `ValueNotifier` (Bawaan Flutter untuk manajemen *State* Global pada sistem Tema).
- **Arsitektur UI:** Material Design 3.
- **Backend & Database:** *TBD (To Be Determined - Menyesuaikan ketersediaan API kampus).*

---

## 📂 Struktur Folder Proyek

```text
lib/
├── main.dart
└── screens/[cite: 1]
    ├── auth/
    │   └── login_screen.dart[cite: 1]
    ├── akun/
    │   ├── akun_screen.dart[cite: 1]
    │   ├── ganti_password_screen.dart[cite: 1]
    │   └── ganti_password_wifi_screen.dart[cite: 1]
    ├── profil/
    │   ├── biodata_mahasiswa_screen.dart[cite: 1]
    │   └── biodata_keluarga_screen.dart[cite: 1]
    ├── akademik/
    │   ├── akademik_screen.dart[cite: 1]
    │   └── kalender_akademik_screen.dart[cite: 1]
    ├── perkuliahan/
    │   ├── perkuliahan_screen.dart[cite: 1]
    │   ├── jadwal_kuliah_screen.dart[cite: 1]
    │   ├── jadwal_ujian_screen.dart[cite: 1]
    │   └── presensi_screen.dart[cite: 1]
    ├── studi/ (atau krs_khs)
    │   ├── isi_krs_screen.dart[cite: 1]
    │   ├── lihat_krs_screen.dart[cite: 1]
    │   ├── khs_screen.dart[cite: 1]
    │   ├── lihat_khs_screen.dart[cite: 1]
    │   └── transkrip_screen.dart[cite: 1]
    ├── komunikasi/
    │   └── pesan_baru_screen.dart[cite: 1]
    ├── keuangan/
    │   └── keuangan_screen.dart[cite: 1]
    └── core/ (Tampilan Utama)
        ├── main_screen.dart[cite: 1]
        └── dashboard_screen.dart[cite: 1]
