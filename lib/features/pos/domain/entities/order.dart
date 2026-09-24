import 'package:equatable/equatable.dart';
import 'order_item.dart';

enum OrderType { dineIn, takeAway, delivery }

enum PaymentStatus { unpaid, paid, voided, refunded }

enum PaymentMethod { cash, qris, debitCard, creditCard, eWallet }

enum SyncStatus { pending, synced, failed }

class Order extends Equatable {
  final String id;
  final String orderNumber;
  final String? tableNumber;
  final String customerName;
  final OrderType orderType;
  final List<OrderItem> items;
  final double subtotal;
  final double orderDiscount; // Discount applied at cart level (e.g., voucher/manual)
  final double serviceChargeRate; // e.g., 0.05 = 5%
  final double serviceChargeAmount;
  final double taxRate; // PB1 = 0.10 (10%)
  final double taxAmount;
  final double roundingAmount;
  final double grandTotal;
  final PaymentStatus paymentStatus;
  final PaymentMethod? paymentMethod;
  final double cashReceived;
  final double cashChange;
  final String cashierId;
  final String cashierName;
  final DateTime createdAt;
  final DateTime? paidAt;
  final SyncStatus syncStatus;
  final String? splitBillParentId;

  const Order({
    required this.id,
    required this.orderNumber,
    this.tableNumber,
    this.customerName = 'Guest',
    this.orderType = OrderType.dineIn,
    this.items = const [],
    this.subtotal = 0.0,
    this.orderDiscount = 0.0,
    this.serviceChargeRate = 0.05,
    this.serviceChargeAmount = 0.0,
    this.taxRate = 0.10, // PB1 default 10%
    this.taxAmount = 0.0,
    this.roundingAmount = 0.0,
    this.grandTotal = 0.0,
    this.paymentStatus = PaymentStatus.unpaid,
    this.paymentMethod,
    this.cashReceived = 0.0,
    this.cashChange = 0.0,
    required this.cashierId,
    required this.cashierName,
    required this.createdAt,
    this.paidAt,
    this.syncStatus = SyncStatus.pending,
    this.splitBillParentId,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({
    String? id,
    String? orderNumber,
    String? tableNumber,
    String? customerName,
    OrderType? orderType,
    List<OrderItem>? items,
    double? subtotal,
    double? orderDiscount,
    double? serviceChargeRate,
    double? serviceChargeAmount,
    double? taxRate,
    double? taxAmount,
    double? roundingAmount,
    double? grandTotal,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    double? cashReceived,
    double? cashChange,
    String? cashierId,
    String? cashierName,
    DateTime? createdAt,
    DateTime? paidAt,
    SyncStatus? syncStatus,
    String? splitBillParentId,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      tableNumber: tableNumber ?? this.tableNumber,
      customerName: customerName ?? this.customerName,
      orderType: orderType ?? this.orderType,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      orderDiscount: orderDiscount ?? this.orderDiscount,
      serviceChargeRate: serviceChargeRate ?? this.serviceChargeRate,
      serviceChargeAmount: serviceChargeAmount ?? this.serviceChargeAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      roundingAmount: roundingAmount ?? this.roundingAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashReceived: cashReceived ?? this.cashReceived,
      cashChange: cashChange ?? this.cashChange,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      syncStatus: syncStatus ?? this.syncStatus,
      splitBillParentId: splitBillParentId ?? this.splitBillParentId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNumber': orderNumber,
    'tableNumber': tableNumber,
    'customerName': customerName,
    'orderType': orderType.name,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'orderDiscount': orderDiscount,
    'serviceChargeRate': serviceChargeRate,
    'serviceChargeAmount': serviceChargeAmount,
    'taxRate': taxRate,
    'taxAmount': taxAmount,
    'roundingAmount': roundingAmount,
    'grandTotal': grandTotal,
    'paymentStatus': paymentStatus.name,
    'paymentMethod': paymentMethod?.name,
    'cashReceived': cashReceived,
    'cashChange': cashChange,
    'cashierId': cashierId,
    'cashierName': cashierName,
    'createdAt': createdAt.toIso8601String(),
    'paidAt': paidAt?.toIso8601String(),
    'syncStatus': syncStatus.name,
    'splitBillParentId': splitBillParentId,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    orderNumber: json['orderNumber'] as String,
    tableNumber: json['tableNumber'] as String?,
    customerName: json['customerName'] as String? ?? 'Guest',
    orderType: OrderType.values.firstWhere(
      (e) => e.name == json['orderType'],
      orElse: () => OrderType.dineIn,
    ),
    items: (json['items'] as List<dynamic>?)
            ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    orderDiscount: (json['orderDiscount'] as num?)?.toDouble() ?? 0.0,
    serviceChargeRate: (json['serviceChargeRate'] as num?)?.toDouble() ?? 0.05,
    serviceChargeAmount: (json['serviceChargeAmount'] as num?)?.toDouble() ?? 0.0,
    taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.10,
    taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
    roundingAmount: (json['roundingAmount'] as num?)?.toDouble() ?? 0.0,
    grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
    paymentStatus: PaymentStatus.values.firstWhere(
      (e) => e.name == json['paymentStatus'],
      orElse: () => PaymentStatus.unpaid,
    ),
    paymentMethod: json['paymentMethod'] != null
        ? PaymentMethod.values.firstWhere(
            (e) => e.name == json['paymentMethod'],
            orElse: () => PaymentMethod.cash,
          )
        : null,
    cashReceived: (json['cashReceived'] as num?)?.toDouble() ?? 0.0,
    cashChange: (json['cashChange'] as num?)?.toDouble() ?? 0.0,
    cashierId: json['cashierId'] as String,
    cashierName: json['cashierName'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
    syncStatus: SyncStatus.values.firstWhere(
      (e) => e.name == json['syncStatus'],
      orElse: () => SyncStatus.pending,
    ),
    splitBillParentId: json['splitBillParentId'] as String?,
  );

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        tableNumber,
        customerName,
        orderType,
        items,
        subtotal,
        orderDiscount,
        serviceChargeRate,
        serviceChargeAmount,
        taxRate,
        taxAmount,
        roundingAmount,
        grandTotal,
        paymentStatus,
        paymentMethod,
        cashReceived,
        cashChange,
        cashierId,
        cashierName,
        createdAt,
        paidAt,
        syncStatus,
        splitBillParentId,
      ];
}
