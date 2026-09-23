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
│
├── screens/
│   ├── dashboard_screen.dart    # Halaman utama aplikasi
│   ├── lihat_krs_screen.dart    # Halaman Kartu Rencana Studi
│   ├── lihat_khs_screen.dart    # Halaman Kartu Hasil Studi
│   └── akademik_screen.dart     # (Opsional) Halaman navigasi menu akademik
│
├── theme_notifier.dart          # Pusat kendali (Global State) untuk sistem ganti tema
└── main.dart                    # Entry point aplikasi
