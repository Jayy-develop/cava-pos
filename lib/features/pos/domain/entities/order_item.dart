import 'package:equatable/equatable.dart';
import 'product.dart';

class OrderItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final double basePrice;
  final ProductVariant? selectedVariant;
  final List<ProductModifierOption> selectedModifiers;
  final int quantity;
  final double itemDiscount; // Direct item-level discount (e.g. promo)
  final String notes;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.basePrice,
    this.selectedVariant,
    this.selectedModifiers = const [],
    this.quantity = 1,
    this.itemDiscount = 0.0,
    this.notes = '',
  });

  /// Price addition from variant + all selected modifiers for a single unit
  double get singleUnitAdditions {
    double additions = selectedVariant?.priceDelta ?? 0.0;
    for (final mod in selectedModifiers) {
      additions += mod.additionalPrice;
    }
    return additions;
  }

  /// Price per single item including variant and modifiers
  double get unitPrice => basePrice + singleUnitAdditions;

  /// Gross total before item discount
  double get grossTotal => unitPrice * quantity;

  /// Net item total after item discount
  double get netTotal => (grossTotal - itemDiscount).clamp(0.0, double.infinity);

  OrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? basePrice,
    ProductVariant? selectedVariant,
    List<ProductModifierOption>? selectedModifiers,
    int? quantity,
    double? itemDiscount,
    String? notes,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      basePrice: basePrice ?? this.basePrice,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      quantity: quantity ?? this.quantity,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'basePrice': basePrice,
    'selectedVariant': selectedVariant?.toJson(),
    'selectedModifiers': selectedModifiers.map((e) => e.toJson()).toList(),
    'quantity': quantity,
    'itemDiscount': itemDiscount,
    'notes': notes,
    'unitPrice': unitPrice,
    'netTotal': netTotal,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as String,
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    basePrice: (json['basePrice'] as num).toDouble(),
    selectedVariant: json['selectedVariant'] != null
        ? ProductVariant.fromJson(json['selectedVariant'] as Map<String, dynamic>)
        : null,
    selectedModifiers: (json['selectedModifiers'] as List<dynamic>?)
            ?.map((e) => ProductModifierOption.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    quantity: json['quantity'] as int? ?? 1,
    itemDiscount: (json['itemDiscount'] as num?)?.toDouble() ?? 0.0,
    notes: json['notes'] as String? ?? '',
  );

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        basePrice,
        selectedVariant,
        selectedModifiers,
        quantity,
        itemDiscount,
        notes,
      ];
}
