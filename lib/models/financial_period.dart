import 'package:intl/intl.dart';

class FinancialPeriod {
  final String id; // Format: "YYYY-MM" e.g. "2026-09"
  final int year;
  final int month;
  final int openingBalance;
  final bool isClosed;

  FinancialPeriod({
    required this.id,
    required this.year,
    required this.month,
    required this.openingBalance,
    this.isClosed = false,
  });

  String get displayText {
    final date = DateTime(year, month, 1);
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  String get shortMonthName {
    final date = DateTime(year, month, 1);
    return DateFormat('MMM', 'id_ID').format(date);
  }

  FinancialPeriod copyWith({
    String? id,
    int? year,
    int? month,
    int? openingBalance,
    bool? isClosed,
  }) {
    return FinancialPeriod(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      openingBalance: openingBalance ?? this.openingBalance,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'openingBalance': openingBalance,
      'isClosed': isClosed,
    };
  }

  factory FinancialPeriod.fromMap(Map<String, dynamic> map) {
    return FinancialPeriod(
      id: map['id'] as String,
      year: map['year'] as int,
      month: map['month'] as int,
      openingBalance: (map['openingBalance'] as num).toInt(),
      isClosed: map['isClosed'] as bool? ?? false,
    );
  }

  static String generateId(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }
}
