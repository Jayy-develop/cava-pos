import 'package:equatable/equatable.dart';

enum IngredientUnit { gram, ml, pcs }

class InventoryIngredient extends Equatable {
  final String id;
  final String sku;
  final String name;
  final IngredientUnit unit;
  final double currentStock;
  final double minStockAlert;
  final double costPerUnit; // e.g., Rp/gram or Rp/ml

  const InventoryIngredient({
    required this.id,
    required this.sku,
    required this.name,
    required this.unit,
    required this.currentStock,
    required this.minStockAlert,
    required this.costPerUnit,
  });

  bool get isLowStock => currentStock <= minStockAlert;

  InventoryIngredient copyWith({
    String? id,
    String? sku,
    String? name,
    IngredientUnit? unit,
    double? currentStock,
    double? minStockAlert,
    double? costPerUnit,
  }) {
    return InventoryIngredient(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      costPerUnit: costPerUnit ?? this.costPerUnit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'unit': unit.name,
      'currentStock': currentStock,
      'minStockAlert': minStockAlert,
      'costPerUnit': costPerUnit,
    };
  }

  factory InventoryIngredient.fromJson(Map<String, dynamic> json) {
    return InventoryIngredient(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      unit: IngredientUnit.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => IngredientUnit.gram,
      ),
      currentStock: (json['currentStock'] as num).toDouble(),
      minStockAlert: (json['minStockAlert'] as num).toDouble(),
      costPerUnit: (json['costPerUnit'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, sku, name, unit, currentStock, minStockAlert, costPerUnit];
}

class RecipeItem extends Equatable {
  final String ingredientId;
  final double amountRequired;

  const RecipeItem({
    required this.ingredientId,
    required this.amountRequired,
  });

  Map<String, dynamic> toJson() => {
    'ingredientId': ingredientId,
    'amountRequired': amountRequired,
  };

  factory RecipeItem.fromJson(Map<String, dynamic> json) => RecipeItem(
    ingredientId: json['ingredientId'] as String,
    amountRequired: (json['amountRequired'] as num).toDouble(),
  );

  @override
  List<Object?> get props => [ingredientId, amountRequired];
}
