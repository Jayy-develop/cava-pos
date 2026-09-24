import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cava_pos/features/hardware/services/esc_pos_thermal_service.dart';
import 'package:cava_pos/features/hardware/services/printer_service.dart';
import 'package:cava_pos/features/pos/domain/entities/order.dart';
import 'package:cava_pos/features/pos/domain/entities/order_item.dart';
import 'package:cava_pos/features/pos/domain/entities/product.dart';

void main() {
  group('EscPosThermalService Tests', () {
    final service = EscPosThermalService();
    final testOrder = Order(
      id: 'ord-001',
      orderNumber: 'CAVA-2026-0001',
      tableNumber: 'T-04',
      orderType: OrderType.dineIn,
      customerName: 'Budi Santoso',
      items: [
        const OrderItem(
          id: 'item-1',
          productId: 'prod-1',
          productName: 'Iced Americano',
          basePrice: 28000,
          quantity: 2,
          selectedModifiers: [
            ProductModifierOption(id: 'm1', name: 'Less Sugar'),
          ],
          notes: 'Extra ice please',
        ),
      ],
      subtotal: 56000,
      serviceChargeRate: 0.05,
      serviceChargeAmount: 2800,
      taxRate: 0.10,
      taxAmount: 5880,
      grandTotal: 64680,
      paymentMethod: PaymentMethod.cash,
      cashReceived: 100000,
      cashChange: 35320,
      cashierId: 'c1',
      cashierName: 'Sarah Kasir',
      createdAt: DateTime(2026, 9, 11, 14, 30),
    );

    test('generateCustomerReceipt generates valid non-empty byte buffer with cafe title', () {
      final bytes = service.generateCustomerReceipt(order: testOrder, paperSize: PaperSize.mm58);
      expect(bytes.isNotEmpty, true);
      final decodedString = latin1.decode(bytes);
      expect(decodedString.contains('CAVA COFFEE'), true);
      expect(decodedString.contains('CAVA-2026-0001'), true);
      expect(decodedString.contains('Iced Americano'), true);
      expect(decodedString.contains('GRAND TOTAL'), true);
      expect(decodedString.contains('Cash Tendered'), true);
    });

    test('generateKitchenTicket generates ticket with large table header & notes', () {
      final bytes = service.generateKitchenTicket(order: testOrder, paperSize: PaperSize.mm58);
      expect(bytes.isNotEmpty, true);
      final decodedString = latin1.decode(bytes);
      expect(decodedString.contains('KITCHEN & BAR'), true);
      expect(decodedString.contains('MEJA: T-04'), true);
      expect(decodedString.contains('EXTRA ICE PLEASE'), true);
      // Kitchen ticket does NOT contain financial payment info
      expect(decodedString.contains('GRAND TOTAL'), false);
    });

    test('generateCashDrawerCommand emits standard ESC p pulse', () {
      final drawerBytes = service.generateCashDrawerCommand();
      expect(drawerBytes, [0x1B, 0x70, 0x00, 0x19, 0xFA]);
    });
  });
}
