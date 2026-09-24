import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/services/cart_calculator.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  static const _uuid = Uuid();

  CartBloc() : super(CartState.initial()) {
    on<AddProductToCart>(_onAddProduct);
    on<UpdateItemQuantity>(_onUpdateQuantity);
    on<RemoveCartItem>(_onRemoveItem);
    on<ApplyDiscountEvent>(_onApplyDiscount);
    on<ChangeOrderType>(_onChangeOrderType);
    on<SelectTableEvent>(_onSelectTable);
    on<UpdateCustomerNameEvent>(_onUpdateCustomerName);
    on<CheckoutCartEvent>(_onCheckout);
    on<ClearCartEvent>(_onClearCart);
  }

  void _onAddProduct(AddProductToCart event, Emitter<CartState> emit) {
    final List<OrderItem> currentItems = List.from(state.items);

    // Check if an identical item (same product, variant, modifiers, notes) already exists
    final int existingIndex = currentItems.indexWhere((item) {
      if (item.productId != event.product.id) return false;
      if (item.selectedVariant?.id != event.variant?.id) return false;
      if (item.notes.trim().toLowerCase() != event.notes.trim().toLowerCase()) return false;

      final existingModIds = item.selectedModifiers.map((e) => e.id).toSet();
      final newModIds = event.selectedModifiers.map((e) => e.id).toSet();
      return existingModIds.length == newModIds.length &&
          existingModIds.containsAll(newModIds);
    });

    if (existingIndex != -1) {
      final existingItem = currentItems[existingIndex];
      currentItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + event.quantity,
      );
    } else {
      final newItem = OrderItem(
        id: _uuid.v4(),
        productId: event.product.id,
        productName: event.product.name,
        basePrice: event.product.basePrice,
        selectedVariant: event.variant,
        selectedModifiers: event.selectedModifiers,
        quantity: event.quantity,
        notes: event.notes,
      );
      currentItems.add(newItem);
    }

    final newCalc = _recalculate(items: currentItems);
    emit(state.copyWith(
      items: currentItems,
      calculation: newCalc,
      status: CartStatus.updated,
    ));
  }

  void _onUpdateQuantity(UpdateItemQuantity event, Emitter<CartState> emit) {
    final List<OrderItem> currentItems = List.from(state.items);
    final int index = currentItems.indexWhere((i) => i.id == event.itemId);
    if (index == -1) return;

    if (event.newQuantity <= 0) {
      currentItems.removeAt(index);
    } else {
      currentItems[index] = currentItems[index].copyWith(quantity: event.newQuantity);
    }

    final newCalc = _recalculate(items: currentItems);
    emit(state.copyWith(
      items: currentItems,
      calculation: newCalc,
      status: CartStatus.updated,
    ));
  }

  void _onRemoveItem(RemoveCartItem event, Emitter<CartState> emit) {
    final List<OrderItem> currentItems = List.from(state.items)
      ..removeWhere((i) => i.id == event.itemId);

    final newCalc = _recalculate(items: currentItems);
    emit(state.copyWith(
      items: currentItems,
      calculation: newCalc,
      status: CartStatus.updated,
    ));
  }

  void _onApplyDiscount(ApplyDiscountEvent event, Emitter<CartState> emit) {
    final double newPct = event.percentage ?? state.discountPercentage;
    final double newFixed = event.fixedAmount ?? state.fixedDiscountAmount;

    final newCalc = _recalculate(
      discountPercentage: newPct,
      fixedDiscountAmount: newFixed,
    );

    emit(state.copyWith(
      discountPercentage: newPct,
      fixedDiscountAmount: newFixed,
      calculation: newCalc,
      status: CartStatus.updated,
    ));
  }

  void _onChangeOrderType(ChangeOrderType event, Emitter<CartState> emit) {
    final newCalc = _recalculate(orderType: event.orderType);
    emit(state.copyWith(
      orderType: event.orderType,
      calculation: newCalc,
      status: CartStatus.updated,
    ));
  }

  void _onSelectTable(SelectTableEvent event, Emitter<CartState> emit) {
    emit(state.copyWith(selectedTable: event.tableNumber));
  }

  void _onUpdateCustomerName(UpdateCustomerNameEvent event, Emitter<CartState> emit) {
    emit(state.copyWith(customerName: event.customerName));
  }

  void _onCheckout(CheckoutCartEvent event, Emitter<CartState> emit) {
    if (state.items.isEmpty) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Keranjang belanja masih kosong',
      ));
      return;
    }

    final calc = state.calculation;
    double cashReceived = event.cashReceived;
    double cashChange = 0.0;

    if (event.paymentMethod == PaymentMethod.cash) {
      if (cashReceived < calc.grandTotal) {
        emit(state.copyWith(
          status: CartStatus.error,
          errorMessage: 'Uang tunai yang diterima kurang dari total tagihan',
        ));
        return;
      }
      cashChange = cashReceived - calc.grandTotal;
    } else {
      cashReceived = calc.grandTotal;
      cashChange = 0.0;
    }

    final now = DateTime.now();
    final orderNum = 'CAVA-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    final completedOrder = Order(
      id: _uuid.v4(),
      orderNumber: orderNum,
      tableNumber: state.orderType == OrderType.dineIn ? (state.selectedTable ?? 'T-01') : null,
      customerName: state.customerName,
      orderType: state.orderType,
      items: state.items,
      subtotal: calc.subtotal,
      orderDiscount: calc.orderDiscount,
      serviceChargeRate: calc.serviceChargeRate,
      serviceChargeAmount: calc.serviceChargeAmount,
      taxRate: calc.taxRate,
      taxAmount: calc.taxAmount,
      roundingAmount: calc.roundingAmount,
      grandTotal: calc.grandTotal,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: event.paymentMethod,
      cashReceived: cashReceived,
      cashChange: cashChange,
      cashierId: event.cashierId,
      cashierName: event.cashierName,
      createdAt: now,
      paidAt: now,
      syncStatus: SyncStatus.pending,
    );

    emit(state.copyWith(
      status: CartStatus.success,
      lastCompletedOrder: completedOrder,
    ));
  }

  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit(CartState.initial());
  }

  CartCalculationResult _recalculate({
    List<OrderItem>? items,
    OrderType? orderType,
    double? discountPercentage,
    double? fixedDiscountAmount,
  }) {
    final activeItems = items ?? state.items;
    final activeOrderType = orderType ?? state.orderType;
    final activeDiscPct = discountPercentage ?? state.discountPercentage;
    final activeFixed = fixedDiscountAmount ?? state.fixedDiscountAmount;

    // Dine-in incurs 5% service charge; Takeaway is 0%
    final double scRate = activeOrderType == OrderType.dineIn ? 0.05 : 0.0;

    return CartCalculator.calculate(
      items: activeItems,
      discountPercentage: activeDiscPct,
      fixedDiscountAmount: activeFixed,
      serviceChargeRate: scRate,
      taxRate: 0.10, // 10% PB1
      applyCashRounding: true,
    );
  }
}
