import 'package:equatable/equatable.dart';
import '../../pos/domain/entities/order.dart';

abstract class OrderHistoryEvent extends Equatable {
  const OrderHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderHistory extends OrderHistoryEvent {}

class AddCompletedOrder extends OrderHistoryEvent {
  final Order order;

  const AddCompletedOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class VoidOrderEvent extends OrderHistoryEvent {
  final String orderId;
  final String reason;
  final String supervisorPin;

  const VoidOrderEvent({
    required this.orderId,
    required this.reason,
    required this.supervisorPin,
  });

  @override
  List<Object?> get props => [orderId, reason, supervisorPin];
}

class FilterOrdersEvent extends OrderHistoryEvent {
  final String searchQuery;
  final PaymentStatus? statusFilter;
  final PaymentMethod? methodFilter;

  const FilterOrdersEvent({
    this.searchQuery = '',
    this.statusFilter,
    this.methodFilter,
  });

  @override
  List<Object?> get props => [searchQuery, statusFilter, methodFilter];
}
