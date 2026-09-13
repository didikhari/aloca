class PlannedExpense {
  final String id;
  final String periodId;
  final String categoryId;
  final String title;
  final int plannedAmount; // Integer nominal in IDR
  final int? actualPaidAmount; // Actual amount paid if different from planned
  final bool isPaid;
  final String? paidTransactionId;
  final DateTime? dueDate;

  PlannedExpense({
    required this.id,
    required this.periodId,
    required this.categoryId,
    required this.title,
    required this.plannedAmount,
    this.actualPaidAmount,
    this.isPaid = false,
    this.paidTransactionId,
    this.dueDate,
  });

  bool get isPaidAbovePlanned {
    if (!isPaid || actualPaidAmount == null) return false;
    return actualPaidAmount! > plannedAmount;
  }

  int get overrunAmount {
    if (!isPaidAbovePlanned) return 0;
    return actualPaidAmount! - plannedAmount;
  }

  PlannedExpense copyWith({
    String? id,
    String? periodId,
    String? categoryId,
    String? title,
    int? plannedAmount,
    int? actualPaidAmount,
    bool? isPaid,
    String? paidTransactionId,
    DateTime? dueDate,
  }) {
    return PlannedExpense(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      actualPaidAmount: actualPaidAmount ?? this.actualPaidAmount,
      isPaid: isPaid ?? this.isPaid,
      paidTransactionId: paidTransactionId ?? this.paidTransactionId,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodId': periodId,
      'categoryId': categoryId,
      'title': title,
      'plannedAmount': plannedAmount,
      'actualPaidAmount': actualPaidAmount,
      'isPaid': isPaid,
      'paidTransactionId': paidTransactionId,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory PlannedExpense.fromMap(Map<String, dynamic> map) {
    return PlannedExpense(
      id: map['id'] as String,
      periodId: map['periodId'] as String,
      categoryId: map['categoryId'] as String,
      title: map['title'] as String,
      plannedAmount: (map['plannedAmount'] as num).toInt(),
      actualPaidAmount: map['actualPaidAmount'] != null
          ? (map['actualPaidAmount'] as num).toInt()
          : null,
      isPaid: map['isPaid'] as bool? ?? false,
      paidTransactionId: map['paidTransactionId'] as String?,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
    );
  }
}
