import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final double _startingCash = 500000;
  final double _totalCashSales = 2450000;
  final double _totalNonCashSales = 4820000;
  final int _totalTransactions = 46;

  final TextEditingController _actualCashController = TextEditingController();
  double _actualCash = 0.0;

  @override
  void initState() {
    super.initState();
    _actualCash = _startingCash + _totalCashSales; // Default match
    _actualCashController.text = _actualCash.toInt().toString();
  }

  @override
  void dispose() {
    _actualCashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expectedCash = _startingCash + _totalCashSales;
    final cashDifference = _actualCash - expectedCash;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        title: const Text('Shift Kasir & Rekonsiliasi (X/Z Report)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Shift Active Status Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.lock_open_rounded, color: AppColors.accent, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SHIFT SEDANG BERJALAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent, letterSpacing: 1.1)),
                      SizedBox(height: 4),
                      Text('Kasir: Arya (ID: CSH-01) • Terminal #1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                      SizedBox(height: 2),
                      Text('Waktu Buka: Hari ini, 08:00 WIB (Durasi: 6 jam 25 mnt)', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan X-Report dicetak ke thermal printer kasir.')),
                    );
                  },
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text('Cetak X-Report'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sales Breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ringkasan Penjualan Shift', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                const SizedBox(height: 16),
                _buildRow('Modal Kas Awal (Opening Float):', CurrencyFormatter.format(_startingCash)),
                _buildRow('Total Penjualan Tunai (Cash):', CurrencyFormatter.format(_totalCashSales)),
                _buildRow('Total Penjualan Non-Tunai (QRIS/EDC):', CurrencyFormatter.format(_totalNonCashSales)),
                _buildRow('Jumlah Transaksi:', '$_totalTransactions Transaksi'),
                const Divider(height: 24),
                _buildRow('Total Kas Fisik Sistem Diharapkan:', CurrencyFormatter.format(expectedCash), isBold: true, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cash Reconciliation (Closing)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rekonsiliasi Kas Akhir (Tutup Kasir)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                const SizedBox(height: 8),
                const Text('Hitung seluruh uang fisik di laci kasir dan masukkan total riil di bawah ini:', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                const SizedBox(height: 14),

                TextField(
                  controller: _actualCashController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Uang Kas Fisik Aktual di Laci (Rp)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _actualCash = double.tryParse(val) ?? 0.0;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Difference indicator
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cashDifference == 0
                        ? AppColors.accentSoft
                        : (cashDifference > 0 ? AppColors.warningSoft : AppColors.dangerSoft),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cashDifference == 0
                            ? 'KAS SEIMBANG (PAS)'
                            : (cashDifference > 0 ? 'SELISIH LEBIH (OVER)' : 'SELISIH KURANG (SHORT)'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: cashDifference == 0
                              ? AppColors.accent
                              : (cashDifference > 0 ? AppColors.warning : AppColors.danger),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(cashDifference.abs()),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: cashDifference == 0
                              ? AppColors.accent
                              : (cashDifference > 0 ? AppColors.warning : AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tutup Shift Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.lightSurface,
                          title: const Text('Konfirmasi Tutup Shift (Z-Report)'),
                          content: const Text('Setelah shift ditutup, seluruh kas akan dibukukan dan printer akan mencetak laporan Z-Report penutupan hari.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Shift berhasil ditutup & Laporan Z-Report dicetak.'),
                                    backgroundColor: AppColors.accent,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                              child: const Text('Tutup Shift Sekarang', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.power_settings_new, color: Colors.white),
                    label: const Text('Tutup Shift & Cetak Z-Report', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color ?? AppColors.lightTextPrimary)),
        ],
      ),
    );
  }
}
