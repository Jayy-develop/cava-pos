import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  bahanDapur,
  utilitas,
  operasional,
  gajiUpah,
  maintenance,
  marketing,
  sewaIuran,
  lainnya,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.bahanDapur:
        return 'Bahan Baku & Dapur';
      case ExpenseCategory.utilitas:
        return 'Utilitas (Listrik, Air, Gas)';
      case ExpenseCategory.operasional:
        return 'Operasional & Perlengkapan';
      case ExpenseCategory.gajiUpah:
        return 'Gaji, Uang Makan, & Lembur';
      case ExpenseCategory.maintenance:
        return 'Servis & Perawatan Mesin';
      case ExpenseCategory.marketing:
        return 'Pemasaran & Promosi';
      case ExpenseCategory.sewaIuran:
        return 'Sewa, Keamanan, & Iuran';
      case ExpenseCategory.lainnya:
        return 'Pengeluaran Lainnya';
    }
  }
}

class ExpenseItem extends Equatable {
  final String id;
  final String title;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String paymentSource; // 'Kas Laci (Petty Cash)' or 'Transfer Bank / Rekening'
  final String notes;
  final String recordedBy;
  final String receiptRef;

  const ExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.paymentSource = 'Kas Laci (Petty Cash)',
    this.notes = '',
    this.recordedBy = 'Arya (Kasir)',
    this.receiptRef = '',
  });

  bool get isPettyCash => paymentSource.contains('Laci') || paymentSource.contains('Cash');

  ExpenseItem copyWith({
    String? id,
    String? title,
    ExpenseCategory? category,
    double? amount,
    DateTime? date,
    String? paymentSource,
    String? notes,
    String? recordedBy,
    String? receiptRef,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentSource: paymentSource ?? this.paymentSource,
      notes: notes ?? this.notes,
      recordedBy: recordedBy ?? this.recordedBy,
      receiptRef: receiptRef ?? this.receiptRef,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'amount': amount,
    'date': date.toIso8601String(),
    'paymentSource': paymentSource,
    'notes': notes,
    'recordedBy': recordedBy,
    'receiptRef': receiptRef,
  };

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
    id: json['id'] as String,
    title: json['title'] as String,
    category: ExpenseCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => ExpenseCategory.lainnya,
    ),
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    paymentSource: json['paymentSource'] as String? ?? 'Kas Laci (Petty Cash)',
    notes: json['notes'] as String? ?? '',
    recordedBy: json['recordedBy'] as String? ?? 'Arya (Kasir)',
    receiptRef: json['receiptRef'] as String? ?? '',
  );

  @override
  List<Object?> get props => [id, title, category, amount, date, paymentSource, notes, recordedBy, receiptRef];
}
