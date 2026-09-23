import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/hive_service.dart';
import '../models/recurring_expense.dart';

class RecurringExpenseListNotifier extends StateNotifier<List<RecurringExpense>> {
  RecurringExpenseListNotifier() : super([]) {
    loadRecurringExpenses();
  }

  void loadRecurringExpenses() {
    state = HiveService.getAllRecurringExpenses();
  }

  Future<void> addRecurringExpense({
    required String categoryId,
    required String name,
  }) async {
    final id = 'rec_${DateTime.now().millisecondsSinceEpoch}';
    final newExpense = RecurringExpense(
      id: id,
      categoryId: categoryId,
      name: name.trim(),
      isActive: true,
      displayOrder: state.length + 1,
    );
    await HiveService.saveRecurringExpense(newExpense);
    loadRecurringExpenses();
  }

  Future<void> updateRecurringExpense(RecurringExpense expense) async {
    await HiveService.saveRecurringExpense(expense);
    loadRecurringExpenses();
  }

  Future<void> toggleActive(String expenseId) async {
    final index = state.indexWhere((e) => e.id == expenseId);
    if (index != -1) {
      final item = state[index];
      final updated = item.copyWith(isActive: !item.isActive);
      await HiveService.saveRecurringExpense(updated);
      loadRecurringExpenses();
    }
  }

  Future<void> deleteRecurringExpense(String expenseId) async {
    await HiveService.deleteRecurringExpense(expenseId);
    loadRecurringExpenses();
  }
}

final recurringExpenseListProvider =
    StateNotifierProvider<RecurringExpenseListNotifier, List<RecurringExpense>>((ref) {
  return RecurringExpenseListNotifier();
});

final categoryRecurringExpensesProvider =
    Provider.family<List<RecurringExpense>, String>((ref, categoryId) {
  final all = ref.watch(recurringExpenseListProvider);
  return all.where((e) => e.categoryId == categoryId).toList();
});
