import 'package:flutter/material.dart';
import '../domain/ingredient.dart';
import 'widgets/edit_stock_dialog.dart';
import 'widgets/add_ingredient_dialog.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late List<InventoryIngredient> _ingredients;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ingredients = [
      const InventoryIngredient(
        id: 'ing_espresso_beans',
        sku: 'RAW-COF-01',
        name: 'House Blend Arabica (Gayo & Flores)',
        unit: IngredientUnit.gram,
        currentStock: 4200,
        minStockAlert: 1500,
        costPerUnit: 250, // Rp 250 / gram (Rp 250.000 / kg)
      ),
      const InventoryIngredient(
        id: 'ing_fresh_milk',
        sku: 'RAW-MLK-01',
        name: 'Greenfields Fresh Milk Pasteurized',
        unit: IngredientUnit.ml,
        currentStock: 9500,
        minStockAlert: 3000,
        costPerUnit: 28, // Rp 28 / ml (Rp 28.000 / liter)
      ),
      const InventoryIngredient(
        id: 'ing_oat_milk',
        sku: 'RAW-MLK-02',
        name: 'Oatside Barista Blend Oat Milk',
        unit: IngredientUnit.ml,
        currentStock: 1200, // Low stock!
        minStockAlert: 2000,
        costPerUnit: 42,
      ),
      const InventoryIngredient(
        id: 'ing_gula_aren',
        sku: 'RAW-SGR-01',
        name: 'Gula Aren Cair Organik Nira Murni',
        unit: IngredientUnit.ml,
        currentStock: 3400,
        minStockAlert: 1000,
        costPerUnit: 35,
      ),
      const InventoryIngredient(
        id: 'ing_matcha_powder',
        sku: 'RAW-TEA-01',
        name: 'Kyoto Ceremonial Uji Matcha Powder',
        unit: IngredientUnit.gram,
        currentStock: 450,
        minStockAlert: 200,
        costPerUnit: 1200, // Rp 1.200 / gram
      ),
      const InventoryIngredient(
        id: 'ing_croissant_dough',
        sku: 'RAW-BAK-01',
        name: 'Elle & Vire Frozen Croissant Dough',
        unit: IngredientUnit.pcs,
        currentStock: 14, // Low stock!
        minStockAlert: 25,
        costPerUnit: 8000,
      ),
      const InventoryIngredient(
        id: 'ing_truffle_oil',
        sku: 'RAW-OIL-01',
        name: 'Italian White Truffle Olive Oil',
        unit: IngredientUnit.ml,
        currentStock: 800,
        minStockAlert: 250,
        costPerUnit: 450,
      ),
    ];
  }

  void _showEditStockDialog(InventoryIngredient ingredient) {
    showDialog(
      context: context,
      builder: (ctx) => EditStockDialog(
        ingredient: ingredient,
        onStockUpdated: (updated) {
          setState(() {
            final index = _ingredients.indexWhere((i) => i.id == updated.id);
            if (index != -1) {
              _ingredients[index] = updated;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stok ${updated.name} berhasil diperbarui menjadi ${updated.currentStock.toInt()} ${updated.unit.name}'),
              backgroundColor: AppColors.accent,
            ),
          );
        },
      ),
    );
  }

  void _showAddIngredientDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddIngredientDialog(
        onIngredientAdded: (newIngredient) {
          setState(() {
            _ingredients.add(newIngredient);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bahan baku "${newIngredient.name}" berhasil ditambahkan!'),
              backgroundColor: AppColors.accent,
            ),
          );
        },
      ),
    );
  }

  void _showRestockDialog(InventoryIngredient ingredient) {
    final qtyController = TextEditingController();
    final supplierController = TextEditingController(text: 'PT Sukses Pangan Mandiri');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightSurface,
        title: Row(
          children: [
            const Icon(Icons.add_shopping_cart, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Restock: ${ingredient.name}', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stok saat ini: ${ingredient.currentStock.toInt()} ${ingredient.unit.name}'),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Masuk (${ingredient.unit.name})',
                hintText: 'Contoh: 5000',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: supplierController,
              decoration: const InputDecoration(
                labelText: 'Nama Pemasok / Vendor',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final added = double.tryParse(qtyController.text);
              if (added != null && added > 0) {
                setState(() {
                  final index = _ingredients.indexWhere((i) => i.id == ingredient.id);
                  if (index != -1) {
                    _ingredients[index] = ingredient.copyWith(
                      currentStock: ingredient.currentStock + added,
                    );
                  }
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stok ${ingredient.name} berhasil ditambah +$added ${ingredient.unit.name}'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              }
            },
            child: const Text('Simpan Stok Masuk'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowStockItems = _ingredients.where((i) => i.isLowStock).toList();
    final double totalAssetValue = _ingredients.fold(
      0.0,
      (sum, item) => sum + (item.currentStock * item.costPerUnit),
    );

    final filteredIngredients = _ingredients.where((i) {
      if (_searchQuery.isEmpty) return true;
      return i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.sku.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        title: const Text('Manajemen Bahan Baku & Stok Gudang (HPP)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          ElevatedButton.icon(
            onPressed: _showAddIngredientDialog,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah Bahan'),
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
          // 3 Highlights Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Varian Bahan',
                  '${_ingredients.length} SKU',
                  'Terdaftar aktif di resep',
                  Icons.inventory_2_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildSummaryCard(
                  'Bahan Low Stock',
                  '${lowStockItems.length} Bahan',
                  lowStockItems.isEmpty ? 'Semua stok aman' : 'Perlu PO Restock!',
                  Icons.warning_amber_rounded,
                  lowStockItems.isEmpty ? AppColors.accent : AppColors.danger,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildSummaryCard(
                  'Estimasi Nilai Aset Stok',
                  CurrencyFormatter.format(totalAssetValue),
                  'Berdasarkan HPP beli',
                  Icons.account_balance_wallet_outlined,
                  const Color(0xFF047857),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Low Stock Warning Alert if any
          if (lowStockItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Peringatan: Ada ${lowStockItems.length} bahan baku di bawah batas aman (${lowStockItems.map((e) => e.name).join(', ')}). Segera lakukan restock!',
                      style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari bahan baku berdasarkan nama atau kode SKU...',
                prefixIcon: Icon(Icons.search, size: 20),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(height: 16),

          // Ingredients Table
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: filteredIngredients.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Tidak ada bahan baku yang cocok dengan pencarian.', style: TextStyle(color: AppColors.lightTextMuted)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredIngredients.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final ing = filteredIngredients[index];
                      final progress = (ing.currentStock / (ing.minStockAlert * 3)).clamp(0.0, 1.0);

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: ing.isLowStock ? AppColors.dangerSoft : AppColors.lightSurfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: ing.isLowStock ? AppColors.danger : AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        ing.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightTextPrimary),
                                      ),
                                      const SizedBox(width: 8),
                                      if (ing.isLowStock)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(4)),
                                          child: const Text('LOW STOCK', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SKU: ${ing.sku} • Biaya Pokok: ${CurrencyFormatter.format(ing.costPerUnit)} / ${ing.unit.name} • Total Aset: ${CurrencyFormatter.format(ing.currentStock * ing.costPerUnit)}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(3),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 6,
                                            backgroundColor: AppColors.lightSurfaceLight,
                                            color: ing.isLowStock ? AppColors.danger : AppColors.accent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Min: ${ing.minStockAlert.toInt()} ${ing.unit.name}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.lightTextMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Actions: Stock Count + Edit Stok Button + Restock Button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${ing.currentStock.toInt()} ${ing.unit.name}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ing.isLowStock ? AppColors.danger : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit Stok Button (Opname fisik)
                                    OutlinedButton.icon(
                                      onPressed: () => _showEditStockDialog(ing),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ),
                                      icon: const Icon(Icons.tune_rounded, size: 14),
                                      label: const Text('Edit Stok', style: TextStyle(fontSize: 12)),
                                    ),
                                    const SizedBox(width: 6),
                                    // Restock Button
                                    ElevatedButton.icon(
                                      onPressed: () => _showRestockDialog(ing),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ),
                                      icon: const Icon(Icons.add, size: 14),
                                      label: const Text('Restock', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color) {
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
