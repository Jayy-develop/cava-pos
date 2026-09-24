import '../domain/entities/category.dart';
import '../domain/entities/product.dart';
import '../domain/entities/cafe_table.dart';
import '../../inventory/domain/ingredient.dart';

class MockPosData {
  MockPosData._();

  static const List<ProductCategory> categories = [
    ProductCategory(id: 'all', name: 'Semua Menu', icon: 'apps', displayOrder: 0),
    ProductCategory(id: 'coffee', name: 'Coffee', icon: 'coffee', displayOrder: 1),
    ProductCategory(id: 'non_coffee', name: 'Non-Coffee', icon: 'cup', displayOrder: 2),
    ProductCategory(id: 'food', name: 'Main Course', icon: 'restaurant', displayOrder: 3),
    ProductCategory(id: 'pastry', name: 'Pastry & Bakery', icon: 'bakery', displayOrder: 4),
  ];

  static const List<ProductModifierGroup> beverageModifierGroups = [
    ProductModifierGroup(
      id: 'sugar_level',
      name: 'Sugar Level',
      isRequired: true,
      minSelection: 1,
      maxSelection: 1,
      options: [
        ProductModifierOption(id: 's_normal', name: 'Normal Sugar (100%)'),
        ProductModifierOption(id: 's_less', name: 'Less Sugar (50%)'),
        ProductModifierOption(id: 's_slight', name: 'Slight Sugar (25%)'),
        ProductModifierOption(id: 's_zero', name: 'No Sugar (0%)'),
      ],
    ),
    ProductModifierGroup(
      id: 'milk_type',
      name: 'Pilihan Susu',
      isRequired: false,
      minSelection: 0,
      maxSelection: 1,
      options: [
        ProductModifierOption(
          id: 'm_dairy',
          name: 'Fresh Dairy Milk',
          additionalPrice: 0,
          recipeItems: [RecipeItem(ingredientId: 'ing_fresh_milk', amountRequired: 150)],
        ),
        ProductModifierOption(
          id: 'm_oat',
          name: 'Oatside Oat Milk',
          additionalPrice: 7000,
          recipeItems: [RecipeItem(ingredientId: 'ing_oat_milk', amountRequired: 150)],
        ),
        ProductModifierOption(
          id: 'm_almond',
          name: 'Almond Milk',
          additionalPrice: 9000,
          recipeItems: [RecipeItem(ingredientId: 'ing_almond_milk', amountRequired: 150)],
        ),
      ],
    ),
    ProductModifierGroup(
      id: 'extras',
      name: 'Add-on Ekstra',
      isRequired: false,
      minSelection: 0,
      maxSelection: 3,
      options: [
        ProductModifierOption(
          id: 'ex_shot',
          name: 'Extra Espresso Shot',
          additionalPrice: 8000,
          recipeItems: [RecipeItem(ingredientId: 'ing_espresso_beans', amountRequired: 18)],
        ),
        ProductModifierOption(
          id: 'ex_caramel',
          name: 'Caramel Syrup',
          additionalPrice: 5000,
          recipeItems: [RecipeItem(ingredientId: 'ing_caramel_syrup', amountRequired: 20)],
        ),
        ProductModifierOption(
          id: 'ex_vanilla',
          name: 'Vanilla Syrup',
          additionalPrice: 5000,
          recipeItems: [RecipeItem(ingredientId: 'ing_vanilla_syrup', amountRequired: 20)],
        ),
      ],
    ),
  ];

  static const List<ProductVariant> drinkSizes = [
    ProductVariant(id: 'sz_reg', name: 'Regular', priceDelta: 0),
    ProductVariant(id: 'sz_lrg', name: 'Large (+12oz)', priceDelta: 6000),
  ];

