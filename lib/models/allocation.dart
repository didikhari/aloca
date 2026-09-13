class Allocation {
  final String id;
  final String periodId;
  final String categoryId;
  final String method; // 'percentage', 'fixed', 'remaining'
  final double value;
  final int allocatedAmount; // Integer nominal in IDR

  Allocation({
    required this.id,
    required this.periodId,
    required this.categoryId,
    required this.method,
    required this.value,
    required this.allocatedAmount,
  });

  Allocation copyWith({
    String? id,
    String? periodId,
    String? categoryId,
    String? method,
    double? value,
    int? allocatedAmount,
  }) {
    return Allocation(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      categoryId: categoryId ?? this.categoryId,
      method: method ?? this.method,
      value: value ?? this.value,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodId': periodId,
      'categoryId': categoryId,
      'method': method,
      'value': value,
      'allocatedAmount': allocatedAmount,
    };
  }

  factory Allocation.fromMap(Map<String, dynamic> map) {
    return Allocation(
      id: map['id'] as String,
      periodId: map['periodId'] as String,
      categoryId: map['categoryId'] as String,
      method: map['method'] as String? ?? 'percentage',
      value: (map['value'] as num).toDouble(),
      allocatedAmount: (map['allocatedAmount'] as num).toInt(),
    );
  }
}
