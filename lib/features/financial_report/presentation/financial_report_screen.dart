import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/financial_report_data.dart';
import '../services/financial_export_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../expenses/presentation/expense_management_screen.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  ReportPeriodType _selectedPeriodType = ReportPeriodType.daily;
  DateTime _selectedDate = DateTime(2026, 9, 11);
  int _selectedMonth = 9;
  int _selectedYear = 2026;

  FinancialReportData _getCurrentReportData() {
    switch (_selectedPeriodType) {
      case ReportPeriodType.daily:
        return FinancialReportData.daily(_selectedDate);
      case ReportPeriodType.monthly:
        return FinancialReportData.monthly(_selectedMonth, _selectedYear);
      case ReportPeriodType.yearly:
        return FinancialReportData.yearly(_selectedYear);
    }
  }

  Future<void> _pickDailyDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportData = _getCurrentReportData();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        title: const Text('Laporan Keuangan & Laba Rugi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Biaya & Template OPEX Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExpenseManagementScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long_rounded, size: 16),
            label: const Text('Biaya & Template (OPEX)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 10),

          // Export Excel Button
          OutlinedButton.icon(
            onPressed: () {
              FinancialExportService.exportToExcel(reportData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mengunduh Laporan Keuangan Excel (.csv): ${reportData.periodLabel}'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            icon: const Icon(Icons.table_chart_outlined, size: 16, color: AppColors.accent),
            label: const Text('Ekspor Excel (.csv)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              side: const BorderSide(color: AppColors.accent),
            ),
          ),
          const SizedBox(width: 10),

          // Export PDF Button
          ElevatedButton.icon(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sedang membuat file PDF resmi...')),
              );
              await FinancialExportService.exportToPdf(reportData);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Laporan PDF ${reportData.periodLabel} berhasil diunduh!'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              }
            },
            icon: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.white),
            label: const Text('Unduh PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Period Filter Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                const Text(
                  'Periode Laporan:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary),
                ),
                const SizedBox(width: 16),

                // Period Mode Segmented Buttons
                ChoiceChip(
                  label: const Text('Harian (Per Hari)'),
                  selected: _selectedPeriodType == ReportPeriodType.daily,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.lightSurfaceLight,
                  labelStyle: TextStyle(
                    color: _selectedPeriodType == ReportPeriodType.daily ? Colors.white : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _selectedPeriodType = ReportPeriodType.daily),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bulanan (Per Bulan)'),
                  selected: _selectedPeriodType == ReportPeriodType.monthly,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.lightSurfaceLight,
                  labelStyle: TextStyle(
                    color: _selectedPeriodType == ReportPeriodType.monthly ? Colors.white : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _selectedPeriodType = ReportPeriodType.monthly),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Tahunan (Per Tahun)'),
                  selected: _selectedPeriodType == ReportPeriodType.yearly,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.lightSurfaceLight,
                  labelStyle: TextStyle(
                    color: _selectedPeriodType == ReportPeriodType.yearly ? Colors.white : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _selectedPeriodType = ReportPeriodType.yearly),
                ),

                const Spacer(),

                // Dynamic Date / Month / Year Picker Input
                if (_selectedPeriodType == ReportPeriodType.daily) ...[
                  OutlinedButton.icon(
                    onPressed: _pickDailyDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                  ),
                ] else if (_selectedPeriodType == ReportPeriodType.monthly) ...[
                  DropdownButton<int>(
                    value: _selectedMonth,
                    underline: const SizedBox(),
                    items: List.generate(12, (index) {
                      final months = [
                        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                      ];
                      return DropdownMenuItem(value: index + 1, child: Text(months[index]));
                    }),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMonth = val);
                    },
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _selectedYear,
                    underline: const SizedBox(),
                    items: [2024, 2025, 2026, 2027].map((y) {
                      return DropdownMenuItem(value: y, child: Text('$y'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedYear = val);
                    },
                  ),
                ] else ...[
                  DropdownButton<int>(
                    value: _selectedYear,
                    underline: const SizedBox(),
                    items: [2024, 2025, 2026, 2027].map((y) {
                      return DropdownMenuItem(value: y, child: Text('Tahun $y'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedYear = val);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4 Big Highlights
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Pendapatan Bersih (Net Sales)',
                  CurrencyFormatter.format(reportData.netSales),
                  'Gross: ${CurrencyFormatter.format(reportData.grossSales)}',
                  Icons.receipt_long,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  'Laba Kotor (Gross Profit)',
                  CurrencyFormatter.format(reportData.grossProfit),
                  'Margin Laba: ${reportData.grossMarginPercent.toStringAsFixed(1)}%',
                  Icons.pie_chart_outline,
                  AppColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  'Total Beban Operasional',
                  CurrencyFormatter.format(reportData.totalOpex),
                  'Gaji, utilitas, & sewa kafe',
                  Icons.payments_outlined,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  'Laba Bersih (Net Profit)',
                  CurrencyFormatter.format(reportData.netOperatingProfit),
                  'Net Margin: ${reportData.netProfitMarginPercent.toStringAsFixed(1)}%',
                  Icons.account_balance_rounded,
                  const Color(0xFF047857), // Deep Emerald
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Complete Financial Statement (P&L Table)
          Container(
            padding: const EdgeInsets.all(24),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Laporan Laba Rugi Komprehensif (Profit & Loss)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                        ),
                        Text(
                          'Cava Specialty Roastery & Eatery • Periode: ${reportData.periodLabel}',
                          style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Volume: ${reportData.totalTransactions} Transaksi',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),

                // 1. Revenue
                _buildSectionHeader('1. PENDAPATAN PENJUALAN (REVENUE)'),
                _buildLineItem('Penjualan Kotor Makanan & Minuman (Gross Sales)', CurrencyFormatter.format(reportData.grossSales)),
                _buildLineItem('Potongan Diskon & Promo Penjualan', '- ${CurrencyFormatter.format(reportData.discounts)}', isNegative: true),
                _buildSubtotalItem('Total Pendapatan Bersih (Net Sales)', CurrencyFormatter.format(reportData.netSales)),

                // 2. COGS (HPP)
                _buildSectionHeader('2. BIAYA POKOK PENJUALAN (HPP / COGS)'),
                _buildLineItem('Bahan Baku Kopi (House Blend Gayo & Flores)', CurrencyFormatter.format(reportData.coffeeBeansCost)),
                _buildLineItem('Bahan Baku Susu (Fresh Milk & Oat Milk)', CurrencyFormatter.format(reportData.milkDairyOatCost)),
                _buildLineItem('Gula Aren Cair, Sirup Karamel, & Perasa', CurrencyFormatter.format(reportData.syrupsAndSugarCost)),
                _buildLineItem('Bahan Makanan & Pastry (Truffle, Dori, Croissant)', CurrencyFormatter.format(reportData.foodAndPastryCost)),
                _buildLineItem('Kemasan Takeaway (Paper Cup, Sedotan, Seal)', CurrencyFormatter.format(reportData.packagingCost)),
                _buildSubtotalItem('Total Beban Pokok Penjualan (HPP)', CurrencyFormatter.format(reportData.totalCogs)),

                // 3. Gross Profit
                _buildHighlightItem(
                  '3. LABA KOTOR (GROSS PROFIT)',
                  CurrencyFormatter.format(reportData.grossProfit),
                  'Gross Margin: ${reportData.grossMarginPercent.toStringAsFixed(1)}%',
                  color: AppColors.primary,
                  bgColor: AppColors.primarySoft,
                ),

                // 4. OPEX
                _buildSectionHeaderWithAction(
                  '4. BEBAN OPERASIONAL (OPEX)',
                  actionLabel: '+ Catat / Kelola Biaya (Template)',
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExpenseManagementScreen()),
                    );
                  },
                ),
                _buildLineItem('Gaji Barista, Kasir, & Tim Dapur', CurrencyFormatter.format(reportData.employeeSalaries)),
                _buildLineItem('Utilitas Operasional (Listrik PLN, Air PDAM, Gas)', CurrencyFormatter.format(reportData.electricityAndWater)),
                _buildLineItem('Alokasi Biaya Sewa Lokasi', CurrencyFormatter.format(reportData.rentExpense)),
                _buildLineItem('Pemeliharaan Mesin Espresso & Grinder', CurrencyFormatter.format(reportData.maintenanceAndSupplies)),
                _buildLineItem('Internet WiFi, POS Cloud, & Promosi Media Sosial', CurrencyFormatter.format(reportData.internetAndMarketing)),
                _buildSubtotalItem('Total Beban Operasional (OPEX)', CurrencyFormatter.format(reportData.totalOpex)),

                // 5. Net Profit (EBITDA)
                _buildHighlightItem(
                  '5. LABA BERSIH OPERASIONAL (NET PROFIT)',
                  CurrencyFormatter.format(reportData.netOperatingProfit),
                  'Net Profit Margin: ${reportData.netProfitMarginPercent.toStringAsFixed(1)}%',
                  color: AppColors.accent,
                  bgColor: AppColors.accentSoft,
                  isLarge: true,
                ),

                // 6. Tax & Service Charge (Non-Revenue)
                _buildSectionHeader('6. TITIPAN PAJAK & SERVIS KONSUMEN (NON-REVENUE)'),
                _buildLineItem('Pajak Restoran PB1 (10% untuk Kas Daerah/Pemda)', CurrencyFormatter.format(reportData.pb1TaxCollected)),
                _buildLineItem('Service Charge (5% untuk Tim Layanan)', CurrencyFormatter.format(reportData.serviceChargeCollected)),

                // 7. Cash Flow
                _buildSectionHeader('7. REKONSILIASI PENERIMAAN KAS'),
                _buildLineItem('Penerimaan Kas Fisik Tunai (Cash)', CurrencyFormatter.format(reportData.cashReceived)),
                _buildLineItem('Penerimaan Kas Digital (QRIS & EDC Debit/Kredit)', CurrencyFormatter.format(reportData.digitalPaymentsReceived)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
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
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderWithAction(String title, {required String actionLabel, required VoidCallback onAction}) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
          ),
          InkWell(
            onTap: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  actionLabel,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItem(String label, String value, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isNegative ? AppColors.danger : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtotalItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(
    String label,
    String value,
    String note, {
    required Color color,
    required Color bgColor,
    bool isLarge = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: isLarge ? 14 : 13, fontWeight: FontWeight.bold, color: color),
              ),
              Text(note, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: isLarge ? 20 : 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
