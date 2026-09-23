import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/hive_service.dart';
import '../../models/monthly_expense.dart';
import '../../models/transaction.dart';
import 'expense_provider.dart';
import 'period_provider.dart';

final plannedExpenseListProvider =
    StateNotifierProvider<PlannedExpenseListNotifier, List<MonthlyExpense>>(
        (ref) {
  final activePeriodId = ref.watch(activePeriodIdProvider);
  return PlannedExpenseListNotifier(ref, activePeriodId);
});

class PlannedExpenseListNotifier extends StateNotifier<List<MonthlyExpense>> {
  final Ref ref;
  final String activePeriodId;

  PlannedExpenseListNotifier(this.ref, this.activePeriodId) : super([]) {
    loadPlannedExpenses();
  }

  void loadPlannedExpenses() {
    final list = HiveService.getMonthlyExpensesForPeriod(activePeriodId);
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    state = list;
  }

  Future<void> addPlannedExpense({
    required String categoryId,
    required String title,
    int? amount,
    bool isPaid = false,
    DateTime? paymentDate,
  }) async {
    final newItem = MonthlyExpense(
      id: 'me_${const Uuid().v4()}',
      periodId: activePeriodId,
      categoryId: categoryId,
      title: title,
      isPaid: isPaid,
      amount: isPaid ? amount : null,
      paymentDate: isPaid ? (paymentDate ?? DateTime.now()) : null,
    );
    await HiveService.saveMonthlyExpense(newItem);
    if (isPaid && amount != null && amount > 0) {
      final newTx = Transaction(
        id: 'tx_${const Uuid().v4()}',
        periodId: activePeriodId,
        date: paymentDate ?? DateTime.now(),
        description: title,
        categoryId: categoryId,
        amount: amount,
        type: 'Expense',
      );
      await ref.read(transactionListProvider.notifier).addTransaction(newTx);
    }
    loadPlannedExpenses();
  }

  Future<void> updatePlannedExpense(MonthlyExpense item) async {
    await HiveService.saveMonthlyExpense(item);
    loadPlannedExpenses();
  }

  Future<void> deletePlannedExpense(String id) async {
    await HiveService.deleteMonthlyExpense(id);
    loadPlannedExpenses();
  }

  /// 1-Tap Pay Action
  /// Updates monthly expense status to paid with actual amount and payment date.
  Future<void> payPlannedExpense({
    required MonthlyExpense item,
    required int actualPaidAmount,
    DateTime? paymentDate,
  }) async {
    final now = paymentDate ?? DateTime.now();

    // Create actual expense transaction
    final newTx = Transaction(
      id: 'tx_${const Uuid().v4()}',
      periodId: activePeriodId,
      date: now,
      description: item.title,
      categoryId: item.categoryId,
      amount: actualPaidAmount,
      type: 'Expense',
    );

    final updatedItem = item.copyWith(
      isPaid: true,
      amount: actualPaidAmount,
      paymentDate: now,
    );

    await HiveService.saveMonthlyExpense(updatedItem);
    await ref.read(transactionListProvider.notifier).addTransaction(newTx);
    loadPlannedExpenses();
  }

  /// Undo Payment
  Future<void> unpayPlannedExpense(MonthlyExpense item) async {
    if (!item.isPaid) return;

    final updatedItem = item.copyWith(
      isPaid: false,
      amount: null,
      paymentDate: null,
    );

    await HiveService.saveMonthlyExpense(updatedItem);
    loadPlannedExpenses();
  }
}
