import 'package:equatable/equatable.dart';
import '../../pos/domain/entities/order.dart';

enum OrderHistoryStatus { initial, loaded, updated, error }

class OrderHistoryState extends Equatable {
  final List<Order> allOrders;
  final List<Order> filteredOrders;
  final String searchQuery;
  final PaymentStatus? statusFilter;
  final PaymentMethod? methodFilter;
  final OrderHistoryStatus status;
  final String? errorMessage;
  final String? successMessage;

  const OrderHistoryState({
    this.allOrders = const [],
    this.filteredOrders = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.methodFilter,
    this.status = OrderHistoryStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  double get totalRevenue => allOrders
      .where((o) => o.paymentStatus == PaymentStatus.paid)
      .fold(0.0, (sum, o) => sum + o.grandTotal);

  int get paidCount =>
      allOrders.where((o) => o.paymentStatus == PaymentStatus.paid).length;

  int get voidCount =>
      allOrders.where((o) => o.paymentStatus == PaymentStatus.voided).length;

  OrderHistoryState copyWith({
    List<Order>? allOrders,
    List<Order>? filteredOrders,
    String? searchQuery,
    PaymentStatus? statusFilter,
    bool clearStatusFilter = false,
    PaymentMethod? methodFilter,
    bool clearMethodFilter = false,
    OrderHistoryStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return OrderHistoryState(
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      methodFilter: clearMethodFilter ? null : (methodFilter ?? this.methodFilter),
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        allOrders,
        filteredOrders,
        searchQuery,
        statusFilter,
        methodFilter,
        status,
        errorMessage,
        successMessage,
      ];
}
