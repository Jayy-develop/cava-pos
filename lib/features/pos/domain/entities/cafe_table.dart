import 'package:equatable/equatable.dart';

enum TableStatus { vacant, occupied, reserved, billing }

class CafeTable extends Equatable {
  final String id;
  final String tableNumber; // e.g. "T-01", "VIP-1"
  final int capacity;
  final String section; // "Indoor", "Outdoor Terrace", "Bar", "Mezzanine"
  final TableStatus status;
  final String? activeOrderId;
  final double activeOrderAmount;
  final int occupiedMinutes;

  const CafeTable({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.section,
    this.status = TableStatus.vacant,
    this.activeOrderId,
    this.activeOrderAmount = 0.0,
    this.occupiedMinutes = 0,
  });

  CafeTable copyWith({
    String? id,
    String? tableNumber,
    int? capacity,
    String? section,
    TableStatus? status,
    String? activeOrderId,
    double? activeOrderAmount,
    int? occupiedMinutes,
  }) {
    return CafeTable(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      section: section ?? this.section,
      status: status ?? this.status,
      activeOrderId: activeOrderId ?? this.activeOrderId,
      activeOrderAmount: activeOrderAmount ?? this.activeOrderAmount,
      occupiedMinutes: occupiedMinutes ?? this.occupiedMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tableNumber': tableNumber,
    'capacity': capacity,
    'section': section,
    'status': status.name,
    'activeOrderId': activeOrderId,
    'activeOrderAmount': activeOrderAmount,
    'occupiedMinutes': occupiedMinutes,
  };

  factory CafeTable.fromJson(Map<String, dynamic> json) => CafeTable(
    id: json['id'] as String,
    tableNumber: json['tableNumber'] as String,
    capacity: json['capacity'] as int,
    section: json['section'] as String,
    status: TableStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => TableStatus.vacant,
    ),
    activeOrderId: json['activeOrderId'] as String?,
    activeOrderAmount: (json['activeOrderAmount'] as num?)?.toDouble() ?? 0.0,
    occupiedMinutes: json['occupiedMinutes'] as int? ?? 0,
  );

  @override
  List<Object?> get props => [
        id,
        tableNumber,
        capacity,
        section,
        status,
        activeOrderId,
        activeOrderAmount,
        occupiedMinutes,
      ];
}
