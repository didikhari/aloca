class Category {
  final String id;
  final String name;
  final String type; // Expense
  final String colorHex;
  final String iconName;
  final bool isActive;
  final int displayOrder;

  Category({
    required this.id,
    required this.name,
    this.type = 'Expense',
    this.colorHex = '#00A884',
    this.iconName = 'category',
    this.isActive = true,
    this.displayOrder = 0,
  });

  Category copyWith({
    String? id,
    String? name,
    String? type,
    String? colorHex,
    String? iconName,
    bool? isActive,
    int? displayOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'colorHex': colorHex,
      'iconName': iconName,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String? ?? 'Expense',
      colorHex: map['colorHex'] as String? ?? '#00A884',
      iconName: map['iconName'] as String? ?? 'category',
      isActive: map['isActive'] as bool? ?? true,
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  static List<Category> defaultCategories() {
    return [
      Category(
        id: 'cat_housing',
        name: 'Kebutuhan Utama',
        colorHex: '#00A884',
        iconName: 'home',
        displayOrder: 1,
      ),
      Category(
        id: 'cat_investment',
        name: 'Tabungan & Investasi',
        colorHex: '#10B981',
        iconName: 'trending_up',
        displayOrder: 2,
      ),
      Category(
        id: 'cat_emergency',
        name: 'Dana Darurat',
        colorHex: '#F59E0B',
        iconName: 'shield',
        displayOrder: 3,
      ),
      Category(
        id: 'cat_lifestyle',
        name: 'Lifestyle & Healing',
        colorHex: '#EC4899',
        iconName: 'movie',
        displayOrder: 4,
      ),
      Category(
        id: 'cat_family',
        name: 'Bantu Keluarga / Other',
        colorHex: '#8B5CF6',
        iconName: 'people',
        displayOrder: 5,
      ),
    ];
  }
}
