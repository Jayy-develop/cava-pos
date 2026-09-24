import 'package:flutter_bloc/flutter_bloc.dart';
import '../../pos/domain/entities/order.dart';
import '../../pos/domain/entities/order_item.dart';
import '../../pos/domain/entities/product.dart';
import 'order_history_event.dart';
import 'order_history_state.dart';

class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  OrderHistoryBloc() : super(const OrderHistoryState()) {
    on<LoadOrderHistory>(_onLoadHistory);
    on<AddCompletedOrder>(_onAddCompletedOrder);
    on<VoidOrderEvent>(_onVoidOrder);
    on<FilterOrdersEvent>(_onFilterOrders);

    add(LoadOrderHistory());
  }

  void _onLoadHistory(LoadOrderHistory event, Emitter<OrderHistoryState> emit) {
    final initialOrders = _getSampleHistoricalOrders();
    emit(state.copyWith(
      allOrders: initialOrders,
      filteredOrders: initialOrders,
      status: OrderHistoryStatus.loaded,
    ));
  }

  void _onAddCompletedOrder(AddCompletedOrder event, Emitter<OrderHistoryState> emit) {
    final updatedList = [event.order, ...state.allOrders];
    final filtered = _applyFilters(
      orders: updatedList,
      query: state.searchQuery,
      status: state.statusFilter,
      method: state.methodFilter,
    );

    emit(state.copyWith(
      allOrders: updatedList,
      filteredOrders: filtered,
      status: OrderHistoryStatus.updated,
      successMessage: 'Transaksi ${event.order.orderNumber} berhasil dicatat ke riwayat',
    ));
  }

  void _onVoidOrder(VoidOrderEvent event, Emitter<OrderHistoryState> emit) {
    // Check supervisor authorization PIN (Default: 1234)
    if (event.supervisorPin.trim() != '1234') {
      emit(state.copyWith(
        status: OrderHistoryStatus.error,
        errorMessage: 'PIN Otorisasi Supervisor salah. Transaksi tidak dapat dibatalkan.',
      ));
      return;
    }

    final int index = state.allOrders.indexWhere((o) => o.id == event.orderId);
    if (index == -1) return;

    final updatedOrders = List<Order>.from(state.allOrders);
    final target = updatedOrders[index];
    updatedOrders[index] = target.copyWith(
      paymentStatus: PaymentStatus.voided,
    );

    final filtered = _applyFilters(
      orders: updatedOrders,
      query: state.searchQuery,
      status: state.statusFilter,
      method: state.methodFilter,
    );

    emit(state.copyWith(
      allOrders: updatedOrders,
      filteredOrders: filtered,
      status: OrderHistoryStatus.updated,
      successMessage: 'Transaksi ${target.orderNumber} berhasil dibatalkan (VOID).',
    ));
  }

  void _onFilterOrders(FilterOrdersEvent event, Emitter<OrderHistoryState> emit) {
    final filtered = _applyFilters(
      orders: state.allOrders,
      query: event.searchQuery,
      status: event.statusFilter,
      method: event.methodFilter,
    );

    emit(state.copyWith(
      filteredOrders: filtered,
      searchQuery: event.searchQuery,
      statusFilter: event.statusFilter,
      clearStatusFilter: event.statusFilter == null,
      methodFilter: event.methodFilter,
      clearMethodFilter: event.methodFilter == null,
      status: OrderHistoryStatus.loaded,
    ));
  }

  List<Order> _applyFilters({
    required List<Order> orders,
    required String query,
    PaymentStatus? status,
    PaymentMethod? method,
  }) {
    return orders.where((order) {
      final matchesQuery = query.isEmpty ||
          order.orderNumber.toLowerCase().contains(query.toLowerCase()) ||
          order.customerName.toLowerCase().contains(query.toLowerCase()) ||
          (order.tableNumber != null &&
              order.tableNumber!.toLowerCase().contains(query.toLowerCase()));

      final matchesStatus = status == null || order.paymentStatus == status;
      final matchesMethod = method == null || order.paymentMethod == method;

      return matchesQuery && matchesStatus && matchesMethod;
    }).toList();
  }

  List<Order> _getSampleHistoricalOrders() {
    final now = DateTime.now();

    return [
      Order(
        id: 'ord-hist-1',
        orderNumber: 'CAVA-20260911-0001',
        tableNumber: 'T-02',
        customerName: 'Budi Santoso',
        orderType: OrderType.dineIn,
        items: const [
          OrderItem(
            id: 'hi-1',
            productId: 'p_latte',
            productName: 'Cava Signature Latte',
            basePrice: 32000,
            quantity: 2,
            selectedModifiers: [
              ProductModifierOption(id: 'm_oat', name: 'Oatside Oat Milk', additionalPrice: 7000),
              ProductModifierOption(id: 's_less', name: 'Less Sugar (50%)'),
            ],
          ),
          OrderItem(
            id: 'hi-2',
            productId: 'p_croissant',
            productName: 'Butter French Croissant',
            basePrice: 25000,
            quantity: 1,
          ),
        ],
        subtotal: 103000,
        serviceChargeRate: 0.05,
        serviceChargeAmount: 5150,
        taxRate: 0.10,
        taxAmount: 10815,
        grandTotal: 118965,
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.qris,
        cashierId: 'csh-01',
        cashierName: 'Arya (Kasir)',
        createdAt: now.subtract(const Duration(minutes: 145)),
        paidAt: now.subtract(const Duration(minutes: 144)),
        syncStatus: SyncStatus.synced,
      ),
      Order(
        id: 'ord-hist-2',
        orderNumber: 'CAVA-20260911-0002',
        customerName: 'Siska Amelia',
        orderType: OrderType.takeAway,
        items: const [
          OrderItem(
            id: 'hi-3',
            productId: 'p_aren',
            productName: 'Kopi Susu Gula Aren Cava',
            basePrice: 26000,
            quantity: 2,
          ),
          OrderItem(
            id: 'hi-4',
            productId: 'p_matcha',
            productName: 'Ceremonial Uji Matcha Latte',
            basePrice: 36000,
            quantity: 1,
          ),
        ],
        subtotal: 88000,
        serviceChargeRate: 0.0,
        serviceChargeAmount: 0,
        taxRate: 0.10,
        taxAmount: 8800,
        grandTotal: 96800,
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.cash,
        cashReceived: 100000,
        cashChange: 3200,
        cashierId: 'csh-01',
        cashierName: 'Arya (Kasir)',
        createdAt: now.subtract(const Duration(minutes: 90)),
        paidAt: now.subtract(const Duration(minutes: 89)),
        syncStatus: SyncStatus.synced,
      ),
      Order(
        id: 'ord-hist-3',
        orderNumber: 'CAVA-20260911-0003',
        tableNumber: 'VIP-1',
        customerName: 'Pak Hendra Gunawan',
        orderType: OrderType.dineIn,
        items: const [
          OrderItem(
            id: 'hi-5',
            productId: 'p_carbonara',
            productName: 'Truffle Cream Fettuccine',
            basePrice: 58000,
            quantity: 2,
          ),
          OrderItem(
            id: 'hi-6',
            productId: 'p_americano',
            productName: 'Iced Long Black / Americano',
            basePrice: 28000,
            quantity: 2,
          ),
        ],
        subtotal: 172000,
        serviceChargeRate: 0.05,
        serviceChargeAmount: 8600,
        taxRate: 0.10,
        taxAmount: 18060,
        grandTotal: 198660,
        paymentStatus: PaymentStatus.paid,
        paymentMethod: PaymentMethod.debitCard,
        cashierId: 'csh-01',
        cashierName: 'Arya (Kasir)',
        createdAt: now.subtract(const Duration(minutes: 50)),
        paidAt: now.subtract(const Duration(minutes: 48)),
        syncStatus: SyncStatus.synced,
      ),
      Order(
        id: 'ord-hist-4',
        orderNumber: 'CAVA-20260911-0004',
        tableNumber: 'T-04',
        customerName: 'Dimas Aditya',
        orderType: OrderType.dineIn,
        items: const [
          OrderItem(
            id: 'hi-7',
            productId: 'p_cinnamon',
            productName: 'Cream Cheese Cinnamon Roll',
            basePrice: 28000,
            quantity: 1,
          ),
        ],
        subtotal: 28000,
        serviceChargeRate: 0.05,
        serviceChargeAmount: 1400,
        taxRate: 0.10,
        taxAmount: 2940,
        grandTotal: 32340,
        paymentStatus: PaymentStatus.voided,
        paymentMethod: PaymentMethod.cash,
        cashierId: 'csh-01',
        cashierName: 'Arya (Kasir)',
        createdAt: now.subtract(const Duration(minutes: 30)),
        syncStatus: SyncStatus.synced,
      ),
    ];
  }
}
