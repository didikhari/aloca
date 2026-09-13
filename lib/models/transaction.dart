class Transaction {
  final String id;
  final String periodId;
  final DateTime date;
  final String description;
  final String categoryId;
  final int amount; // Integer IDR amount
  final String type; // Expense, Income, Transfer
  final String? note;

  Transaction({
    required this.id,
    required this.periodId,
    required this.date,
    required this.description,
    required this.categoryId,
    required this.amount,
    this.type = 'Expense',
    this.note,
  });

  Transaction copyWith({
    String? id,
    String? periodId,
    DateTime? date,
    String? description,
    String? categoryId,
    int? amount,
    String? type,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      date: date ?? this.date,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodId': periodId,
      'date': date.toIso8601String(),
      'description': description,
      'categoryId': categoryId,
      'amount': amount,
      'type': type,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      periodId: map['periodId'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      categoryId: map['categoryId'] as String,
      amount: (map['amount'] as num).toInt(),
      type: map['type'] as String? ?? 'Expense',
      note: map['note'] as String?,
    );
  }
}
