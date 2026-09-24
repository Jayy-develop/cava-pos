import 'package:flutter/material.dart';
import '../../domain/entities/cafe_table.dart';
import '../../data/mock_pos_data.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class TableManagementModal extends StatefulWidget {
  final String? currentSelectedTable;
  final ValueChanged<String> onTableSelected;

  const TableManagementModal({
    super.key,
    required this.currentSelectedTable,
    required this.onTableSelected,
  });

  @override
  State<TableManagementModal> createState() => _TableManagementModalState();
}

class _TableManagementModalState extends State<TableManagementModal> {
  String _selectedSection = 'All';

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.vacant:
        return AppColors.accent; // Emerald
      case TableStatus.occupied:
        return AppColors.warning; // Amber
      case TableStatus.reserved:
        return AppColors.info; // Blue
      case TableStatus.billing:
        return AppColors.danger;
    }
  }

  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.vacant:
        return 'Kosong';
      case TableStatus.occupied:
        return 'Terisi';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.billing:
        return 'Billing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = ['All', 'Indoor', 'Outdoor Terrace', 'VIP Room'];
    final tables = _selectedSection == 'All'
        ? MockPosData.sampleTables
        : MockPosData.sampleTables.where((t) => t.section == _selectedSection).toList();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
        child: Column(
          children: [
            // Modal Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.table_restaurant_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Denah & Manajemen Meja (Floor Plan)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Pilih meja untuk Dine-In atau kelola pemisahan/penggabungan tagihan',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Section Filter & Status Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Filter Chips
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sections.map((sec) {
                          final isSelected = _selectedSection == sec;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(sec),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceLight,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              onSelected: (_) => setState(() => _selectedSection = sec),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Legend
                  Row(
                    children: [
                      _buildLegendDot(AppColors.accent, 'Kosong'),
                      const SizedBox(width: 12),
                      _buildLegendDot(AppColors.warning, 'Terisi'),
                      const SizedBox(width: 12),
                      _buildLegendDot(AppColors.info, 'Reserved'),
                    ],
                  ),
                ],
              ),
            ),

            // Table Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.25,
                ),
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final table = tables[index];
                  final isCurrent = widget.currentSelectedTable == table.tableNumber;
                  final statusColor = _getStatusColor(table.status);

                  return InkWell(
                    onTap: () {
                      widget.onTableSelected(table.tableNumber);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? AppColors.primary : AppColors.border,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                table.tableNumber,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getStatusText(table.status),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${table.capacity} Kursi (${table.section})',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          if (table.status == TableStatus.occupied) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${table.occupiedMinutes}m lalu',
                                  style: const TextStyle(fontSize: 11, color: AppColors.warning),
                                ),
                                Text(
                                  CurrencyFormatter.formatCompact(table.activeOrderAmount),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            // Footer Quick Actions (Split Bill / Merge Bill)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur Split Bill: Pilih pesanan untuk dipecah')),
                      );
                    },
                    icon: const Icon(Icons.call_split_rounded, size: 16),
                    label: const Text('Split Bill'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur Merge Bill: Pilih meja untuk digabungkan')),
                      );
                    },
                    icon: const Icon(Icons.merge_type_rounded, size: 16),
                    label: const Text('Merge Bill'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
