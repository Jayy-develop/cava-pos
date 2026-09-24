import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

enum MenuStatus { initial, loading, success, error }

class MenuState extends Equatable {
  final List<Product> allProducts;
  final List<ProductCategory> categories;
  final String selectedCategoryId;
  final String searchQuery;
  final MenuStatus status;
  final String? successMessage;
  final String? errorMessage;

  const MenuState({
    this.allProducts = const [],
    this.categories = const [],
    this.selectedCategoryId = 'all',
    this.searchQuery = '',
    this.status = MenuStatus.initial,
    this.successMessage,
    this.errorMessage,
  });

  List<Product> get filteredProducts {
    return allProducts.where((prod) {
      final matchesCategory = selectedCategoryId == 'all' || prod.categoryId == selectedCategoryId;
      final matchesQuery = searchQuery.isEmpty ||
          prod.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          prod.sku.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  MenuState copyWith({
    List<Product>? allProducts,
    List<ProductCategory>? categories,
    String? selectedCategoryId,
    String? searchQuery,
    MenuStatus? status,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return MenuState(
      allProducts: allProducts ?? this.allProducts,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      successMessage: clearMessages ? null : successMessage,
      errorMessage: clearMessages ? null : errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        allProducts,
        categories,
        selectedCategoryId,
        searchQuery,
        status,
        successMessage,
        errorMessage,
      ];
}