  static final List<Product> products = [
    Product(
      id: 'p_latte',
      sku: 'CAV-COF-001',
      name: 'Cava Signature Latte',
      description: 'Espresso blend Arabica Gayo & Flores dengan steamed milk lembut.',
      categoryId: 'coffee',
      basePrice: 32000,
      costPrice: 8500, // COGS (HPP)
      imageUrl: 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?auto=format&fit=crop&w=600&q=80',
      variants: drinkSizes,
      modifierGroups: beverageModifierGroups,
      baseRecipe: const [
        RecipeItem(ingredientId: 'ing_espresso_beans', amountRequired: 18),
        RecipeItem(ingredientId: 'ing_fresh_milk', amountRequired: 180),
      ],
    ),
    Product(
      id: 'p_cappuccino',
      sku: 'CAV-COF-002',
      name: 'Classic Cappuccino',
      description: 'Keseimbangan espresso, steamed milk, dan busa mikro tebal taburan kakao.',
      categoryId: 'coffee',
      basePrice: 32000,
      costPrice: 8000,
      imageUrl: 'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=600&q=80',
      variants: drinkSizes,
      modifierGroups: beverageModifierGroups,
      baseRecipe: const [
        RecipeItem(ingredientId: 'ing_espresso_beans', amountRequired: 18),
        RecipeItem(ingredientId: 'ing_fresh_milk', amountRequired: 140),
      ],
    ),
    Product(
      id: 'p_americano',
      sku: 'CAV-COF-003',
      name: 'Iced Long Black / Americano',
      description: 'Double shot espresso tuang atas filtered ice water. Notes citrus & brown sugar.',
      categoryId: 'coffee',
      basePrice: 28000,
      costPrice: 4200,
      imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
      variants: drinkSizes,
      modifierGroups: [beverageModifierGroups[0], beverageModifierGroups[2]],
      baseRecipe: const [
        RecipeItem(ingredientId: 'ing_espresso_beans', amountRequired: 18),
      ],
    ),
    Product(
      id: 'p_aren',
      sku: 'CAV-COF-004',
      name: 'Kopi Susu Gula Aren Cava',
      description: 'Espresso pekat, susu segar, dan aren organik nira aren murni.',
      categoryId: 'coffee',
      basePrice: 26000,
      costPrice: 6500,
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=600&q=80',
      variants: drinkSizes,
      modifierGroups: beverageModifierGroups,
      baseRecipe: const [
        RecipeItem(ingredientId: 'ing_espresso_beans', amountRequired: 18),
        RecipeItem(ingredientId: 'ing_fresh_milk', amountRequired: 150),
        RecipeItem(ingredientId: 'ing_gula_aren', amountRequired: 25),
      ],
    ),
    Product(
      id: 'p_matcha',
      sku: 'CAV-NCF-001',
      name: 'Ceremonial Uji Matcha Latte',
      description: 'Matcha grade seremonial dari Kyoto dipadukan susu manis lembut.',
      categoryId: 'non_coffee',
      basePrice: 36000,
      costPrice: 11000,
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=600&q=80',
      variants: drinkSizes,
      modifierGroups: beverageModifierGroups,
    ),
    Product(
      id: 'p_chocolate',
      sku: 'CAV-NCF-002',
      name: 'Artisan Dark Chocolate 70%',
      description: 'Cokelat Belgia single origin dengan susu gurih kental.',
      categoryId: 'non_coffee',
      basePrice: 34000,
      costPrice: 9500,
      imageUrl: 'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?auto=format&fit=crop&w=600&q=80',
      variants: drinkSizes,
      modifierGroups: beverageModifierGroups,
    ),
    Product(
      id: 'p_carbonara',
      sku: 'CAV-FOD-001',
      name: 'Truffle Cream Fettuccine',
      description: 'Pasta al dente saus krim truffle harum, beef bacon krispi, dan parmesan.',
      categoryId: 'food',
      basePrice: 58000,
      costPrice: 21000,
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281298?auto=format&fit=crop&w=600&q=80',
    ),
    Product(
      id: 'p_sambal_matah',
      sku: 'CAV-FOD-002',
      name: 'Crispy Dori Sambal Matah Rice Bowl',
      description: 'Ikan dori goreng tepung renyah dengan racikan sambal matah Bali segar.',
      categoryId: 'food',
      basePrice: 48000,
      costPrice: 17500,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
    ),
    Product(
      id: 'p_croissant',
      sku: 'CAV-PAS-001',
      name: 'Butter French Croissant',
      description: 'Croissant berlapis mentega Prancis Elle & Vire, renyah di luar lembut di dalam.',
      categoryId: 'pastry',
      basePrice: 25000,
      costPrice: 8000,
      imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
    ),
    Product(
      id: 'p_cinnamon',
      sku: 'CAV-PAS-002',
      name: 'Cream Cheese Cinnamon Roll',
      description: 'Roti gulung kayu manis harum dengan glaze cream cheese lumer.',
      categoryId: 'pastry',
      basePrice: 28000,
      costPrice: 9000,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80',
    ),
  ];

  static final List<CafeTable> sampleTables = [
    const CafeTable(id: 't1', tableNumber: 'T-01', capacity: 2, section: 'Indoor', status: TableStatus.vacant),
    const CafeTable(id: 't2', tableNumber: 'T-02', capacity: 4, section: 'Indoor', status: TableStatus.occupied, activeOrderId: 'ord-092', activeOrderAmount: 145000, occupiedMinutes: 42),
    const CafeTable(id: 't3', tableNumber: 'T-03', capacity: 4, section: 'Indoor', status: TableStatus.vacant),
    const CafeTable(id: 't4', tableNumber: 'T-04', capacity: 6, section: 'Indoor', status: TableStatus.reserved),
    const CafeTable(id: 't5', tableNumber: 'VIP-1', capacity: 8, section: 'VIP Room', status: TableStatus.vacant),
    const CafeTable(id: 't6', tableNumber: 'OUT-1', capacity: 4, section: 'Outdoor Terrace', status: TableStatus.occupied, activeOrderId: 'ord-093', activeOrderAmount: 88000, occupiedMinutes: 18),
    const CafeTable(id: 't7', tableNumber: 'OUT-2', capacity: 2, section: 'Outdoor Terrace', status: TableStatus.vacant),
  ];
}
