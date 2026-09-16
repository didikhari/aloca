import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/hive_service.dart';
import '../../models/category.dart';
import 'period_provider.dart';
import 'income_provider.dart';
import 'expense_provider.dart';
import 'allocation_provider.dart';
import 'category_provider.dart';
import 'planned_expense_provider.dart';

final isBalanceMaskedProvider = StateNotifierProvider<BalanceMaskNotifier, bool>((ref) {
  return BalanceMaskNotifier();
});

class BalanceMaskNotifier extends StateNotifier<bool> {
  static const String _key = 'is_balance_masked';

  BalanceMaskNotifier() : super(_loadInitialState());

  static bool _loadInitialState() {
    final val = HiveService.getSetting(_key);
    return val == 'true';
  }

  void toggleMask() {
    final newState = !state;
    state = newState;
    HiveService.setSetting(_key, newState.toString());
  }
}

class CategoryBudgetStatus {
  final Category category;
  final int allocated;
  final int actual;
  final int remaining;
  final double usageRatio;
  final String status; // 'Under Budget', 'On Budget', 'Over Budget'
  final int totalPlannedItems;
  final int paidItemsCount;
  final int unpaidItemsCount;
  final int totalPlannedAmount;

  CategoryBudgetStatus({
    required this.category,
    required this.allocated,
    required this.actual,
    required this.remaining,
    required this.usageRatio,
    required this.status,
    this.totalPlannedItems = 0,
    this.paidItemsCount = 0,
    this.unpaidItemsCount = 0,
    this.totalPlannedAmount = 0,
  });
}

class MonthlySummary {
  final int openingBalance;
  final int totalIncome;
  final int totalAvailable;
  final int totalAllocated;
  final int unallocatedAmount;
  final int totalActualExpenses;
  final int remainingBudget;
  final int closingBalance;
  final List<CategoryBudgetStatus> categoryStatuses;

  MonthlySummary({
    required this.openingBalance,
    required this.totalIncome,
    required this.totalAvailable,
    required this.totalAllocated,
    required this.unallocatedAmount,
    required this.totalActualExpenses,
    required this.remainingBudget,
    required this.closingBalance,
    required this.categoryStatuses,
  });
}

final monthlySummaryProvider = Provider<MonthlySummary>((ref) {
  final period = ref.watch(activePeriodProvider);
  final incomes = ref.watch(incomeListProvider);
  final transactions = ref.watch(transactionListProvider);
  final allocations = ref.watch(allocationListProvider);
  final categories = ref.watch(categoryListProvider);
  final plannedExpenses = ref.watch(plannedExpenseListProvider);

  final openingBalance = period.openingBalance;
  final totalIncome = incomes.fold<int>(0, (sum, i) => sum + i.amount);
  final totalAvailable = openingBalance + totalIncome;

  final totalAllocated = allocations.fold<int>(0, (sum, a) => sum + a.allocatedAmount);
  final unallocatedAmount = totalAvailable - totalAllocated;

  final expenseTransactions = transactions.where((t) => t.type == 'Expense').toList();
  final totalActualExpenses = expenseTransactions.fold<int>(0, (sum, t) => sum + t.amount);

  final remainingBudget = totalAllocated - totalActualExpenses;
  final closingBalance = totalAvailable - totalActualExpenses;

  final categoryStatuses = <CategoryBudgetStatus>[];

  for (final cat in categories.where((c) => c.isActive)) {
    final matchingAlloc = allocations.where((a) => a.categoryId == cat.id);
    final catAlloc = matchingAlloc.isNotEmpty ? matchingAlloc.first : null;
    final allocated = catAlloc?.allocatedAmount ?? 0;

    final catExpenses = expenseTransactions.where((t) => t.categoryId == cat.id);
    final actual = catExpenses.fold<int>(0, (sum, t) => sum + t.amount);

    final catPlanned = plannedExpenses.where((pe) => pe.categoryId == cat.id).toList();
    final totalPlannedItems = catPlanned.length;
    final paidItemsCount = catPlanned.where((pe) => pe.isPaid).length;
    final unpaidItemsCount = catPlanned.where((pe) => !pe.isPaid).length;
    final totalPlannedAmount = catPlanned.fold<int>(0, (sum, pe) => sum + pe.plannedAmount);

    final remaining = allocated - actual;
    final usageRatio = allocated > 0 ? (actual / allocated) : (actual > 0 ? 1.0 : 0.0);

    String status = 'Under Budget';
    if (actual > allocated && allocated > 0) {
      status = 'Over Budget';
    } else if (actual == allocated && allocated > 0) {
      status = 'On Budget';
    }

    categoryStatuses.add(CategoryBudgetStatus(
      category: cat,
      allocated: allocated,
      actual: actual,
      remaining: remaining,
      usageRatio: usageRatio,
      status: status,
      totalPlannedItems: totalPlannedItems,
      paidItemsCount: paidItemsCount,
      unpaidItemsCount: unpaidItemsCount,
      totalPlannedAmount: totalPlannedAmount,
    ));
  }

  return MonthlySummary(
    openingBalance: openingBalance,
    totalIncome: totalIncome,
    totalAvailable: totalAvailable,
    totalAllocated: totalAllocated,
    unallocatedAmount: unallocatedAmount,
    totalActualExpenses: totalActualExpenses,
    remainingBudget: remainingBudget,
    closingBalance: closingBalance,
    categoryStatuses: categoryStatuses,
  );
});
