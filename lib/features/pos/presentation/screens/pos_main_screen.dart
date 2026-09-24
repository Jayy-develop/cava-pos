import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../data/mock_pos_data.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/modifier_selection_dialog.dart';
import '../widgets/cart_summary_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/role_switcher_dialog.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_state.dart';
import '../widgets/menu_management_modal.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/network/cloud_sync_service.dart';
import '../../../../core/network/sync_status_modal.dart';

class PosMainScreen extends StatefulWidget {
  const PosMainScreen({super.key});

  @override
  State<PosMainScreen> createState() => _PosMainScreenState();
}

class _PosMainScreenState extends State<PosMainScreen> {
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _onProductTapped(Product product) {
    if (product.variants.isNotEmpty || product.modifierGroups.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => ModifierSelectionDialog(
          product: product,
          onConfirm: ({
            required variant,
            required selectedModifiers,
            required notes,
            required quantity,
          }) {
            context.read<CartBloc>().add(
                  AddProductToCart(
                    product: product,
                    variant: variant,
                    selectedModifiers: selectedModifiers,
                    notes: notes,
                    quantity: quantity,
                  ),
                );
          },
        ),
      );
    } else {
      context.read<CartBloc>().add(AddProductToCart(product: product));
    }
  }

  void _showShiftReportModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.point_of_sale, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Status Shift Kasir (X-Report)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kasir: Arya (ID: CSH-01)', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Shift Mulai: 11 Sep 2026, 08:00 WIB'),
            const Divider(height: 24),
            _buildReportRow('Modal Kas Awal:', 'Rp 500.000'),
            _buildReportRow('Total Penjualan Tunai:', 'Rp 2.450.000'),
            _buildReportRow('Total Non-Tunai (QRIS/EDC):', 'Rp 4.820.000'),
            _buildReportRow('Total Transaksi:', '46 Transaksi'),
            const Divider(height: 24),
            _buildReportRow('Total Kas Fisik Diharapkan:', 'Rp 2.950.000', isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cetak X-Report'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shift berhasil ditutup. Laporan Z-Report dicetak.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Tutup Shift (Z-Report)'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isBold ? AppColors.accent : AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTabletLandscape = constraints.maxWidth >= 900;

        return Scaffold(
          appBar: _buildAppBar(context, isTabletLandscape),
          body: isTabletLandscape
              ? Row(
                  children: [
                    // Master: Menu Catalog & Categories
                    Expanded(
                      child: _buildMenuContent(isTabletLandscape),
                    ),
                    // Detail: Sticky Cart & Checkout Panel
                    const SizedBox(
                      width: 390,
                      child: CartSummaryView(isMobile: false),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    _buildMenuContent(isTabletLandscape),
                    // Mobile Bottom Floating Cart Bar
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: _buildMobileCartBottomBar(context),
                    ),
                  ],
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.coffee, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'CAVA POS',
            style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 16),
          // User Role Pill (Click to Switch between Kasir & Owner)
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isOwner = authState.isOwner;
              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const RoleSwitcherDialog(),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOwner
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.infoSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOwner ? AppColors.primary : AppColors.info,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(isOwner ? '👑' : '👤', style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 6),
                      Text(
                        isOwner
                            ? 'Owner (${authState.currentUser.name})'
                            : 'Kasir (${authState.currentUser.name})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOwner ? AppColors.primaryDark : AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swap_horiz,
                        size: 14,
                        color: isOwner ? AppColors.primaryDark : AppColors.info,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        // Sync Status Indicator
        ListenableBuilder(
          listenable: CloudSyncService(),
          builder: (context, _) {
            final syncService = CloudSyncService();
            final isOnline = syncService.isOnline;
            final isSyncing = syncService.isSyncing;
            final pendingCount = syncService.pendingOrdersCount;

            return Tooltip(
              message: isOnline
                  ? (pendingCount > 0
                      ? '$pendingCount pesanan tersimpan di lokal. Klik untuk sinkronkan'
                      : 'Terhubung ke Cloud Database (Supabase). Klik untuk detail')
                  : 'Mode Offline (Lokal DB). Klik untuk detail & simulasi',
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const SyncStatusModal(),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? (pendingCount > 0 ? AppColors.warningSoft : AppColors.accentSoft)
                        : AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOnline
                          ? (pendingCount > 0 ? AppColors.warning : AppColors.accent)
                          : AppColors.danger,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOnline
                            ? (isSyncing ? Icons.sync : (pendingCount > 0 ? Icons.cloud_queue : Icons.cloud_done))
                            : Icons.cloud_off,
                        color: isOnline
                            ? (pendingCount > 0 ? AppColors.warning : AppColors.accent)
                            : AppColors.danger,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline
                            ? (isSyncing ? 'Sinkron...' : (pendingCount > 0 ? 'Pending ($pendingCount)' : 'Online DB'))
                            : 'Offline DB',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOnline
                              ? (pendingCount > 0 ? AppColors.warning : AppColors.accent)
                              : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Laporan Shift (X/Z Report)',
          icon: const Icon(Icons.assessment_outlined),
          onPressed: () => _showShiftReportModal(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMenuContent(bool isTablet) {
    return BlocListener<MenuBloc, MenuState>(
      listener: (context, menuState) {
        if (menuState.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(menuState.successMessage!),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      },
      child: Column(
        children: [
          // Search & Category Filter Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                // Search Input
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari menu (e.g. Latte, Croissant, CAV-COF)...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Kelola Menu & Harga Button
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const MenuManagementModal(),
                    );
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Kelola Harga'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ],
            ),
          ),

          // Category Pills
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: MockPosData.categories.length,
              itemBuilder: (context, index) {
                final cat = MockPosData.categories[index];
                final isSelected = _selectedCategoryId == cat.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceLight,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    onSelected: (_) => setState(() => _selectedCategoryId = cat.id),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Products Grid from MenuBloc
          Expanded(
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, menuState) {
                final activeProducts = menuState.allProducts.where((prod) {
                  final matchesCategory =
                      _selectedCategoryId == 'all' || prod.categoryId == _selectedCategoryId;
                  final matchesQuery = _searchQuery.isEmpty ||
                      prod.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      prod.sku.toLowerCase().contains(_searchQuery.toLowerCase());
                  return matchesCategory && matchesQuery;
                }).toList();

                if (activeProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        const Text(
                          'Menu tidak ditemukan',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, isTablet ? 16 : 90),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2,
                    childAspectRatio: isTablet ? 0.82 : 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: activeProducts.length,
                  itemBuilder: (context, index) {
                    final product = activeProducts[index];
                    return ProductGridCard(
                      product: product,
                      onTap: () => _onProductTapped(product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCartBottomBar(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${state.totalQuantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Pesanan',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    Text(
                      CurrencyFormatter.format(state.calculation.grandTotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => FractionallySizedBox(
                      heightFactor: 0.85,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: const CartSummaryView(isMobile: true),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long, size: 16),
                label: const Text('Lihat Keranjang'),
              ),
            ],
          ),
        );
      },
    );
  }
}
