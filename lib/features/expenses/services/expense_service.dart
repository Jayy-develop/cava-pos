import 'package:flutter/foundation.dart';
import '../domain/expense_item.dart';
import '../domain/expense_template.dart';

class ExpenseService extends ChangeNotifier {
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;

  ExpenseService._internal() {
    _initSampleData();
  }

  final List<ExpenseTemplate> _templates = List.from(ExpenseTemplate.defaultTemplates);
  final List<ExpenseItem> _expenses = [];

  List<ExpenseTemplate> get templates => List.unmodifiable(_templates);
  List<ExpenseItem> get expenses => List.unmodifiable(_expenses);

  void _initSampleData() {
    final now = DateTime.now();
    _expenses.addAll([
      ExpenseItem(
        id: 'exp-001',
        title: 'Beli Es Batu Kristal (Tube)',
        category: ExpenseCategory.bahanDapur,
        amount: 25000,
        date: DateTime(now.year, now.month, now.day, 9, 30),
        paymentSource: 'Kas Laci (Petty Cash)',
        notes: 'Beli 2 sak es kristal untuk bar minuman pagi',
        recordedBy: 'Arya (Kasir)',
        receiptRef: 'RCP-EXP-901',
      ),
      ExpenseItem(
        id: 'exp-002',
        title: 'Isi Ulang Air Mineral Galon Bar',
        category: ExpenseCategory.bahanDapur,
        amount: 22000,
        date: DateTime(now.year, now.month, now.day, 11, 15),
        paymentSource: 'Kas Laci (Petty Cash)',
        notes: 'Galon cadangan untuk seduh V60 & espresso bar',
        recordedBy: 'Arya (Kasir)',
        receiptRef: 'RCP-EXP-902',
      ),
      ExpenseItem(
        id: 'exp-003',
        title: 'Kertas Struk Thermal Roll (Pack)',
        category: ExpenseCategory.operasional,
        amount: 75000,
        date: DateTime(now.year, now.month, now.day, 13, 0),
        paymentSource: 'Kas Laci (Petty Cash)',
        notes: '10 roll kertas printer kasir 58mm',
        recordedBy: 'Arya (Kasir)',
        receiptRef: 'RCP-EXP-903',
      ),
      ExpenseItem(
        id: 'exp-004',
        title: 'Beli Token Listrik PLN Kafe',
        category: ExpenseCategory.utilitas,
        amount: 500000,
        date: DateTime(now.year, now.month, now.day - 2, 10, 0),
        paymentSource: 'Transfer Bank / Rekening',
        notes: 'Token PLN 3500VA operasional mesin espresso',
        recordedBy: 'Budi Santoso (Owner)',
        receiptRef: 'PLN-920188',
      ),
      ExpenseItem(
        id: 'exp-005',
        title: 'Servis / Maintenance Mesin Espresso',
        category: ExpenseCategory.maintenance,
        amount: 350000,
        date: DateTime(now.year, now.month, now.day - 4, 15, 30),
        paymentSource: 'Transfer Bank / Rekening',
        notes: 'Kalibrasi tekanan boiler & ganti gasket shower screen',
        recordedBy: 'Budi Santoso (Owner)',
        receiptRef: 'INV-TEK-441',
      ),
    ]);
  }

  // --- Expense CRUD ---

  void addExpense(ExpenseItem item) {
    _expenses.insert(0, item);
    notifyListeners();
  }

  void updateExpense(ExpenseItem item) {
    final index = _expenses.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _expenses[index] = item;
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // --- Template CRUD ---

  void addTemplate(ExpenseTemplate template) {
    _templates.add(template);
    notifyListeners();
  }

  void updateTemplate(ExpenseTemplate template) {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      _templates[index] = template;
      notifyListeners();
    }
  }

  void deleteTemplate(String id) {
    _templates.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // --- Calculations ---

  double get totalToday {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get pettyCashOutToday {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day &&
            e.isPettyCash)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
