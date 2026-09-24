import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../pos/domain/entities/order.dart';
import '../bloc/order_history_bloc.dart';
import '../bloc/order_history_event.dart';
import '../bloc/order_history_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../hardware/services/esc_pos_thermal_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final EscPosThermalService _printerService = EscPosThermalService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showOrderDetailModal(BuildContext context, Order order) {
    final historyBloc = context.read<OrderHistoryBloc>();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
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
                        color: order.paymentStatus == PaymentStatus.paid
                            ? AppColors.accentSoft
                            : AppColors.dangerSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        order.paymentStatus == PaymentStatus.paid
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: order.paymentStatus == PaymentStatus.paid
                            ? AppColors.accent
                            : AppColors.danger,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.lightTextMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Order Summary Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    _buildTag(
                      order.orderType == OrderType.dineIn
                          ? 'Dine In (${order.tableNumber ?? "-"})'
                          : 'Take Away',
                      color: AppColors.info,
                      bgColor: AppColors.infoSoft,
                    ),
                    const SizedBox(width: 8),
                    _buildTag(
                      'Pelanggan: ${order.customerName}',
                      color: AppColors.lightTextSecondary,
                      bgColor: AppColors.lightSurfaceLight,
                    ),
                    const SizedBox(width: 8),
                    _buildTag(
                      'Kasir: ${order.cashierName}',
                      color: AppColors.lightTextSecondary,
                      bgColor: AppColors.lightSurfaceLight,
                    ),
                  ],
                ),
              ),

              // Item List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                                if (item.selectedVariant != null)
                                  Text(
                                    'Size: ${item.selectedVariant!.name}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                                  ),
                                for (final mod in item.selectedModifiers)
                                  Text(
                                    '+ ${mod.name}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                                  ),
                                if (item.notes.isNotEmpty)
                                  Text(
                                    'Note: ${item.notes}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.warning),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.netTotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),

              // Financial Calculation Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    _buildDetailRow('Subtotal', CurrencyFormatter.format(order.subtotal)),
                    if (order.orderDiscount > 0)
                      _buildDetailRow('Diskon', '-${CurrencyFormatter.format(order.orderDiscount)}', color: AppColors.accent),
                    if (order.serviceChargeAmount > 0)
                      _buildDetailRow('Service Charge (5%)', CurrencyFormatter.format(order.serviceChargeAmount)),
                    _buildDetailRow('PB1 (10%)', CurrencyFormatter.format(order.taxAmount)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL AKHIR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(
                          CurrencyFormatter.format(order.grandTotal),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Metode Bayar: ${order.paymentMethod?.name.toUpperCase() ?? "-"}', style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                        if (order.paymentMethod == PaymentMethod.cash)
                          Text('Kembalian: ${CurrencyFormatter.format(order.cashChange)}', style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Actions: Reprint & Void
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Cetak Struk Pelanggan
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _printerService.generateCustomerReceipt(order: order, openCashDrawer: false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Mencetak ulang struk ${order.orderNumber}')),
                          );
                        },
                        icon: const Icon(Icons.print, size: 16),
                        label: const Text('Cetak Struk'),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Cetak Kitchen Ticket
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _printerService.generateKitchenTicket(order: order);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Mencetak tiket kitchen ${order.orderNumber}')),
                          );
                        },
                        icon: const Icon(Icons.kitchen, size: 16),
                        label: const Text('Tiket Bar'),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Void Transaction Button
                    if (order.paymentStatus == PaymentStatus.paid)
                      ElevatedButton.icon(
                        onPressed: () {
                          _showVoidConfirmationDialog(context, historyBloc, order);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        icon: const Icon(Icons.cancel, size: 16, color: Colors.white),
                        label: const Text('Void', style: TextStyle(color: Colors.white)),
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

  void _showVoidConfirmationDialog(
    BuildContext context,
    OrderHistoryBloc bloc,
    Order order,
  ) {
    final pinController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightSurface,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Otorisasi Void Transaksi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan membatalkan invoice ${order.orderNumber} senilai ${CurrencyFormatter.format(order.grandTotal)}.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'PIN Supervisor / Owner',
                hintText: 'Default PIN: 1234',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Pembatalan (Void)',
                hintText: 'Contoh: Salah input pesanan / Pelanggan ganti menu',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final pin = pinController.text;
              final reason = reasonController.text;
              if (pin.isEmpty) return;

              bloc.add(VoidOrderEvent(
                orderId: order.id,
                reason: reason.isNotEmpty ? reason : 'Void oleh Supervisor',
                supervisorPin: pin,
              ));

              Navigator.of(ctx).pop(); // Close confirm dialog
              Navigator.of(context).pop(); // Close detail modal
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Konfirmasi Void', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color ?? AppColors.lightTextPrimary)),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderHistoryBloc, OrderHistoryState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.accent),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.danger),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor: AppColors.lightSurface,
            title: const Text('Riwayat Transaksi & Struk', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Muat Ulang',
                onPressed: () {
                  context.read<OrderHistoryBloc>().add(LoadOrderHistory());
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Top Stats Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Omzet Riwayat',
                        CurrencyFormatter.format(state.totalRevenue),
                        Icons.payments_outlined,
                        AppColors.accent,
                      ),
                    ),
                    const VerticalDivider(width: 32),
                    Expanded(
                      child: _buildStatItem(
                        'Transaksi Selesai',
                        '${state.paidCount} Pesanan',
                        Icons.check_circle_outline,
                        AppColors.primary,
                      ),
                    ),
                    const VerticalDivider(width: 32),
                    Expanded(
                      child: _buildStatItem(
                        'Transaksi Dibatalkan',
                        '${state.voidCount} Void',
                        Icons.cancel_outlined,
                        AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Controls Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          context.read<OrderHistoryBloc>().add(FilterOrdersEvent(
                                searchQuery: val,
                                statusFilter: state.statusFilter,
                                methodFilter: state.methodFilter,
                              ));
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari invoice (e.g. CAVA-2026...), meja, pelanggan...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.lightTextMuted),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<OrderHistoryBloc>().add(FilterOrdersEvent(
                                          searchQuery: '',
                                          statusFilter: state.statusFilter,
                                          methodFilter: state.methodFilter,
                                        ));
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Status Filter
                    _buildFilterChip(
                      label: 'Semua Status',
                      isSelected: state.statusFilter == null,
                      onTap: () {
                        context.read<OrderHistoryBloc>().add(FilterOrdersEvent(
                              searchQuery: state.searchQuery,
                              statusFilter: null,
                              methodFilter: state.methodFilter,
                            ));
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Selesai (Paid)',
                      isSelected: state.statusFilter == PaymentStatus.paid,
                      onTap: () {
                        context.read<OrderHistoryBloc>().add(FilterOrdersEvent(
                              searchQuery: state.searchQuery,
                              statusFilter: PaymentStatus.paid,
                              methodFilter: state.methodFilter,
                            ));
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      label: 'Void (Batal)',
                      isSelected: state.statusFilter == PaymentStatus.voided,
                      onTap: () {
                        context.read<OrderHistoryBloc>().add(FilterOrdersEvent(
                              searchQuery: state.searchQuery,
                              statusFilter: PaymentStatus.voided,
                              methodFilter: state.methodFilter,
                            ));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Orders List
              Expanded(
                child: state.filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.lightTextMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 10),
                            const Text(
                              'Tidak ada transaksi yang cocok dengan filter',
                              style: TextStyle(color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filteredOrders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final order = state.filteredOrders[index];
                          final isPaid = order.paymentStatus == PaymentStatus.paid;

                          return InkWell(
                            onTap: () => _showOrderDetailModal(context, order),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.lightBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Icon Badge
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isPaid ? AppColors.accentSoft : AppColors.dangerSoft,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isPaid ? Icons.check_circle_outline : Icons.cancel_outlined,
                                      color: isPaid ? AppColors.accent : AppColors.danger,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Invoice Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              order.orderNumber,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.lightTextPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _buildTag(
                                              order.orderType == OrderType.dineIn
                                                  ? 'Meja ${order.tableNumber ?? "-"}'
                                                  : 'Take Away',
                                              color: AppColors.info,
                                              bgColor: AppColors.infoSoft,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${order.items.length} Menu • ${order.customerName} • ${DateFormat('HH:mm').format(order.createdAt)} WIB',
                                          style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Payment Method & Total
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(order.grandTotal),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isPaid ? AppColors.lightTextPrimary : AppColors.danger,
                                          decoration: isPaid ? null : TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightSurfaceLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          order.paymentMethod?.name.toUpperCase() ?? 'UNPAID',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.lightTextSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, color: AppColors.lightTextMuted),
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
      },
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.lightSurface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.lightTextSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
