# ☕ Cava Cafe POS (Point of Sale & Operational System)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State_Management-flutter__bloc-blueviolet)](https://bloclibrary.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20|%20Android%20|%20Web%20|%20iOS%20|%20macOS-blue)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Aplikasi **Point of Sale (POS)** dan **Manajemen Operasional Kafe** berbasis **Flutter & BLoC Pattern** dengan arsitektur modern (*offline-first*, perutean tiket pesanan termal ESC/POS, manajemen meja, stok bahan baku, hingga laporan keuangan laba-rugi otomatis).

---

## 📑 Daftar Isi
1. [Panduan Instalasi Flutter dari Nol (Untuk Pemula)](#-panduan-instalasi-flutter-dari-nol-untuk-pemula)
   - [Langkah 1: Download & Install Git](#langkah-1-download--install-git)
   - [Langkah 2: Install VS Code & Ekstensi Pendukung](#langkah-2-install-visual-studio-code--ekstensi)
   - [Langkah 3: Install Flutter SDK](#langkah-3-install-flutter-sdk)
   - [Langkah 4: Atur Environment Variable (PATH di Windows)](#langkah-4-atur-environment-variable-path-di-windows)
   - [Langkah 5: Pilihan Target Device (Web, Windows, atau Android)](#langkah-5-pilihan-target-device)
   - [Langkah 6: Validasi dengan Flutter Doctor](#langkah-6-validasi-dengan-flutter-doctor)
2. [Cara Menjalankan Project Cava POS](#-cara-menjalankan-project-cava-pos)
3. [Fitur-Fitur Utama Aplikasi](#-fitur-fitur-utama-aplikasi)
4. [Struktur Folder Project](#-struktur-folder-project)
5. [Tips Selama Masa Pengembangan](#-tips-selama-masa-pengembangan)
6. [Troubleshooting & Solusi Masalah Umum](#-troubleshooting--solusi-masalah-umum)

---

## 🚀 Panduan Instalasi Flutter dari Nol (Untuk Pemula)

Jika kamu baru pertama kali belajar atau menyentuh Flutter, ikuti langkah-langkah di bawah ini secara berurutan.

### Langkah 1: Download & Install Git
Git diperlukan untuk mengunduh kode program dari GitHub dan mengelola update aplikasi.
1. Download installer Git untuk Windows di: [https://git-scm.com/download/win](https://git-scm.com/download/win).
2. Jalankan file `.exe` yang sudah didownload, klik **Next** terus sampai selesai (gunakan konfigurasi default).
3. Buka **Command Prompt (CMD)** atau **PowerShell**, lalu ketik untuk memastikan:
   ```bash
   git --version
   ```

---

### Langkah 2: Install Visual Studio Code & Ekstensi
VS Code adalah teks editor ringan yang sangat direkomendasikan untuk pengembangan Flutter.
1. Download VS Code: [https://code.visualstudio.com/](https://code.visualstudio.com/) lalu install.
2. Buka VS Code, klik ikon **Extensions** di sisi kiri (`Ctrl + Shift + X`), lalu cari dan install ekstensi berikut:
   - **Flutter** (Otomatis juga menginstall ekstensi **Dart**)
   - **Bloc** (Memudahkan navigasi arsitektur state management)

---

### Langkah 3: Install Flutter SDK
1. Download bundle resmi Flutter SDK terbaru untuk Windows di:  
   👉 [https://docs.flutter.dev/get-started/install/windows/desktop](https://docs.flutter.dev/get-started/install/windows/desktop)
2. Ekstrak file zip tersebut ke direktori yang mudah diakses dan **tidak memerlukan hak akses administrator**.  
   *Contoh lokasi yang disarankan*:
   ```
   C:\src\flutter
   ```
   *(⚠️ PENTING: Jangan ekstrak ke folder `C:\Program Files\` karena proteksi hak akses Windows dapat menyebabkan error).*

---

### Langkah 4: Atur Environment Variable (PATH di Windows)
Agar perintah `flutter` dapat dijalankan dari terminal mana saja:
1. Tekan tombol **Windows + S**, ketik `env`, lalu pilih **Edit the system environment variables** (Edit variabel lingkungan sistem).
2. Klik tombol **Environment Variables...** di pojok kanan bawah.
3. Di bagian **User variables for [Nama Kamu]**, cari baris bernama `Path`, lalu klik tombol **Edit...**.
4. Klik **New**, lalu masukkan lokasi folder `bin` dari Flutter yang kamu ekstrak tadi:
   ```
   C:\src\flutter\bin
   ```
5. Klik **OK** -> **OK** -> **OK** untuk menyimpan semua perubahan.
6. Buka jendela terminal baru (PowerShell / CMD), lalu tes:
   ```bash
   flutter --version
   ```
   *Jika versi Flutter muncul, selamat! Flutter sudah terpasang dengan benar di komputermu.*

---

### Langkah 5: Pilihan Target Device

Kamu bisa menjalankan aplikasi ini di beberapa pilihan target berikut:

#### Opsi A: Google Chrome / Web (Paling Cepat & Ringan)
- **Kebutuhan**: Cukup punya browser **Google Chrome** di komputermu.
- Tidak perlu emulator berat ataupun tools tambahan.

#### Opsi B: Windows Desktop (Aplikasi Desktop Native)
- **Kebutuhan**: Install **Visual Studio 2022 Community** (bukan hanya VS Code).
- Saat instalasi Visual Studio Installer, pastikan centang workload:  
  **"Desktop development with C++"** (Pengembangan desktop dengan C++).

#### Opsi C: Android (HP Fisik atau Emulator)
1. Install **Android Studio**: [https://developer.android.com/studio](https://developer.android.com/studio).
2. Buka Android Studio -> **More Actions** -> **SDK Manager** -> tab **SDK Tools**:
   - Centang **Android SDK Command-line Tools (latest)**
   - Centang **Android SDK Platform-Tools**
   - Klik **Apply** / **OK**.
3. Jika ingin menggunakan HP fisik: Aktifkan **Developer Options** & **USB Debugging** pada HP Android kamu lalu hubungkan dengan kabel data USB.

---

### Langkah 6: Validasi dengan Flutter Doctor
Buka terminal baru di komputermu, lalu jalankan:
```bash
flutter doctor
```
Jika muncul tanda seru pada lisensi Android, jalankan perintah ini dan tekan `y` untuk semua persetujuan lisensi:
```bash
flutter doctor --android-licenses
```

---

## 💻 Cara Menjalankan Project Cava POS

Setelah Flutter siap, ikuti langkah berikut untuk mengunduh dan menjalankan project:

### 1. Clone Repository
Buka folder tempat kamu ingin menyimpan proyek (misalnya di drive `D:\` atau folder dokumen), lalu buka terminal dan jalankan:
```bash
git clone https://github.com/Jayy-develop/cava-pos.git
```

### 2. Masuk ke Direktori Project
```bash
cd cava-pos
```
*(Atau buka VS Code, lalu klik **File** -> **Open Folder** -> pilih folder `cava-pos`)*.

### 3. Install Dependensi (Packages)
Jalankan perintah ini di terminal proyek untuk mengunduh semua library yang dibutuhkan:
```bash
flutter pub get
```

### 4. Jalankan Aplikasi
Jalankan salah satu perintah berikut sesuai perangkat yang ingin kamu gunakan:

- **Jalankan di Web Browser (Chrome)**:
  ```bash
  flutter run -d chrome
  ```
- **Jalankan di Windows Desktop**:
  ```bash
  flutter run -d windows
  ```
- **Jalankan di HP Android / Emulator**:
  ```bash
  flutter run
  ```

---

## ✨ Fitur-Fitur Utama Aplikasi

| Modul | Deskripsi Fitur |
| :--- | :--- |
| **Point of Sale (POS)** | Antarmuka kasir cepat, pencarian menu real-time, filter kategori, pilihan varian & modifiers (Level gula, varian susu, es/panas). |
| **Denah Meja (Table Map)** | Manajemen denah meja kafe multi-area (Indoor, Outdoor, VIP) dengan indikator status meja (Kosong, Terisi, Reservasi). |
| **Pembayaran & Cetak Struk** | Integrasi cetak struk termal ESC/POS (58mm & 80mm), opsi Split Bill, QRIS, Tunai, Kartu Debit/Kredit, dan preview struk digital. |
| **Shift Kasir** | Buka/Tutup shift, pencatatan uang modal kas awal (*float cash*), penarikan tunai (*cash drop*), dan audit selisih kas. |
| **Inventaris & Bahan Baku** | Monitoring stok bahan baku resep kopi, kartu stok keluar/masuk, serta peringatan otomatis saat stok menipis (*low stock alert*). |
| **Pengeluaran (*Petty Cash*)**| Pencatatan beban operasional kas kecil harian berbasis template cepat. |
| **Laporan Finansial** | Laporan Laba/Rugi (*Profit & Loss*), ringkasan omzet, HPP (*COGS*), dan ekspor data ke format PDF & CSV. |
| **Role & Hak Akses (RBAC)** | Pemisahan hak akses antara Kasir dan Owner dengan sistem proteksi PIN keamanan. |

---

## 📁 Struktur Folder Project

Aplikasi ini menggunakan pola arsitektur **Feature-First** berbasis **BLoC (Business Logic Component)**:

```
lib/
├── core/                       # Komponen global & utilitas inti
│   ├── constants/              # Warna, dimensi, dan konstanta aplikasi
│   ├── network/                # Layanan sinkronisasi offline-first / cloud
│   ├── theme/                  # Konfigurasi Tema (Dark/Light mode & Palet Cava Cafe)
│   └── utils/                  # Formatter mata uang rupiah, export helper, dsb.
├── features/                   # Modul fitur fungsional
│   ├── analytics/              # Dashboard performa & grafik analitik
│   ├── auth/                   # Autentikasi peran (Kasir / Owner) & dialog PIN
│   ├── expenses/               # Manajemen pengeluaran kas kecil & template
│   ├── financial_report/       # Laporan keuangan laba/rugi, ekspor PDF & CSV
│   ├── hardware/               # Integrasi printer termal ESC/POS (58mm/80mm)
│   ├── history/                # Riwayat transaksi dan pesanan sebelumnya
│   ├── inventory/              # Inventaris bahan baku & resep stok
│   ├── pos/                    # Kasir POS, keranjang, kalkulator pesanan & meja
│   └── shift/                  # Pengendalian shift kerja kasir & audit kas
└── main.dart                   # Entry point aplikasi Flutter
```

---

## 💡 Tips Selama Masa Pengembangan

Ketika aplikasi sedang berjalan dari terminal menggunakan `flutter run`:
- Tekan tombol **`r`** di terminal untuk **Hot Reload** (memperbarui tampilan UI secara instan dalam 1 detik tanpa me-reset data).
- Tekan tombol **`R`** (huruf besar) untuk **Hot Restart** (me-restart aplikasi dan me-reset state).
- Tekan tombol **`q`** untuk **Quit** (menghentikan aplikasi).

---

## 🛠 Troubleshooting & Solusi Masalah Umum

### 1. `flutter : The term 'flutter' is not recognized...`
- **Penyebab**: Path Flutter belum terdaftar di Environment Variables atau terminal belum direstart.
- **Solusi**: Pastikan `C:\src\flutter\bin` sudah ada di User Variables `Path`. Tutup seluruh jendela terminal/VS Code, lalu buka kembali.

### 2. `Android license status unknown` saat `flutter doctor`
- **Solusi**: Jalankan perintah berikut di terminal:
  ```bash
  flutter doctor --android-licenses
  ```
  Ketik `y` lalu tekan Enter setiap kali muncul konfirmasi lisensi.

### 3. Masalah saat build Windows Desktop: `Visual Studio is missing components`
- **Solusi**: Buka aplikasi **Visual Studio Installer**, klik **Modify** pada Visual Studio 2022, lalu pastikan workload **"Desktop development with C++"** telah tercentang dan terpasang.

### 4. Error dependensi / package merah di editor
- **Solusi**: Bersihkan cache dan unduh ulang dependensi dengan menjalankan:
  ```bash
  flutter clean
  flutter pub get
  ```

---

*Selamat ngoding! Jika menemui kendala di tengah jalan, jangan ragu untuk berdiskusi atau membuat Issue di repository ini.* ☕🚀
