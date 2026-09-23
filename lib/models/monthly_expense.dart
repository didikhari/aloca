/// Model representing a monthly expense item for a period.
/// Unpaid expenses (`isPaid == false`) MUST have a `null` amount (meaning not yet paid / unknown).
/// Paid expenses (`isPaid == true`) contain the actual paid `amount` and `paymentDate`.
class MonthlyExpense {
  final String id;
  final String periodId;
  final String categoryId;
  final String title;
  final bool isPaid;
  final int? amount; // Nullable: null = unpaid / amount not entered yet.
  final DateTime? paymentDate;
  final String? recurringExpenseId;
  final String? note;

  MonthlyExpense({
    required this.id,
    required this.periodId,
    required this.categoryId,
    required this.title,
    this.isPaid = false,
    this.amount,
    this.paymentDate,
    this.recurringExpenseId,
    this.note,
  });

  MonthlyExpense copyWith({
    String? id,
    String? periodId,
    String? categoryId,
    String? title,
    bool? isPaid,
    int? amount,
    DateTime? paymentDate,
    String? recurringExpenseId,
    String? note,
  }) {
    return MonthlyExpense(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      isPaid: isPaid ?? this.isPaid,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      recurringExpenseId: recurringExpenseId ?? this.recurringExpenseId,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodId': periodId,
      'categoryId': categoryId,
      'title': title,
      'isPaid': isPaid,
      'amount': amount,
      'paymentDate': paymentDate?.toIso8601String(),
      'recurringExpenseId': recurringExpenseId,
      'note': note,
    };
  }

  factory MonthlyExpense.fromMap(Map<String, dynamic> map) {
    return MonthlyExpense(
      id: map['id'] as String,
      periodId: map['periodId'] as String,
      categoryId: map['categoryId'] as String,
      title: map['title'] as String,
      isPaid: map['isPaid'] as bool? ?? false,
      amount: map['amount'] != null ? (map['amount'] as num).toInt() : null,
      paymentDate: map['paymentDate'] != null
          ? DateTime.parse(map['paymentDate'] as String)
          : null,
      recurringExpenseId: map['recurringExpenseId'] as String?,
      note: map['note'] as String?,
    );
  }
}
