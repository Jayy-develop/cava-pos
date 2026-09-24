import 'package:flutter_test/flutter_test.dart';
import 'package:cava_pos/features/inventory/domain/ingredient.dart';
import 'package:cava_pos/features/expenses/domain/expense_item.dart';
import 'package:cava_pos/features/expenses/domain/expense_template.dart';
import 'package:cava_pos/features/expenses/services/expense_service.dart';

void main() {
  group('Inventory & Edit Stock Tests', () {
    test('InventoryIngredient correctly detects low stock', () {
      const normalStock = InventoryIngredient(
        id: 'ing_1',
        sku: 'RAW-01',
        name: 'House Blend Arabica',
        unit: IngredientUnit.gram,
        currentStock: 4200,
        minStockAlert: 1500,
        costPerUnit: 250,
      );
      expect(normalStock.isLowStock, isFalse);

      final lowStock = normalStock.copyWith(currentStock: 1200);
      expect(lowStock.isLowStock, isTrue);
    });

    test('InventoryIngredient copyWith updates stock, unit cost, and min alert accurately', () {
      const original = InventoryIngredient(
        id: 'ing_milk',
        sku: 'RAW-MLK-01',
        name: 'Fresh Milk',
        unit: IngredientUnit.ml,
        currentStock: 5000,
        minStockAlert: 2000,
        costPerUnit: 28,
      );

      final updated = original.copyWith(
        name: 'Greenfields Fresh Milk (Updated)',
        currentStock: 7500,
        costPerUnit: 30,
        minStockAlert: 2500,
      );

      expect(updated.name, equals('Greenfields Fresh Milk (Updated)'));
      expect(updated.currentStock, equals(7500));
      expect(updated.costPerUnit, equals(30));
      expect(updated.minStockAlert, equals(2500));
      expect(updated.id, equals(original.id));
    });
  });

  group('Expense & Template Tests', () {
    test('Default templates contain cafe operational expenses', () {
      expect(ExpenseTemplate.defaultTemplates, isNotEmpty);
      expect(ExpenseTemplate.defaultTemplates.length, greaterThanOrEqualTo(10));

      final iceTpl = ExpenseTemplate.defaultTemplates.firstWhere((t) => t.id == 'tpl_ice');
      expect(iceTpl.title, contains('Es Batu'));
      expect(iceTpl.category, equals(ExpenseCategory.bahanDapur));
      expect(iceTpl.defaultAmount, equals(25000));
    });

    test('Template can be converted to ExpenseItem and customized', () {
      final tpl = ExpenseTemplate.defaultTemplates.firstWhere((t) => t.id == 'tpl_token_pln');
      final item = tpl.toExpenseItem(
        customAmount: 750000,
        customNotes: 'Token PLN darurat pasca live music',
        recordedBy: 'Budi Santoso',
      );

      expect(item.title, equals(tpl.title));
      expect(item.category, equals(tpl.category));
      expect(item.amount, equals(750000));
      expect(item.notes, equals('Token PLN darurat pasca live music'));
      expect(item.recordedBy, equals('Budi Santoso'));
      expect(item.isPettyCash, isFalse); // Transfer Bank
    });

    test('ExpenseService adds, updates, deletes expenses and tracks totals', () {
      final service = ExpenseService();
      final initialCount = service.expenses.length;

      final testExpense = ExpenseItem(
        id: 'exp-test-999',
        title: 'Beli Kanebo & Spons Cuci Piring',
        category: ExpenseCategory.operasional,
        amount: 35000,
        date: DateTime.now(),
        paymentSource: 'Kas Laci (Petty Cash)',
        notes: 'Perlengkapan bar',
      );

      // Add
      service.addExpense(testExpense);
      expect(service.expenses.length, equals(initialCount + 1));
      expect(service.expenses.first.id, equals('exp-test-999'));
      expect(service.pettyCashOutToday, greaterThanOrEqualTo(35000));

      // Update
      final modified = testExpense.copyWith(amount: 45000, title: 'Beli Kanebo Jumbo');
      service.updateExpense(modified);
      final found = service.expenses.firstWhere((e) => e.id == 'exp-test-999');
      expect(found.amount, equals(45000));
      expect(found.title, equals('Beli Kanebo Jumbo'));

      // Delete
      service.deleteExpense('exp-test-999');
      expect(service.expenses.any((e) => e.id == 'exp-test-999'), isFalse);
    });

    test('ExpenseService manages custom templates', () {
      final service = ExpenseService();
      final initialTplCount = service.templates.length;

      const newTpl = ExpenseTemplate(
        id: 'tpl-custom-new',
        title: 'Beli Kantong Plastik Takeaway Motif Cava',
        category: ExpenseCategory.operasional,
        defaultAmount: 90000,
        defaultPaymentSource: 'Kas Laci (Petty Cash)',
      );

      service.addTemplate(newTpl);
      expect(service.templates.length, equals(initialTplCount + 1));

      // Update template
      final updatedTpl = newTpl.copyWith(defaultAmount: 110000);
      service.updateTemplate(updatedTpl);
      final foundTpl = service.templates.firstWhere((t) => t.id == 'tpl-custom-new');
      expect(foundTpl.defaultAmount, equals(110000));

      // Delete template
      service.deleteTemplate('tpl-custom-new');
      expect(service.templates.any((t) => t.id == 'tpl-custom-new'), isFalse);
    });
  });
}
