import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import '../../domain/services/cart_calculator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class PaymentDialog extends StatefulWidget {
  final CartCalculationResult calculation;
  final String customerName;
  final String? tableNumber;
  final OrderType orderType;
  final void Function(PaymentMethod method, double cashReceived) onPayConfirmed;

  const PaymentDialog({
    super.key,
    required this.calculation,
    required this.customerName,
    required this.tableNumber,
    required this.orderType,
    required this.onPayConfirmed,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final TextEditingController _cashController = TextEditingController();
  double _cashReceived = 0.0;

  @override
  void initState() {
    super.initState();
    _cashReceived = widget.calculation.grandTotal;
    _cashController.text = widget.calculation.grandTotal.toInt().toString();
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _setCashAmount(double amount) {
    setState(() {
      _cashReceived = amount;
      _cashController.text = amount.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = widget.calculation.grandTotal;
    final changeResult = CartCalculator.calculateChange(
      grandTotal: grandTotal,
      cashReceived: _cashReceived,
    );

    // Common cash quick amounts in Indonesia
    final quickAmounts = [
      grandTotal, // Uang Pas
      50000.0,
      100000.0,
      150000.0,
      200000.0,
    ].where((amt) => amt >= grandTotal).toSet().toList();

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.payments_rounded, color: AppColors.accent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pembayaran / Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.orderType == OrderType.dineIn ? "Dine In (${widget.tableNumber ?? '-'})" : "Take Away"} • Pelanggan: ${widget.customerName}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Total Payable Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL TAGIHAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Termasuk PB1 10% & Servis',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(grandTotal),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Method Selector
                  const Text(
                    'METODE PEMBAYARAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMethodButton(PaymentMethod.cash, Icons.money_rounded, 'Tunai (Cash)'),
                      const SizedBox(width: 8),
                      _buildMethodButton(PaymentMethod.qris, Icons.qr_code_2_rounded, 'QRIS'),
                      const SizedBox(width: 8),
                      _buildMethodButton(PaymentMethod.debitCard, Icons.credit_card_rounded, 'Kartu Debit/Kredit'),
                      const SizedBox(width: 8),
                      _buildMethodButton(PaymentMethod.eWallet, Icons.account_balance_wallet_rounded, 'E-Wallet'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Method Specific Details
                  if (_selectedMethod == PaymentMethod.cash) ...[
                    // Cash Input & Change Calculator
                    const Text(
                      'UANG TUNAI DITERIMA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cashController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _cashReceived = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Quick Cash Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickAmounts.map((amt) {
                        final isPas = amt == grandTotal;
                        return ActionChip(
                          label: Text(isPas ? 'Uang Pas' : CurrencyFormatter.formatCompact(amt)),
                          backgroundColor: AppColors.surfaceLight,
                          labelStyle: TextStyle(
                            color: isPas ? AppColors.accent : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () => _setCashAmount(amt),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Kembalian (Change) Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: changeResult.isSufficient
                            ? AppColors.accent.withValues(alpha: 0.1)
                            : AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: changeResult.isSufficient ? AppColors.accent : AppColors.danger,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            changeResult.isSufficient ? 'KEMBALIAN' : 'UANG KURANG',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: changeResult.isSufficient ? AppColors.accent : AppColors.danger,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(changeResult.change),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: changeResult.isSufficient ? AppColors.accent : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_selectedMethod == PaymentMethod.qris) ...[
                    // QRIS Display Simulation
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'QRIS STANDAR PEMBAYARAN NASIONAL',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 170,
                              height: 170,
                              color: Colors.black12,
                              child: const Center(
                                child: Icon(Icons.qr_code_2, size: 160, color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Scan melalui BCA, Mandiri, GoPay, OVO, ShopeePay',
                              style: TextStyle(color: Colors.black54, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phonelink_ring_rounded, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Silakan proses gesek / tap kartu pada mesin EDC Cava, lalu klik Selesai.',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(),

            // Confirm Payment Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_selectedMethod == PaymentMethod.cash && !changeResult.isSufficient)
                          ? null
                          : () {
                              widget.onPayConfirmed(_selectedMethod, _cashReceived);
                              Navigator.of(context).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Selesaikan Pembayaran (${CurrencyFormatter.format(grandTotal)})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
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

  Widget _buildMethodButton(PaymentMethod method, IconData icon, String label) {
    final isSelected = _selectedMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = method),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
