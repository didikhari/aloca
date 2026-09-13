class Income {
  final String id;
  final String periodId;
  final DateTime date;
  final String description;
  final int amount;
  final String type; // Salary, Bonus, Other

  Income({
    required this.id,
    required this.periodId,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
  });

  Income copyWith({
    String? id,
    String? periodId,
    DateTime? date,
    String? description,
    int? amount,
    String? type,
  }) {
    return Income(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodId': periodId,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'type': type,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as String,
      periodId: map['periodId'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      amount: (map['amount'] as num).toInt(),
      type: map['type'] as String? ?? 'Salary',
    );
  }
}
