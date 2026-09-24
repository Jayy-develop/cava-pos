import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import 'edit_menu_price_dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class MenuManagementModal extends StatefulWidget {
  const MenuManagementModal({super.key});

  @override
  State<MenuManagementModal> createState() => _MenuManagementModalState();
}

class _MenuManagementModalState extends State<MenuManagementModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openEditDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => EditMenuPriceDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MenuBloc, MenuState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      },
      builder: (context, state) {
        final products = state.allProducts.where((p) {
          return _search.isEmpty ||
              p.name.toLowerCase().contains(_search.toLowerCase()) ||
              p.sku.toLowerCase().contains(_search.toLowerCase());
        }).toList();

        return Dialog(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.lightBorder),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780, maxHeight: 720),
            child: Column(
              children: [
                // Modal Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelola Menu & Perubahan Harga',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                            ),
                            Text(
                              'Atur harga jual resmi konsumen, biaya pokok (HPP), dan status ketersediaan',
                              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.lightTextMuted),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _search = val),
                    decoration: InputDecoration(
                      hintText: 'Cari menu yang ingin diubah harganya...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.lightTextMuted),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Product Price Table
                Expanded(
                  child: products.isEmpty
                      ? const Center(
                          child: Text('Menu tidak ditemukan', style: TextStyle(color: AppColors.lightTextSecondary)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: products.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = products[index];
                            final margin = item.basePrice - item.costPrice;
                            final marginPct = item.basePrice > 0 ? (margin / item.basePrice) * 100 : 0.0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  // Availability Indicator
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: item.isAvailable ? AppColors.accent : AppColors.danger,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Product Info
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightTextPrimary),
                                        ),
                                        Text(
                                          '${item.sku} • Kategori: ${item.categoryId.toUpperCase()}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Pricing & Margin Column
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyFormatter.format(item.basePrice),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                                        ),
                                        Text(
                                          'HPP: ${CurrencyFormatter.format(item.costPrice)} (Margin ${marginPct.toStringAsFixed(0)}%)',
                                          style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Toggle Availability
                                  Switch(
                                    value: item.isAvailable,
                                    activeThumbColor: AppColors.accent,
                                    onChanged: (_) {
                                      context.read<MenuBloc>().add(
                                            ToggleProductAvailabilityEvent(item.id),
                                          );
                                    },
                                  ),
                                  const SizedBox(width: 8),

                                  // Edit Button
                                  OutlinedButton.icon(
                                    onPressed: () => _openEditDialog(context, item),
                                    icon: const Icon(Icons.edit, size: 14),
                                    label: const Text('Ubah Harga'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const Divider(height: 1),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Menu: ${products.length} Item',
                        style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                      ),
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
      },
    );
  }
}
