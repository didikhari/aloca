import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/hive_service.dart';
import '../../models/planned_expense.dart';
import '../../models/transaction.dart';
import 'expense_provider.dart';
import 'period_provider.dart';

final plannedExpenseListProvider =
    StateNotifierProvider<PlannedExpenseListNotifier, List<PlannedExpense>>(
        (ref) {
  final activePeriodId = ref.watch(activePeriodIdProvider);
  return PlannedExpenseListNotifier(ref, activePeriodId);
});

class PlannedExpenseListNotifier extends StateNotifier<List<PlannedExpense>> {
  final Ref ref;
  final String activePeriodId;

  PlannedExpenseListNotifier(this.ref, this.activePeriodId) : super([]) {
    loadPlannedExpenses();
  }

  void loadPlannedExpenses() {
    state = HiveService.getPlannedExpensesForPeriod(activePeriodId);
  }

  Future<void> addPlannedExpense({
    required String categoryId,
    required String title,
    required int plannedAmount,
    DateTime? dueDate,
  }) async {
    final newItem = PlannedExpense(
      id: 'pe_${const Uuid().v4()}',
      periodId: activePeriodId,
      categoryId: categoryId,
      title: title,
      plannedAmount: plannedAmount,
      dueDate: dueDate,
      isPaid: false,
    );
    await HiveService.savePlannedExpense(newItem);
    loadPlannedExpenses();
  }

  Future<void> updatePlannedExpense(PlannedExpense item) async {
    await HiveService.savePlannedExpense(item);
    loadPlannedExpenses();
  }

  Future<void> deletePlannedExpense(String id) async {
    final item = state.firstWhere(
      (element) => element.id == id,
      orElse: () => PlannedExpense(
          id: '', periodId: '', categoryId: '', title: '', plannedAmount: 0),
    );
    if (item.id.isNotEmpty && item.isPaid && item.paidTransactionId != null) {
      // Also remove associated transaction if paid
      await ref
          .read(transactionListProvider.notifier)
          .deleteTransaction(item.paidTransactionId!);
    }
    await HiveService.deletePlannedExpense(id);
    loadPlannedExpenses();
  }

  /// 1-Tap Pay Action
  /// Creates actual transaction, updates planned expense status and paid transaction link.
  Future<void> payPlannedExpense({
    required PlannedExpense item,
    required int actualPaidAmount,
    DateTime? paymentDate,
  }) async {
    final now = paymentDate ?? DateTime.now();
    final isAbovePlanned = actualPaidAmount > item.plannedAmount;

    // Create actual expense transaction
    final newTx = Transaction(
      id: 'tx_${const Uuid().v4()}',
      periodId: activePeriodId,
      date: now,
      description: item.title,
      categoryId: item.categoryId,
      amount: actualPaidAmount,
      type: 'Expense',
      note: isAbovePlanned
          ? 'Dibayar di atas rencana (+Rp ${actualPaidAmount - item.plannedAmount})'
          : null,
    );

    final updatedItem = item.copyWith(
      isPaid: true,
      actualPaidAmount: actualPaidAmount,
      paidTransactionId: newTx.id,
    );

    // Save planned expense FIRST so paidTransactionId is linked before transaction notification
    await HiveService.savePlannedExpense(updatedItem);
    await ref.read(transactionListProvider.notifier).addTransaction(newTx);
    loadPlannedExpenses();
  }

  /// Undo Payment
  Future<void> unpayPlannedExpense(PlannedExpense item) async {
    if (!item.isPaid) return;

    final txId = item.paidTransactionId;

    final updatedItem = item.copyWith(
      isPaid: false,
      actualPaidAmount: null,
      paidTransactionId: null,
    );

    await HiveService.savePlannedExpense(updatedItem);
    if (txId != null) {
      await ref.read(transactionListProvider.notifier).deleteTransaction(txId);
    }
    loadPlannedExpenses();
  }
}
