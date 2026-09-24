import 'package:equatable/equatable.dart';

enum ShiftStatus { open, closed }

class CashierShift extends Equatable {
  final String id;
  final String cashierId;
  final String cashierName;
  final DateTime startTime;
  final DateTime? endTime;
  final double startingCash;
  final double expectedCash; // startingCash + totalCashSales - cashPaidOut
  final double? actualCash; // Cash counted at closing
  final double? cashDifference; // actualCash - expectedCash
  final double totalCashSales;
  final double totalNonCashSales; // QRIS, Debit, Credit, E-Wallet
  final int totalTransactions;
  final ShiftStatus status;
  final String? notes;

  const CashierShift({
    required this.id,
    required this.cashierId,
    required this.cashierName,
    required this.startTime,
    this.endTime,
    required this.startingCash,
    this.expectedCash = 0,
    this.actualCash,
    this.cashDifference,
    this.totalCashSales = 0,
    this.totalNonCashSales = 0,
    this.totalTransactions = 0,
    this.status = ShiftStatus.open,
    this.notes,
  });

  double get totalGrossSales => totalCashSales + totalNonCashSales;

  CashierShift copyWith({
    String? id,
    String? cashierId,
    String? cashierName,
    DateTime? startTime,
    DateTime? endTime,
    double? startingCash,
    double? expectedCash,
    double? actualCash,
    double? cashDifference,
    double? totalCashSales,
    double? totalNonCashSales,
    int? totalTransactions,
    ShiftStatus? status,
    String? notes,
  }) {
    return CashierShift(
      id: id ?? this.id,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startingCash: startingCash ?? this.startingCash,
      expectedCash: expectedCash ?? this.expectedCash,
      actualCash: actualCash ?? this.actualCash,
      cashDifference: cashDifference ?? this.cashDifference,
      totalCashSales: totalCashSales ?? this.totalCashSales,
      totalNonCashSales: totalNonCashSales ?? this.totalNonCashSales,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'startingCash': startingCash,
      'expectedCash': expectedCash,
      'actualCash': actualCash,
      'cashDifference': cashDifference,
      'totalCashSales': totalCashSales,
      'totalNonCashSales': totalNonCashSales,
      'totalTransactions': totalTransactions,
      'status': status.name,
      'notes': notes,
    };
  }

  factory CashierShift.fromJson(Map<String, dynamic> json) {
    return CashierShift(
      id: json['id'] as String,
      cashierId: json['cashierId'] as String,
      cashierName: json['cashierName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      startingCash: (json['startingCash'] as num).toDouble(),
      expectedCash: (json['expectedCash'] as num).toDouble(),
      actualCash: json['actualCash'] != null ? (json['actualCash'] as num).toDouble() : null,
      cashDifference: json['cashDifference'] != null ? (json['cashDifference'] as num).toDouble() : null,
      totalCashSales: (json['totalCashSales'] as num).toDouble(),
      totalNonCashSales: (json['totalNonCashSales'] as num).toDouble(),
      totalTransactions: json['totalTransactions'] as int,
      status: ShiftStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ShiftStatus.open,
      ),
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cashierId,
        cashierName,
        startTime,
        endTime,
        startingCash,
        expectedCash,
        actualCash,
        cashDifference,
        totalCashSales,
        totalNonCashSales,
        totalTransactions,
        status,
        notes,
      ];
}
