import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int displayOrder;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.displayOrder = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'displayOrder': displayOrder,
  };

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    displayOrder: json['displayOrder'] as int? ?? 0,
  );

  @override
  List<Object?> get props => [id, name, icon, displayOrder];
}
