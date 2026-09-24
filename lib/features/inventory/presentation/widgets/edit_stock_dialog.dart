import 'package:flutter/material.dart';
import '../../domain/ingredient.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class EditStockDialog extends StatefulWidget {
  final InventoryIngredient ingredient;
  final ValueChanged<InventoryIngredient> onStockUpdated;

  const EditStockDialog({
    super.key,
    required this.ingredient,
    required this.onStockUpdated,
  });

  @override
  State<EditStockDialog> createState() => _EditStockDialogState();
}

class _EditStockDialogState extends State<EditStockDialog> {
  late TextEditingController _nameController;
  late TextEditingController _stockController;
  late TextEditingController _minAlertController;
  late TextEditingController _costController;
  late IngredientUnit _selectedUnit;

  String _adjustmentReason = 'Stock Opname Fisik Rutin';
  final List<String> _reasonOptions = [
    'Stock Opname Fisik Rutin',
    'Barang Rusak / Tumpah di Bar',
    'Kadaluarsa / Expired',
    'Koreksi Salah Hitung',
    'Sampel / Bonus dari Vendor',
    'Penyesuaian Manual Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _stockController = TextEditingController(text: widget.ingredient.currentStock.toInt().toString());
    _minAlertController = TextEditingController(text: widget.ingredient.minStockAlert.toInt().toString());
    _costController = TextEditingController(text: widget.ingredient.costPerUnit.toInt().toString());
    _selectedUnit = widget.ingredient.unit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _minAlertController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final originalStock = widget.ingredient.currentStock;
    final enteredStock = double.tryParse(_stockController.text) ?? originalStock;
    final difference = enteredStock - originalStock;

    return Dialog(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit & Opname Stok Bahan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'SKU: ${widget.ingredient.sku} • Satuan: ${_selectedUnit.name}',
                            style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Bahan
                    const Text(
                      'NAMA BAHAN BAKU',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Nama Bahan Baku',
                        prefixIcon: Icon(Icons.inventory_2_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current Stock Edit with live difference calculation
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'JUMLAH STOK FISIK (${_selectedUnit.name.toUpperCase()})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _stockController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  suffixText: _selectedUnit.name,
                                  suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Stock Difference Card
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: difference == 0
                                  ? AppColors.lightSurfaceLight
                                  : (difference > 0 ? AppColors.accentSoft : AppColors.dangerSoft),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: difference == 0
                                    ? AppColors.lightBorder
                                    : (difference > 0 ? AppColors.accent : AppColors.danger),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  difference == 0
                                      ? 'STOK COCOK'
                                      : (difference > 0 ? 'SURPLUS (+)' : 'DEFISIT (-)'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: difference == 0
                                        ? AppColors.lightTextSecondary
                                        : (difference > 0 ? AppColors.accent : AppColors.danger),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${difference > 0 ? '+' : ''}${difference.toInt()} ${_selectedUnit.name}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: difference == 0
                                        ? AppColors.lightTextPrimary
                                        : (difference > 0 ? AppColors.accent : AppColors.danger),
                                  ),
                                ),
                                Text(
                                  'Sebelum: ${originalStock.toInt()}',
                                  style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Alasan Penyesuaian (Adjustment Reason)
                    if (difference != 0) ...[
                      const Text(
                        'ALASAN PENYESUAIAN STOK',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightSurfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _adjustmentReason,
                            isExpanded: true,
                            items: _reasonOptions.map((reason) {
                              return DropdownMenuItem(
                                value: reason,
                                child: Text(reason, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _adjustmentReason = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Minimum Stock Alert & Cost per Unit
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BATAS MINIMUM ALERT (${_selectedUnit.name})',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _minAlertController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  suffixText: _selectedUnit.name,
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BIAYA POKOK / ${_selectedUnit.name.toUpperCase()} (HPP)',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _costController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixText: 'Rp ',
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Estimasi Nilai Stok Bahan
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estimasi Nilai Total Aset Bahan:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                          ),
                          Text(
                            CurrencyFormatter.format(
                              enteredStock * (double.tryParse(_costController.text) ?? widget.ingredient.costPerUnit),
                            ),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          final newStock = double.tryParse(_stockController.text);
                          final newMinAlert = double.tryParse(_minAlertController.text);
                          final newCost = double.tryParse(_costController.text);
                          final newName = _nameController.text.trim();

                          if (newName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama bahan baku tidak boleh kosong')),
                            );
                            return;
                          }

                          if (newStock == null || newStock < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Jumlah stok fisik tidak valid')),
                            );
                            return;
                          }

                          final updated = widget.ingredient.copyWith(
                            name: newName,
                            currentStock: newStock,
                            minStockAlert: newMinAlert ?? widget.ingredient.minStockAlert,
                            costPerUnit: newCost ?? widget.ingredient.costPerUnit,
                          );

                          widget.onStockUpdated(updated);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Simpan Perubahan Stok'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
