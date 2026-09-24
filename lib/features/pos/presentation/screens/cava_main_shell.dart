import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import 'pos_main_screen.dart';
import 'table_map_screen.dart';
import '../../../history/presentation/order_history_screen.dart';
import '../../../inventory/presentation/inventory_screen.dart';
import '../../../analytics/presentation/analytics_screen.dart';
import '../../../financial_report/presentation/financial_report_screen.dart';
import '../../../shift/presentation/shift_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/owner_access_barrier.dart';
import '../../../auth/presentation/widgets/role_switcher_dialog.dart';
import '../../../../core/constants/app_colors.dart';

class CavaMainShell extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final VoidCallback onToggleTheme;

  const CavaMainShell({
    super.key,
    required this.currentThemeMode,
    required this.onToggleTheme,
  });

  @override
  State<CavaMainShell> createState() => _CavaMainShellState();
}

class _CavaMainShellState extends State<CavaMainShell> {
  int _selectedIndex = 0;

  void _navigateToPosWithTable(String tableNumber) {
    context.read<CartBloc>().add(SelectTableEvent(tableNumber));
    setState(() => _selectedIndex = 0);
  }

  void _openRoleSwitcher(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const RoleSwitcherDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = widget.currentThemeMode == ThemeMode.light;

    final screens = [
      const PosMainScreen(),
      TableMapScreen(onSelectTableForOrder: _navigateToPosWithTable),
      const OrderHistoryScreen(),
      const InventoryScreen(),
      // Analytics screen (protected for Owner)
      const OwnerAccessBarrier(title: 'Dashboard Analitik Owner', child: AnalyticsScreen()),
      // Financial Report screen (P&L, PDF & Excel export)
      const OwnerAccessBarrier(title: 'Laporan Keuangan & Laba Rugi', child: FinancialReportScreen()),
      const ShiftScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                // Left Slim Navigation Rail
                Container(
                  width: 82,
                  decoration: BoxDecoration(
                    color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
                    border: Border(
                      right: BorderSide(
                        color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // App Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.coffee_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 20),

                      // Nav Items
                      _buildNavRailItem(0, Icons.point_of_sale_rounded, 'Kasir', isLight),
                      _buildNavRailItem(1, Icons.table_restaurant_rounded, 'Meja', isLight),
                      _buildNavRailItem(2, Icons.receipt_long_rounded, 'Riwayat', isLight),
                      _buildNavRailItem(3, Icons.inventory_2_rounded, 'Stok', isLight),
                      _buildNavRailItem(4, Icons.insights_rounded, 'Analitik', isLight),
                      _buildNavRailItem(5, Icons.account_balance_rounded, 'Keuangan', isLight),
                      _buildNavRailItem(6, Icons.access_time_rounded, 'Shift', isLight),

                      const Spacer(),

                      // Theme Mode Toggle Button (Cerah / Gelap)
                      IconButton(
                        tooltip: isLight ? 'Beralih ke Tema Gelap' : 'Beralih ke Tema Cerah',
                        icon: Icon(
                          isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                          color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                        ),
                        onPressed: widget.onToggleTheme,
                      ),
                      const SizedBox(height: 8),

                      // Interactive User Role Switcher Avatar
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          final isOwner = authState.isOwner;

                          return Tooltip(
                            message: isOwner
                                ? 'Role: Business Owner (${authState.currentUser.name})\nKlik untuk ganti role'
                                : 'Role: Kasir (${authState.currentUser.name})\nKlik untuk ganti role',
                            child: InkWell(
                              onTap: () => _openRoleSwitcher(context),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: isOwner
                                      ? AppColors.primary.withValues(alpha: 0.12)
                                      : AppColors.infoSoft,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isOwner ? AppColors.primary : AppColors.info,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: isOwner ? AppColors.primary : AppColors.info,
                                      child: Text(
                                        isOwner ? '👑' : 'A',
                                        style: TextStyle(
                                          fontSize: isOwner ? 12 : 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isOwner ? 'Owner' : 'Kasir',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isOwner ? AppColors.primaryDark : AppColors.info,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Main Body Screen
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Layout
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.point_of_sale_rounded), label: 'Kasir'),
              NavigationDestination(icon: Icon(Icons.table_restaurant_rounded), label: 'Meja'),
              NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Riwayat'),
              NavigationDestination(icon: Icon(Icons.inventory_2_rounded), label: 'Stok'),
              NavigationDestination(icon: Icon(Icons.insights_rounded), label: 'Analitik'),
              NavigationDestination(icon: Icon(Icons.account_balance_rounded), label: 'Keuangan'),
              NavigationDestination(icon: Icon(Icons.access_time_rounded), label: 'Shift'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavRailItem(int index, IconData icon, String label, bool isLight) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: isLight ? 0.12 : 0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : (isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : (isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
