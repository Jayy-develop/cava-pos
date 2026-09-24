import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/services/cart_calculator.dart';

enum CartStatus { initial, updated, checkingOut, success, error }

class CartState extends Equatable {
  final List<OrderItem> items;
  final OrderType orderType;
  final String? selectedTable;
  final String customerName;
  final double discountPercentage;
  final double fixedDiscountAmount;
  final CartCalculationResult calculation;
  final CartStatus status;
  final Order? lastCompletedOrder;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.orderType = OrderType.dineIn,
    this.selectedTable,
    this.customerName = 'Guest',
    this.discountPercentage = 0.0,
    this.fixedDiscountAmount = 0.0,
    required this.calculation,
    this.status = CartStatus.initial,
    this.lastCompletedOrder,
    this.errorMessage,
  });

  factory CartState.initial() {
    return CartState(
      calculation: CartCalculator.calculate(
        items: const [],
        serviceChargeRate: 0.05,
        taxRate: 0.10,
      ),
    );
  }

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<OrderItem>? items,
    OrderType? orderType,
    String? selectedTable,
    String? customerName,
    double? discountPercentage,
    double? fixedDiscountAmount,
    CartCalculationResult? calculation,
    CartStatus? status,
    Order? lastCompletedOrder,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      selectedTable: selectedTable ?? this.selectedTable,
      customerName: customerName ?? this.customerName,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      fixedDiscountAmount: fixedDiscountAmount ?? this.fixedDiscountAmount,
      calculation: calculation ?? this.calculation,
      status: status ?? this.status,
      lastCompletedOrder: lastCompletedOrder ?? this.lastCompletedOrder,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        items,
        orderType,
        selectedTable,
        customerName,
        discountPercentage,
        fixedDiscountAmount,
        calculation.grandTotal,
        status,
        lastCompletedOrder,
        errorMessage,
      ];
}
