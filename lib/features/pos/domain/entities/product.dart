import 'package:equatable/equatable.dart';
import '../../../inventory/domain/ingredient.dart';

class ProductModifierOption extends Equatable {
  final String id;
  final String name;
  final double additionalPrice;
  final List<RecipeItem> recipeItems; // Ingredients consumed if option chosen (e.g., Oat Milk 150ml)

  const ProductModifierOption({
    required this.id,
    required this.name,
    this.additionalPrice = 0.0,
    this.recipeItems = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'additionalPrice': additionalPrice,
    'recipeItems': recipeItems.map((e) => e.toJson()).toList(),
  };

  factory ProductModifierOption.fromJson(Map<String, dynamic> json) => ProductModifierOption(
    id: json['id'] as String,
    name: json['name'] as String,
    additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0.0,
    recipeItems: (json['recipeItems'] as List<dynamic>?)
            ?.map((e) => RecipeItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );

  @override
  List<Object?> get props => [id, name, additionalPrice, recipeItems];
}

class ProductModifierGroup extends Equatable {
  final String id;
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;
  final List<ProductModifierOption> options;

  const ProductModifierGroup({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.minSelection = 0,
    this.maxSelection = 1,
    required this.options,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isRequired': isRequired,
    'minSelection': minSelection,
    'maxSelection': maxSelection,
    'options': options.map((e) => e.toJson()).toList(),
  };

  factory ProductModifierGroup.fromJson(Map<String, dynamic> json) => ProductModifierGroup(
    id: json['id'] as String,
    name: json['name'] as String,
    isRequired: json['isRequired'] as bool? ?? false,
    minSelection: json['minSelection'] as int? ?? 0,
    maxSelection: json['maxSelection'] as int? ?? 1,
    options: (json['options'] as List<dynamic>)
        .map((e) => ProductModifierOption.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  @override
  List<Object?> get props => [id, name, isRequired, minSelection, maxSelection, options];
}

class ProductVariant extends Equatable {
  final String id;
  final String name;
  final double priceDelta; // e.g., Large = +Rp 5.000

  const ProductVariant({
    required this.id,
    required this.name,
    this.priceDelta = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'priceDelta': priceDelta,
  };

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: json['id'] as String,
    name: json['name'] as String,
    priceDelta: (json['priceDelta'] as num?)?.toDouble() ?? 0.0,
  );

  @override
  List<Object?> get props => [id, name, priceDelta];
}

class Product extends Equatable {
  final String id;
  final String sku;
  final String name;
  final String description;
  final String categoryId;
  final double basePrice;
  final double costPrice; // HPP (Harga Pokok Penjualan)
  final String imageUrl;
  final bool isAvailable;
  final List<ProductVariant> variants;
  final List<ProductModifierGroup> modifierGroups;
  final List<RecipeItem> baseRecipe; // Base recipe (e.g. 18g espresso beans)

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    this.description = '',
    required this.categoryId,
    required this.basePrice,
    this.costPrice = 0.0,
    this.imageUrl = '',
    this.isAvailable = true,
    this.variants = const [],
    this.modifierGroups = const [],
    this.baseRecipe = const [],
  });

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    String? categoryId,
    double? basePrice,
    double? costPrice,
    String? imageUrl,
    bool? isAvailable,
    List<ProductVariant>? variants,
    List<ProductModifierGroup>? modifierGroups,
    List<RecipeItem>? baseRecipe,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      basePrice: basePrice ?? this.basePrice,
      costPrice: costPrice ?? this.costPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      variants: variants ?? this.variants,
      modifierGroups: modifierGroups ?? this.modifierGroups,
      baseRecipe: baseRecipe ?? this.baseRecipe,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'name': name,
    'description': description,
    'categoryId': categoryId,
    'basePrice': basePrice,
    'costPrice': costPrice,
    'imageUrl': imageUrl,
    'isAvailable': isAvailable,
    'variants': variants.map((e) => e.toJson()).toList(),
    'modifierGroups': modifierGroups.map((e) => e.toJson()).toList(),
    'baseRecipe': baseRecipe.map((e) => e.toJson()).toList(),
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    sku: json['sku'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    categoryId: json['categoryId'] as String,
    basePrice: (json['basePrice'] as num).toDouble(),
    costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
    imageUrl: json['imageUrl'] as String? ?? '',
    isAvailable: json['isAvailable'] as bool? ?? true,
    variants: (json['variants'] as List<dynamic>?)
            ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    modifierGroups: (json['modifierGroups'] as List<dynamic>?)
            ?.map((e) => ProductModifierGroup.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    baseRecipe: (json['baseRecipe'] as List<dynamic>?)
            ?.map((e) => RecipeItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );

  @override
  List<Object?> get props => [
        id,
        sku,
        name,
        description,
        categoryId,
        basePrice,
        costPrice,
        imageUrl,
        isAvailable,
        variants,
        modifierGroups,
        baseRecipe,
      ];
}
