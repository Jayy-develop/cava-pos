import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/ingredient.dart';
import '../../../../core/constants/app_colors.dart';

class AddIngredientDialog extends StatefulWidget {
  final ValueChanged<InventoryIngredient> onIngredientAdded;

  const AddIngredientDialog({super.key, required this.onIngredientAdded});

  @override
  State<AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockController = TextEditingController(text: '1000');
  final _minAlertController = TextEditingController(text: '200');
  final _costController = TextEditingController(text: '50');
  IngredientUnit _unit = IngredientUnit.gram;

  @override
  void initState() {
    super.initState();
    _skuController.text = 'RAW-ING-${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _minAlertController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                      child: const Icon(Icons.add_box_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Bahan Baku Baru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Daftarkan bahan baku atau kemasan ke sistem inventaris',
                            style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
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
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Bahan Baku',
                        hintText: 'Contoh: Sirup Hazelnut Monin / Biji Kopi Toraja',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // SKU & Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _skuController,
                            decoration: const InputDecoration(
                              labelText: 'Kode SKU',
                              prefixIcon: Icon(Icons.qr_code),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<IngredientUnit>(
                            initialValue: _unit,
                            decoration: const InputDecoration(labelText: 'Satuan'),
                            items: IngredientUnit.values.map((u) {
                              return DropdownMenuItem(value: u, child: Text(u.name.toUpperCase()));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _unit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Stok Awal & Min Alert
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Stok Awal Masuk',
                              suffixText: _unit.name,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _minAlertController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Batas Min. Peringatan',
                              suffixText: _unit.name,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Biaya per unit
                    TextField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Biaya Pokok per Satuan (${_unit.name})',
                        prefixText: 'Rp ',
                        hintText: 'Contoh: 150',
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
                          final name = _nameController.text.trim();
                          final sku = _skuController.text.trim();
                          final stock = double.tryParse(_stockController.text);
                          final minAlert = double.tryParse(_minAlertController.text);
                          final cost = double.tryParse(_costController.text);

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama bahan baku tidak boleh kosong')),
                            );
                            return;
                          }

                          final newIngredient = InventoryIngredient(
                            id: 'ing_${const Uuid().v4().substring(0, 8)}',
                            sku: sku.isNotEmpty ? sku : 'RAW-${DateTime.now().millisecondsSinceEpoch % 1000}',
                            name: name,
                            unit: _unit,
                            currentStock: stock ?? 0.0,
                            minStockAlert: minAlert ?? 100.0,
                            costPerUnit: cost ?? 0.0,
                          );

                          widget.onIngredientAdded(newIngredient);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Daftarkan Bahan'),
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
