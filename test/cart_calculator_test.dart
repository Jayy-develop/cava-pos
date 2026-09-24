import 'package:flutter_test/flutter_test.dart';
import 'package:cava_pos/features/pos/domain/entities/order_item.dart';
import 'package:cava_pos/features/pos/domain/entities/product.dart';
import 'package:cava_pos/features/pos/domain/services/cart_calculator.dart';

void main() {
  group('CartCalculator Tests', () {
    final item1 = OrderItem(
      id: '1',
      productId: 'p1',
      productName: 'Cava Latte',
      basePrice: 30000,
      selectedVariant: const ProductVariant(id: 'v1', name: 'Large', priceDelta: 5000),
      selectedModifiers: const [
        ProductModifierOption(id: 'm1', name: 'Oat Milk', additionalPrice: 7000),
      ],
      quantity: 2,
    );
    // Unit price = 30000 + 5000 + 7000 = 42000
    // Gross = 42000 * 2 = 84000

    final item2 = const OrderItem(
      id: '2',
      productId: 'p2',
      productName: 'Butter Croissant',
      basePrice: 25000,
      quantity: 1,
    );
    // Unit price = 25000 * 1 = 25000

    test('Standard PB1 (10%) and Service Charge (5%) calculation without discount', () {
      final result = CartCalculator.calculate(
        items: [item1, item2],
        discountPercentage: 0.0,
        serviceChargeRate: 0.05,
        taxRate: 0.10,
      );

      // Subtotal = 84000 + 25000 = 109000
      expect(result.subtotal, 109000);
      expect(result.orderDiscount, 0);
      expect(result.taxableSubtotal, 109000);

      // Service Charge = 5% of 109000 = 5450
      expect(result.serviceChargeAmount, 5450);

      // Tax Base = 109000 + 5450 = 114450
      // PB1 Tax = 10% of 114450 = 11445
      expect(result.taxAmount, 11445);

      // Grand Total = 114450 + 11445 = 125895
      expect(result.grandTotal, 125895);
    });

    test('Calculation with 10% cart discount', () {
      final result = CartCalculator.calculate(
        items: [item1, item2],
        discountPercentage: 0.10, // 10%
        serviceChargeRate: 0.05,
        taxRate: 0.10,
      );

      // Subtotal = 109000
      // Discount = 10900
      expect(result.subtotal, 109000);
      expect(result.orderDiscount, 10900);

      // Taxable Subtotal = 109000 - 10900 = 98100
      expect(result.taxableSubtotal, 98100);

      // Service Charge = 5% of 98100 = 4905
      expect(result.serviceChargeAmount, 4905);

      // Tax base = 98100 + 4905 = 103005
      // PB1 = 10% of 103005 = 10300.5
      expect(result.taxAmount, 10300.5);

      // Grand total = 103005 + 10300.5 = 113305.5
      expect(result.grandTotal, 113305.5);
    });

    test('Cash change calculation', () {
      final changeResult = CartCalculator.calculateChange(
        grandTotal: 125000,
        cashReceived: 150000,
      );

      expect(changeResult.isSufficient, true);
      expect(changeResult.change, 25000);

      final insufficient = CartCalculator.calculateChange(
        grandTotal: 125000,
        cashReceived: 100000,
      );
      expect(insufficient.isSufficient, false);
    });

    test('Split bill equal test', () {
      final splits = CartCalculator.splitEqual(grandTotal: 100000, numberOfSplits: 3);
      expect(splits.length, 3);
      // 100000 / 3 = 33333 with 1 remainder
      expect(splits[0], 33334);
      expect(splits[1], 33333);
      expect(splits[2], 33333);
      expect(splits[0] + splits[1] + splits[2], 100000);
    });
  });
}
