import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Hari Ini';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        title: const Text('Dashboard Analitik & Penjualan (Owner)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              underline: const SizedBox(),
              items: ['Hari Ini', '7 Hari Terakhir', 'Bulan Ini'].map((p) {
                return DropdownMenuItem(value: p, child: Text(p));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPeriod = val);
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 4 Big KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Gross Sales (Omzet Kotor)',
                  value: 'Rp 8.420.000',
                  subtitle: '+18.4% vs kemarin',
                  icon: Icons.monetization_on_outlined,
                  color: AppColors.primary,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildKpiCard(
                  title: 'Net Sales (Penjualan Bersih)',
                  value: 'Rp 7.280.000',
                  subtitle: 'Setelah diskon & COGS',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.accent,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Transaksi',
                  value: '84 Struk',
                  subtitle: 'Rata-rata 9.2 struk/jam',
                  icon: Icons.receipt_outlined,
                  color: AppColors.info,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildKpiCard(
                  title: 'Average Basket Size (AOV)',
                  value: 'Rp 100.238',
                  subtitle: 'Rata-rata per pelanggan',
                  icon: Icons.shopping_basket_outlined,
                  color: const Color(0xFF8B5CF6), // Purple
                  isPositive: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Two Column Breakdown: Top Items & Payment Breakdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Top 5 Best Selling Items
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Menu Paling Laris (Top Sellers)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                          ),
                          Icon(Icons.emoji_events_outlined, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTopItemRow(1, 'Cava Signature Latte', '42 cup terjual', 'Rp 1.344.000', 0.85),
                      _buildTopItemRow(2, 'Kopi Susu Gula Aren Cava', '38 cup terjual', 'Rp 988.000', 0.76),
                      _buildTopItemRow(3, 'Truffle Cream Fettuccine', '24 porsi terjual', 'Rp 1.392.000', 0.48),
                      _buildTopItemRow(4, 'Butter French Croissant', '29 pcs terjual', 'Rp 725.000', 0.58),
                      _buildTopItemRow(5, 'Iced Long Black / Americano', '21 cup terjual', 'Rp 588.000', 0.42),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Right: Payment Methods Breakdown & Tax PB1
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distribusi Metode Pembayaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentBar('QRIS (BCA/Mandiri/GoPay)', 'Rp 4.630.000 (55%)', 0.55, AppColors.accent),
                      _buildPaymentBar('Tunai (Cash)', 'Rp 2.105.000 (25%)', 0.25, AppColors.primary),
                      _buildPaymentBar('Kartu Debit/Kredit EDC', 'Rp 1.685.000 (20%)', 0.20, AppColors.info),
                      const Divider(height: 32),
                      const Text(
                        'Rekapitulasi Pajak & Servis',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                      ),
                      const SizedBox(height: 8),
                      _buildTaxRow('Pajak Restoran PB1 (10%):', 'Rp 765.450'),
                      _buildTaxRow('Service Charge (5%):', 'Rp 382.725'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Peak Hours Activity Heatmap Simulation
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
                const Row(
                  children: [
                    Icon(Icons.schedule, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Peak Hours Traffic (Waktu Paling Sibuk)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildHourBar('08:00', 0.25, '3 ord'),
                      _buildHourBar('09:00', 0.45, '6 ord'),
                      _buildHourBar('10:00', 0.60, '8 ord'),
                      _buildHourBar('11:00', 0.85, '12 ord'),
                      _buildHourBar('12:00', 1.00, '15 ord', isPeak: true), // Peak Lunch
                      _buildHourBar('13:00', 0.90, '13 ord'),
                      _buildHourBar('14:00', 0.50, '7 ord'),
                      _buildHourBar('15:00', 0.70, '10 ord'),
                      _buildHourBar('16:00', 0.85, '12 ord'),
                      _buildHourBar('17:00', 0.95, '14 ord'),
                      _buildHourBar('18:00', 0.80, '11 ord'),
                      _buildHourBar('19:00', 0.65, '9 ord'),
                      _buildHourBar('20:00', 0.40, '5 ord'),
                      _buildHourBar('21:00', 0.20, '2 ord'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: isPositive ? AppColors.accent : AppColors.danger)),
        ],
      ),
    );
  }

  Widget _buildTopItemRow(int rank, String name, String subtitle, String totalRevenue, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rank <= 3 ? AppColors.primary : AppColors.lightSurfaceLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.white : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.lightTextPrimary)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
                  ],
                ),
              ),
              Text(totalRevenue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.lightSurfaceLight,
              color: AppColors.primary,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBar(String method, String amount, double ratio, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(method, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
              Text(amount, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.lightSurfaceLight,
              color: color,
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
        ],
      ),
    );
  }

  Widget _buildHourBar(String time, double heightRatio, String label, {bool isPeak = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isPeak)
          const Text('PEAK', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.danger)),
        Container(
          width: 28,
          height: 65 * heightRatio,
          decoration: BoxDecoration(
            color: isPeak ? AppColors.primary : AppColors.primarySoft,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 6),
        Text(time, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
      ],
    );
  }
}
