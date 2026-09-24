import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../hardware/services/esc_pos_thermal_service.dart';

class ReceiptPreviewDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onNewOrder;

  const ReceiptPreviewDialog({
    super.key,
    required this.order,
    required this.onNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    final printerService = EscPosThermalService();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 750),
        child: Column(
          children: [
            // Success Top Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Transaksi Berhasil!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Thermal Paper Preview Simulation
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2), // Thermal paper creamy off-white
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      color: Color(0xFF262626),
                      fontSize: 12,
                      height: 1.3,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            'CAVA COFFEE',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const Center(child: Text('Specialty Roastery & Eatery')),
                        const Center(child: Text('Jl. Senopati No. 88, Jakarta')),
                        const Center(child: Text('WiFi: Cava_Guest / cava2026')),
                        const SizedBox(height: 8),
                        const Text('--------------------------------'),
                        Text('No: ${order.orderNumber}'),
                        Text('Kasir: ${order.cashierName}'),
                        Text('Tipe: ${order.orderType == OrderType.dineIn ? "Dine In (${order.tableNumber ?? "-"})" : "Take Away"}'),
                        const Text('--------------------------------'),

                        // Items
                        ...order.items.map((item) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.quantity}x ${item.productName}'),
                                  Text(CurrencyFormatter.format(item.grossTotal)),
                                ],
                              ),
                              if (item.selectedVariant != null)
                                Text('   Variant: ${item.selectedVariant!.name}'),
                              ...item.selectedModifiers.map(
                                (m) => Text('   + ${m.name}'),
                              ),
                              if (item.notes.isNotEmpty)
                                Text('   *Note: ${item.notes}'),
                            ],
                          );
                        }),

                        const Text('--------------------------------'),
                        _buildRow('Subtotal', CurrencyFormatter.format(order.subtotal)),
                        if (order.orderDiscount > 0)
                          _buildRow('Diskon', '-${CurrencyFormatter.format(order.orderDiscount)}'),
                        if (order.serviceChargeAmount > 0)
                          _buildRow('Service Charge (5%)', CurrencyFormatter.format(order.serviceChargeAmount)),
                        if (order.taxAmount > 0)
                          _buildRow('PB1 (10%)', CurrencyFormatter.format(order.taxAmount)),
                        if (order.roundingAmount != 0)
                          _buildRow('Pembulatan', CurrencyFormatter.format(order.roundingAmount)),
                        const Text('================================'),
                        _buildRow('TOTAL', CurrencyFormatter.format(order.grandTotal), isBold: true),
                        const Text('--------------------------------'),
                        _buildRow('Metode', order.paymentMethod?.name.toUpperCase() ?? 'CASH'),
                        if (order.paymentMethod == PaymentMethod.cash) ...[
                          _buildRow('Tunai', CurrencyFormatter.format(order.cashReceived)),
                          _buildRow('Kembalian', CurrencyFormatter.format(order.cashChange)),
                        ],
                        const Text('--------------------------------'),
                        const SizedBox(height: 6),
                        const Center(child: Text('Terima Kasih!')),
                        const Center(child: Text('IG: @cavacoffee.id')),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Printer Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            printerService.generateCustomerReceipt(order: order);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mengirim Struk ke Printer Kasir 58mm...')),
                            );
                          },
                          icon: const Icon(Icons.receipt_long, size: 16),
                          label: const Text('Cetak Struk'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            printerService.generateKitchenTicket(order: order);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mengirim Tiket ke Bar/Kitchen Printer...')),
                            );
                          },
                          icon: const Icon(Icons.kitchen, size: 16),
                          label: const Text('Tiket Bar/Dapur'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onNewOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Mulai Transaksi Baru'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String left, String right, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(right, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
