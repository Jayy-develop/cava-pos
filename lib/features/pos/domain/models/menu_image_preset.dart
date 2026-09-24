class MenuImagePreset {
  final String title;
  final String category;
  final String url;

  const MenuImagePreset({
    required this.title,
    required this.category,
    required this.url,
  });

  static const List<MenuImagePreset> presets = [
    // Coffee
    MenuImagePreset(
      title: 'Signature Latte Art',
      category: 'Coffee',
      url: 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Classic Cappuccino',
      category: 'Coffee',
      url: 'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Iced Americano',
      category: 'Coffee',
      url: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Kopi Susu Aren',
      category: 'Coffee',
      url: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Espresso Double Shot',
      category: 'Coffee',
      url: 'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Caramel Macchiato',
      category: 'Coffee',
      url: 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?auto=format&fit=crop&w=600&q=80',
    ),

    // Non-Coffee
    MenuImagePreset(
      title: 'Ceremonial Matcha Latte',
      category: 'Non-Coffee',
      url: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Artisan Dark Chocolate',
      category: 'Non-Coffee',
      url: 'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Earl Grey Artisan Tea',
      category: 'Non-Coffee',
      url: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Berry Refreshing Mocktail',
      category: 'Non-Coffee',
      url: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
    ),

    // Main Course (Food)
    MenuImagePreset(
      title: 'Truffle Cream Fettuccine',
      category: 'Food',
      url: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281298?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Crispy Dori Rice Bowl',
      category: 'Food',
      url: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Wagyu Beef Burger',
      category: 'Food',
      url: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Chicken Caesar Salad',
      category: 'Food',
      url: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80',
    ),

    // Pastry & Bakery
    MenuImagePreset(
      title: 'French Butter Croissant',
      category: 'Pastry',
      url: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Cream Cheese Cinnamon Roll',
      category: 'Pastry',
      url: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Pain au Chocolat',
      category: 'Pastry',
      url: 'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?auto=format&fit=crop&w=600&q=80',
    ),
    MenuImagePreset(
      title: 'Basque Burnt Cheesecake',
      category: 'Pastry',
      url: 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=600&q=80',
    ),
  ];
}
