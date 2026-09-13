import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/hive_service.dart';
import '../../models/financial_period.dart';

final periodListProvider = StateNotifierProvider<PeriodListNotifier, List<FinancialPeriod>>((ref) {
  return PeriodListNotifier();
});

class PeriodListNotifier extends StateNotifier<List<FinancialPeriod>> {
  PeriodListNotifier() : super([]) {
    loadPeriods();
  }

  void loadPeriods() {
    var periods = HiveService.getAllPeriods();
    if (periods.isEmpty) {
      final now = DateTime.now();
      final initialPeriodId = FinancialPeriod.generateId(now.year, now.month);
      final initialPeriod = FinancialPeriod(
        id: initialPeriodId,
        year: now.year,
        month: now.month,
        openingBalance: 0,
      );
      HiveService.savePeriod(initialPeriod);
      periods = [initialPeriod];
    }
    recalculateAllPeriodsChain(periods);
  }

  /// Recalculates Opening Balances for all periods sequentially:
  /// Closing Balance (M-1) = Opening (M-1) + Income (M-1) - Expense (M-1)
  /// Opening Balance (M) = Closing Balance (M-1)
  Future<void> recalculateAllPeriodsChain([List<FinancialPeriod>? currentPeriods]) async {
    final list = currentPeriods ?? HiveService.getAllPeriods();
    list.sort((a, b) => a.id.compareTo(b.id));

    final updatedList = <FinancialPeriod>[];
    for (int i = 0; i < list.length; i++) {
      var period = list[i];
      if (i > 0) {
        final prevPeriod = updatedList[i - 1];
        final prevIncomes = HiveService.getIncomesForPeriod(prevPeriod.id);
        final prevExpenses = HiveService.getTransactionsForPeriod(prevPeriod.id)
            .where((t) => t.type == 'Expense');

        final totalPrevIncome = prevIncomes.fold<int>(0, (sum, item) => sum + item.amount);
        final totalPrevExpense = prevExpenses.fold<int>(0, (sum, item) => sum + item.amount);
        final calculatedClosing = prevPeriod.openingBalance + totalPrevIncome - totalPrevExpense;

        if (period.openingBalance != calculatedClosing) {
          period = period.copyWith(openingBalance: calculatedClosing);
          await HiveService.savePeriod(period);
        }
      }
      updatedList.add(period);
    }
    state = updatedList;
  }

  Future<FinancialPeriod> getOrCreatePeriod(int year, int month) async {
    final periodId = FinancialPeriod.generateId(year, month);
    final existing = HiveService.getPeriod(periodId);
    if (existing != null) return existing;

    // Calculate opening balance based on closing balance of preceding period if exists
    final all = HiveService.getAllPeriods();
    all.sort((a, b) => a.id.compareTo(b.id));
    int opening = 0;
    
    // Find latest period before this one
    final prevPeriods = all.where((p) => p.id.compareTo(periodId) < 0).toList();
    if (prevPeriods.isNotEmpty) {
      final prev = prevPeriods.last;
      final prevIncomes = HiveService.getIncomesForPeriod(prev.id);
      final prevExpenses = HiveService.getTransactionsForPeriod(prev.id)
          .where((t) => t.type == 'Expense');
      final totalIncome = prevIncomes.fold<int>(0, (sum, item) => sum + item.amount);
      final totalExpense = prevExpenses.fold<int>(0, (sum, item) => sum + item.amount);
      opening = prev.openingBalance + totalIncome - totalExpense;
    }

    final newPeriod = FinancialPeriod(
      id: periodId,
      year: year,
      month: month,
      openingBalance: opening,
    );
    await HiveService.savePeriod(newPeriod);
    await recalculateAllPeriodsChain();
    return newPeriod;
  }

  Future<void> updateInitialOpeningBalance(String periodId, int amount) async {
    final period = HiveService.getPeriod(periodId);
    if (period != null) {
      final updated = period.copyWith(openingBalance: amount);
      await HiveService.savePeriod(updated);
      await recalculateAllPeriodsChain();
    }
  }
}

final activePeriodIdProvider = StateProvider<String>((ref) {
  final periods = ref.watch(periodListProvider);
  if (periods.isNotEmpty) {
    return periods.last.id;
  }
  final now = DateTime.now();
  return FinancialPeriod.generateId(now.year, now.month);
});

final activePeriodProvider = Provider<FinancialPeriod>((ref) {
  final periods = ref.watch(periodListProvider);
  final activeId = ref.watch(activePeriodIdProvider);
  return periods.firstWhere(
    (p) => p.id == activeId,
    orElse: () {
      final now = DateTime.now();
      return FinancialPeriod(
        id: activeId,
        year: now.year,
        month: now.month,
        openingBalance: 0,
      );
    },
  );
});
