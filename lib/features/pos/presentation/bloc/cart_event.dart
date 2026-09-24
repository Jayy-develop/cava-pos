import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddProductToCart extends CartEvent {
  final Product product;
  final ProductVariant? variant;
  final List<ProductModifierOption> selectedModifiers;
  final String notes;
  final int quantity;

  const AddProductToCart({
    required this.product,
    this.variant,
    this.selectedModifiers = const [],
    this.notes = '',
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [product, variant, selectedModifiers, notes, quantity];
}

class UpdateItemQuantity extends CartEvent {
  final String itemId;
  final int newQuantity;

  const UpdateItemQuantity({
    required this.itemId,
    required this.newQuantity,
  });

  @override
  List<Object?> get props => [itemId, newQuantity];
}

class RemoveCartItem extends CartEvent {
  final String itemId;

  const RemoveCartItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ApplyDiscountEvent extends CartEvent {
  final double? percentage;
  final double? fixedAmount;

  const ApplyDiscountEvent({this.percentage, this.fixedAmount});

  @override
  List<Object?> get props => [percentage, fixedAmount];
}

class ChangeOrderType extends CartEvent {
  final OrderType orderType;

  const ChangeOrderType(this.orderType);

  @override
  List<Object?> get props => [orderType];
}

class SelectTableEvent extends CartEvent {
  final String? tableNumber;

  const SelectTableEvent(this.tableNumber);

  @override
  List<Object?> get props => [tableNumber];
}

class UpdateCustomerNameEvent extends CartEvent {
  final String customerName;

  const UpdateCustomerNameEvent(this.customerName);

  @override
  List<Object?> get props => [customerName];
}

class CheckoutCartEvent extends CartEvent {
  final PaymentMethod paymentMethod;
  final double cashReceived;
  final String cashierId;
  final String cashierName;

  const CheckoutCartEvent({
    required this.paymentMethod,
    required this.cashReceived,
    required this.cashierId,
    required this.cashierName,
  });

  @override
  List<Object?> get props => [paymentMethod, cashReceived, cashierId, cashierName];
}

class ClearCartEvent extends CartEvent {}
