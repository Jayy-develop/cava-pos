import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/mock_pos_data.dart';
import '../../domain/entities/product.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(const MenuState()) {
    on<LoadMenuEvent>(_onLoadMenu);
    on<UpdateProductPriceEvent>(_onUpdateProductPrice);
    on<ToggleProductAvailabilityEvent>(_onToggleAvailability);
    on<FilterCategoryEvent>(_onFilterCategory);
    on<SearchProductEvent>(_onSearchProduct);

    add(LoadMenuEvent());
  }

  void _onLoadMenu(LoadMenuEvent event, Emitter<MenuState> emit) {
    emit(state.copyWith(
      allProducts: List.from(MockPosData.products),
      categories: MockPosData.categories,
      status: MenuStatus.success,
    ));
  }

  void _onUpdateProductPrice(UpdateProductPriceEvent event, Emitter<MenuState> emit) {
    final int index = state.allProducts.indexWhere((p) => p.id == event.productId);
    if (index == -1) return;

    final updatedProducts = List<Product>.from(state.allProducts);
    final target = updatedProducts[index];

    final updatedProduct = target.copyWith(
      name: event.newName ?? target.name,
      basePrice: event.newPrice,
      costPrice: event.newCostPrice ?? target.costPrice,
      imageUrl: event.newImageUrl ?? target.imageUrl,
      isAvailable: event.isAvailable ?? target.isAvailable,
    );

    updatedProducts[index] = updatedProduct;

    emit(state.copyWith(
      allProducts: updatedProducts,
      status: MenuStatus.success,
      successMessage: 'Menu "${updatedProduct.name}" berhasil diperbarui!',
    ));
  }

  void _onToggleAvailability(ToggleProductAvailabilityEvent event, Emitter<MenuState> emit) {
    final int index = state.allProducts.indexWhere((p) => p.id == event.productId);
    if (index == -1) return;

    final updatedProducts = List<Product>.from(state.allProducts);
    final target = updatedProducts[index];
    final newAvailability = !target.isAvailable;

    updatedProducts[index] = target.copyWith(isAvailable: newAvailability);

    emit(state.copyWith(
      allProducts: updatedProducts,
      status: MenuStatus.success,
      successMessage: 'Status menu "${target.name}": ${newAvailability ? "Tersedia" : "Habis"}',
    ));
  }

  void _onFilterCategory(FilterCategoryEvent event, Emitter<MenuState> emit) {
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      clearMessages: true,
    ));
  }

  void _onSearchProduct(SearchProductEvent event, Emitter<MenuState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
      clearMessages: true,
    ));
  }
}
