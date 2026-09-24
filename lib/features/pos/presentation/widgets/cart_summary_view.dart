import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'table_management_modal.dart';
import 'payment_dialog.dart';
import 'receipt_preview_dialog.dart';
import '../../../history/bloc/order_history_bloc.dart';
import '../../../history/bloc/order_history_event.dart';

class CartSummaryView extends StatelessWidget {
  final bool isMobile;

  const CartSummaryView({
    super.key,
    this.isMobile = false,
  });

  void _showDiscountModal(BuildContext context) {
    final cartBloc = context.read<CartBloc>();
    final TextEditingController percentCtrl = TextEditingController();
    final TextEditingController amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Terapkan Diskon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: percentCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Diskon Persen (%)',
                hintText: 'Contoh: 10 untuk 10%',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Diskon Nominal (Rp)',
                hintText: 'Contoh: 15000',
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
              final pct = double.tryParse(percentCtrl.text);
              final amt = double.tryParse(amountCtrl.text);
              cartBloc.add(ApplyDiscountEvent(
                percentage: pct != null ? pct / 100.0 : null,
                fixedAmount: amt,
              ));
              Navigator.of(ctx).pop();
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state.status == CartStatus.success && state.lastCompletedOrder != null) {
          context.read<OrderHistoryBloc>().add(AddCompletedOrder(state.lastCompletedOrder!));
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => ReceiptPreviewDialog(
              order: state.lastCompletedOrder!,
              onNewOrder: () {
                context.read<CartBloc>().add(ClearCartEvent());
              },
            ),
          );
        } else if (state.status == CartStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      builder: (context, state) {
        final calc = state.calculation;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: isMobile
                ? null
                : const Border(left: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Column(
            children: [
              // Header: Order Type Toggle & Table Selector
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Dine-in / Takeaway segmented control
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              context.read<CartBloc>().add(
                                    const ChangeOrderType(OrderType.dineIn),
                                  );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: state.orderType == OrderType.dineIn
                                    ? AppColors.primary
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant,
                                    size: 16,
                                    color: state.orderType == OrderType.dineIn
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Dine In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: state.orderType == OrderType.dineIn
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              context.read<CartBloc>().add(
                                    const ChangeOrderType(OrderType.takeAway),
                                  );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: state.orderType == OrderType.takeAway
                                    ? AppColors.primary
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 16,
                                    color: state.orderType == OrderType.takeAway
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Take Away',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: state.orderType == OrderType.takeAway
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Table Selector Badge (if Dine-in)
                    if (state.orderType == OrderType.dineIn)
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => TableManagementModal(
                              currentSelectedTable: state.selectedTable,
                              onTableSelected: (tbl) {
                                context.read<CartBloc>().add(SelectTableEvent(tbl));
                              },
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.table_bar_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.selectedTable != null
                                      ? 'Meja: ${state.selectedTable}'
                                      : 'Pilih Meja (Default T-01)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),

              // Items List
              Expanded(
                child: state.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 10),
                            const Text(
                              'Keranjang Kosong',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                            ),
                            const Text(
                              'Pilih menu di samping untuk memesan',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            CurrencyFormatter.format(item.unitPrice),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Stepper
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                                          color: AppColors.textMuted,
                                          onPressed: () {
                                            context.read<CartBloc>().add(
                                                  UpdateItemQuantity(
                                                    itemId: item.id,
                                                    newQuantity: item.quantity - 1,
                                                  ),
                                                );
                                          },
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, size: 20),
                                          color: AppColors.primary,
                                          onPressed: () {
                                            context.read<CartBloc>().add(
                                                  UpdateItemQuantity(
                                                    itemId: item.id,
                                                    newQuantity: item.quantity + 1,
                                                  ),
                                                );
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                      CurrencyFormatter.format(item.netTotal),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),

                                // Modifiers & Notes preview
                                if (item.selectedVariant != null ||
                                    item.selectedModifiers.isNotEmpty ||
                                    item.notes.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        if (item.selectedVariant != null)
                                          _buildBadge(item.selectedVariant!.name),
                                        ...item.selectedModifiers.map((m) => _buildBadge(m.name)),
                                        if (item.notes.isNotEmpty)
                                          _buildBadge('Note: ${item.notes}', isNote: true),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const Divider(),

              // Calculation Summary & Checkout Action
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCalculationRow('Subtotal', CurrencyFormatter.format(calc.subtotal)),
                    if (calc.orderDiscount > 0)
                      _buildCalculationRow('Diskon', '-${CurrencyFormatter.format(calc.orderDiscount)}', color: AppColors.accent),
                    if (calc.serviceChargeAmount > 0)
                      _buildCalculationRow('Service Charge (5%)', CurrencyFormatter.format(calc.serviceChargeAmount)),
                    _buildCalculationRow('Pajak Restoran PB1 (10%)', CurrencyFormatter.format(calc.taxAmount)),
                    if (calc.roundingAmount != 0)
                      _buildCalculationRow('Pembulatan', CurrencyFormatter.format(calc.roundingAmount)),

                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Grand Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          CurrencyFormatter.format(calc.grandTotal),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Action Buttons
                    Row(
                      children: [
                        // Quick Discount Button
                        OutlinedButton(
                          onPressed: () => _showDiscountModal(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          child: const Icon(Icons.discount_outlined, size: 20),
                        ),
                        const SizedBox(width: 8),

                        // Pay Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: state.items.isEmpty
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => PaymentDialog(
                                        calculation: calc,
                                        customerName: state.customerName,
                                        tableNumber: state.selectedTable,
                                        orderType: state.orderType,
                                        onPayConfirmed: (method, cashReceived) {
                                          context.read<CartBloc>().add(
                                                CheckoutCartEvent(
                                                  paymentMethod: method,
                                                  cashReceived: cashReceived,
                                                  cashierId: 'cashier-001',
                                                  cashierName: 'Arya (Kasir)',
                                                ),
                                              );
                                        },
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.payment, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Bayar (${CurrencyFormatter.format(calc.grandTotal)})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, {bool isNote = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isNote ? AppColors.warning.withValues(alpha: 0.15) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: isNote ? AppColors.warning : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
