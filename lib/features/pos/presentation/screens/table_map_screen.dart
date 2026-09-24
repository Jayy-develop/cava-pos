import 'package:flutter/material.dart';
import '../../domain/entities/cafe_table.dart';
import '../../data/mock_pos_data.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class TableMapScreen extends StatefulWidget {
  final ValueChanged<String>? onSelectTableForOrder;

  const TableMapScreen({super.key, this.onSelectTableForOrder});

  @override
  State<TableMapScreen> createState() => _TableMapScreenState();
}

class _TableMapScreenState extends State<TableMapScreen> {
  String _selectedSection = 'All';

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.vacant:
        return AppColors.accent;
      case TableStatus.occupied:
        return AppColors.warning;
      case TableStatus.reserved:
        return AppColors.info;
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

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        title: const Text('Denah Meja & Floor Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pilih dua meja untuk digabungkan (Merge Bill)')),
              );
            },
            icon: const Icon(Icons.merge_type, size: 16),
            label: const Text('Merge Bill'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pilih tagihan meja untuk dipecah (Split Bill)')),
              );
            },
            icon: const Icon(Icons.call_split, size: 16),
            label: const Text('Split Bill'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Section Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.lightSurface,
            child: Row(
              children: [
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
                            backgroundColor: AppColors.lightSurfaceLight,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          const Divider(height: 1),

          // Grid of Tables
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                final statusColor = _getStatusColor(table.status);

                return InkWell(
                  onTap: () {
                    if (widget.onSelectTableForOrder != null) {
                      widget.onSelectTableForOrder!(table.tableNumber);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Meja ${table.tableNumber} dipilih untuk pesanan.')),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                            Text(
                              table.tableNumber,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getStatusText(table.status),
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.people_alt_outlined, size: 14, color: AppColors.lightTextMuted),
                            const SizedBox(width: 4),
                            Text('${table.capacity} Kursi (${table.section})', style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                          ],
                        ),
                        if (table.status == TableStatus.occupied) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${table.occupiedMinutes} menit lalu', style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600)),
                              Text(CurrencyFormatter.formatCompact(table.activeOrderAmount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
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
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
      ],
    );
  }
}
