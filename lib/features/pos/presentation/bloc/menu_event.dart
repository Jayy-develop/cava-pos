import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuEvent extends MenuEvent {}

class UpdateProductPriceEvent extends MenuEvent {
  final String productId;
  final String? newName;
  final double newPrice;
  final double? newCostPrice;
  final String? newImageUrl;
  final bool? isAvailable;
  final String? authorizedPin;

  const UpdateProductPriceEvent({
    required this.productId,
    this.newName,
    required this.newPrice,
    this.newCostPrice,
    this.newImageUrl,
    this.isAvailable,
    this.authorizedPin,
  });

  @override
  List<Object?> get props => [productId, newName, newPrice, newCostPrice, newImageUrl, isAvailable, authorizedPin];
}

class ToggleProductAvailabilityEvent extends MenuEvent {
  final String productId;

  const ToggleProductAvailabilityEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class FilterCategoryEvent extends MenuEvent {
  final String categoryId;

  const FilterCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchProductEvent extends MenuEvent {
  final String query;

  const SearchProductEvent(this.query);

  @override
  List<Object?> get props => [query];
}
