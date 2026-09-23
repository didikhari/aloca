/// Model representing a recurring monthly expense identity belonging to a Category (Pengeluaran Rutin).
/// IMPORTANT: Pengeluaran Rutin MUST NOT contain a nominal amount.
class RecurringExpense {
  final String id;
  final String categoryId;
  final String name;
  final bool isActive;
  final int displayOrder;

  RecurringExpense({
    required this.id,
    required this.categoryId,
    required this.name,
    this.isActive = true,
    this.displayOrder = 0,
  });

  RecurringExpense copyWith({
    String? id,
    String? categoryId,
    String? name,
    bool? isActive,
    int? displayOrder,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }

  factory RecurringExpense.fromMap(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      name: map['name'] as String,
      isActive: map['isActive'] as bool? ?? true,
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  static List<RecurringExpense> defaultRecurringExpenses() {
    return [
      RecurringExpense(
        id: 'rec_pulsa',
        categoryId: 'cat_housing',
        name: 'Pulsa',
        displayOrder: 1,
      ),
      RecurringExpense(
        id: 'rec_listrik',
        categoryId: 'cat_housing',
        name: 'Listrik',
        displayOrder: 2,
      ),
      RecurringExpense(
        id: 'rec_internet',
        categoryId: 'cat_housing',
        name: 'Internet',
        displayOrder: 3,
      ),
      RecurringExpense(
        id: 'rec_makan',
        categoryId: 'cat_housing',
        name: 'Makan',
        displayOrder: 4,
      ),
      RecurringExpense(
        id: 'rec_kebutuhan_pokok',
        categoryId: 'cat_housing',
        name: 'Kebutuhan Pokok',
        displayOrder: 5,
      ),
    ];
  }
}
