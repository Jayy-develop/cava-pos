import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/expense_item.dart';
import '../services/expense_service.dart';
import 'widgets/add_expense_from_template_dialog.dart';
import 'widgets/manage_templates_dialog.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class ExpenseManagementScreen extends StatefulWidget {
  const ExpenseManagementScreen({super.key});

  @override
  State<ExpenseManagementScreen> createState() => _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen> {
  final _expenseService = ExpenseService();
  String _selectedFilter = 'all'; // 'all', 'today', 'month'
  ExpenseCategory? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _expenseService.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _expenseService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _openAddExpenseModal({ExpenseItem? existing}) {
    showDialog(
      context: context,
      builder: (ctx) => AddExpenseFromTemplateDialog(existingExpense: existing),
    );
  }

  void _openManageTemplatesModal() {
    showDialog(
      context: context,
      builder: (ctx) => const ManageTemplatesDialog(),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.bahanDapur:
        return Icons.kitchen;
      case ExpenseCategory.utilitas:
        return Icons.bolt;
      case ExpenseCategory.operasional:
        return Icons.inventory;
      case ExpenseCategory.gajiUpah:
        return Icons.payments_outlined;
      case ExpenseCategory.maintenance:
        return Icons.build;
      case ExpenseCategory.marketing:
        return Icons.campaign;
      case ExpenseCategory.sewaIuran:
        return Icons.holiday_village;
      case ExpenseCategory.lainnya:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final allExpenses = _expenseService.expenses;
    final templates = _expenseService.templates;

    final filteredExpenses = allExpenses.where((e) {
      if (_selectedFilter == 'today') {
        final isToday = e.date.year == now.year && e.date.month == now.month && e.date.day == now.day;
        if (!isToday) return false;
      } else if (_selectedFilter == 'month') {
        final isMonth = e.date.year == now.year && e.date.month == now.month;
        if (!isMonth) return false;
      }

      if (_selectedCategoryFilter != null && e.category != _selectedCategoryFilter) {
        return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        title: const Text('Biaya Operasional & Template (OPEX)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Manage Templates Button
          OutlinedButton.icon(
            onPressed: _openManageTemplatesModal,
            icon: const Icon(Icons.dashboard_customize_outlined, size: 16),
            label: const Text('Kelola Template'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),

          // Add Expense Button
          ElevatedButton.icon(
            onPressed: () => _openAddExpenseModal(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Catat Biaya'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 4 Metric Highlights
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Biaya Hari Ini',
                  CurrencyFormatter.format(_expenseService.totalToday),
                  'Pengeluaran operasional hari ini',
                  Icons.receipt_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  'Kas Laci Keluar (Petty Cash)',
                  CurrencyFormatter.format(_expenseService.pettyCashOutToday),
                  'Mengurangi fisik uang kasir',
                  Icons.point_of_sale_rounded,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  'Total Biaya Bulan Ini',
                  CurrencyFormatter.format(_expenseService.totalThisMonth),
                  DateFormat('MMMM yyyy').format(now),
                  Icons.calendar_month_outlined,
                  AppColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  'Jumlah Transaksi Biaya',
                  '${allExpenses.length} Bukti',
                  'Tercatat di sistem akuntansi',
                  Icons.fact_check_outlined,
                  const Color(0xFF047857),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Quick Template Selection Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bolt, color: AppColors.primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Catat Cepat Menggunakan Template Biaya:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _openManageTemplatesModal,
                      child: const Text(
                        'Edit & Tambah Template →',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick Clickable Template Chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: templates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tpl = templates[index];
                      return ActionChip(
                        avatar: Icon(_getCategoryIcon(tpl.category), size: 14, color: AppColors.primary),
                        label: Text('${tpl.title} (${tpl.defaultAmount > 0 ? "Rp ${tpl.defaultAmount.toInt()}" : "Kustom"})'),
                        backgroundColor: AppColors.lightSurfaceLight,
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        onPressed: () {
                          // Quick open pre-filled
                          showDialog(
                            context: context,
                            builder: (ctx) => AddExpenseFromTemplateDialog(
                              existingExpense: tpl.toExpenseItem(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Filters Bar
          Row(
            children: [
              ChoiceChip(
                label: const Text('Semua Periode'),
                selected: _selectedFilter == 'all',
                onSelected: (_) => setState(() => _selectedFilter = 'all'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Hari Ini'),
                selected: _selectedFilter == 'today',
                onSelected: (_) => setState(() => _selectedFilter = 'today'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Bulan Ini'),
                selected: _selectedFilter == 'month',
                onSelected: (_) => setState(() => _selectedFilter = 'month'),
              ),
              const Spacer(),
              if (_selectedCategoryFilter != null)
                ActionChip(
                  avatar: const Icon(Icons.close, size: 14),
                  label: Text('Kategori: ${_selectedCategoryFilter!.label}'),
                  onPressed: () => setState(() => _selectedCategoryFilter = null),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Expenses List
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: filteredExpenses.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('Belum ada catatan pengeluaran pada periode ini.', style: TextStyle(color: AppColors.lightTextMuted)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredExpenses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredExpenses[index];
                      final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(item.date);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.isPettyCash ? AppColors.warningSoft : AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(item.category),
                            color: item.isPettyCash ? AppColors.warning : AppColors.accent,
                            size: 22,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.lightSurfaceLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.lightBorder),
                              ),
                              child: Text(
                                item.category.label,
                                style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '$dateStr • Sumber: ${item.paymentSource} • Dicatat: ${item.recordedBy}',
                              style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                            ),
                            if (item.notes.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Catatan: ${item.notes}',
                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.lightTextMuted),
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '- ${CurrencyFormatter.format(item.amount)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.danger,
                                  ),
                                ),
                                Text(
                                  item.receiptRef.isNotEmpty ? item.receiptRef : 'Tanpa Nota',
                                  style: const TextStyle(fontSize: 10, color: AppColors.lightTextMuted),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),

                            // Edit Action
                            IconButton(
                              tooltip: 'Edit Biaya Ini',
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                              onPressed: () => _openAddExpenseModal(existing: item),
                            ),

                            // Delete Action
                            IconButton(
                              tooltip: 'Hapus Biaya',
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                              onPressed: () {
                                _expenseService.deleteExpense(item.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Biaya "${item.title}" berhasil dihapus')),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
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
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
