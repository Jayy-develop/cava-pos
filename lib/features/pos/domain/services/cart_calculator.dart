import '../entities/order_item.dart';

class CartCalculationResult {
  final double subtotal; // Gross sum of all items after item-level discounts
  final double orderDiscount; // Applied cart-level discount
  final double taxableSubtotal; // subtotal - orderDiscount
  final double serviceChargeRate;
  final double serviceChargeAmount; // taxableSubtotal * serviceChargeRate
  final double taxRate;
  final double taxAmount; // (taxableSubtotal + serviceChargeAmount) * taxRate (Standard PB1)
  final double roundingAmount; // Rounding adjustment for cash transactions
  final double grandTotal; // taxableSubtotal + serviceChargeAmount + taxAmount + roundingAmount

  const CartCalculationResult({
    required this.subtotal,
    required this.orderDiscount,
    required this.taxableSubtotal,
    required this.serviceChargeRate,
    required this.serviceChargeAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.roundingAmount,
    required this.grandTotal,
  });
}

class CartCalculator {
  CartCalculator._();

  /// Calculates complete financial totals for a list of items and discount rules.
  /// Standard Indonesian F&B tax law (PB1 10% on Subtotal + Service Charge).
  static CartCalculationResult calculate({
    required List<OrderItem> items,
    double discountPercentage = 0.0, // 0.0 - 1.0 (e.g., 0.10 for 10%)
    double fixedDiscountAmount = 0.0, // e.g., Rp 20.000 voucher
    double serviceChargeRate = 0.05, // 5% for Dine-In, 0% for Takeaway
    double taxRate = 0.10, // 10% PB1
    bool applyCashRounding = false, // Rounding to nearest 100
  }) {
    // 1. Calculate Gross Subtotal (Sum of item netTotals: unitPrice * qty - itemDiscount)
    double calculatedSubtotal = 0.0;
    for (final item in items) {
      calculatedSubtotal += item.netTotal;
    }

    // 2. Calculate Cart-level Discount
    double calculatedOrderDiscount = 0.0;
    if (discountPercentage > 0) {
      calculatedOrderDiscount += calculatedSubtotal * discountPercentage;
    }
    calculatedOrderDiscount += fixedDiscountAmount;
    // Discount cannot exceed subtotal
    if (calculatedOrderDiscount > calculatedSubtotal) {
      calculatedOrderDiscount = calculatedSubtotal;
    }

    // 3. Taxable Subtotal (DPP dasar sebelum service charge)
    final double taxableSubtotal = calculatedSubtotal - calculatedOrderDiscount;

    // 4. Service Charge (default 5% on discounted food/beverage amount)
    final double serviceChargeAmount = taxableSubtotal * serviceChargeRate;

    // 5. Pajak Restoran / PB1 (10% on taxable base = taxableSubtotal + serviceCharge)
    final double taxBase = taxableSubtotal + serviceChargeAmount;
    final double taxAmount = taxBase * taxRate;

    // 6. Pre-rounding Grand Total
    final double preRoundingTotal = taxBase + taxAmount;

    // 7. Rounding Adjustment (Optional for cash payment, rounds to nearest Rp 100)
    double rounding = 0.0;
    double finalGrandTotal = preRoundingTotal;

    if (applyCashRounding) {
      final double rounded = (preRoundingTotal / 100).round() * 100.0;
      rounding = rounded - preRoundingTotal;
      finalGrandTotal = rounded;
    }

    return CartCalculationResult(
      subtotal: calculatedSubtotal,
      orderDiscount: calculatedOrderDiscount,
      taxableSubtotal: taxableSubtotal,
      serviceChargeRate: serviceChargeRate,
      serviceChargeAmount: serviceChargeAmount,
      taxRate: taxRate,
      taxAmount: taxAmount,
      roundingAmount: rounding,
      grandTotal: finalGrandTotal,
    );
  }

  /// Calculates cash change and validates if payment is sufficient
  static ({bool isSufficient, double change}) calculateChange({
    required double grandTotal,
    required double cashReceived,
  }) {
    if (cashReceived < grandTotal) {
      return (isSufficient: false, change: 0.0);
    }
    return (isSufficient: true, change: cashReceived - grandTotal);
  }

  /// Splits an order equally among N persons.
  /// Balances any rounding remainder to the first person's bill to guarantee sum equality.
  static List<double> splitEqual({
    required double grandTotal,
    required int numberOfSplits,
  }) {
    if (numberOfSplits <= 1) return [grandTotal];

    final double baseShare = (grandTotal / numberOfSplits).floorToDouble();
    final double remainder = grandTotal - (baseShare * numberOfSplits);

    final List<double> splits = List.filled(numberOfSplits, baseShare);
    splits[0] += remainder; // Add odd remainder to first payer
    return splits;
  }
}
