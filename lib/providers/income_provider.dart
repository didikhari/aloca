import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/hive_service.dart';
import '../../models/income.dart';
import 'period_provider.dart';

final incomeListProvider = StateNotifierProvider<IncomeListNotifier, List<Income>>((ref) {
  final activePeriodId = ref.watch(activePeriodIdProvider);
  return IncomeListNotifier(ref, activePeriodId);
});

class IncomeListNotifier extends StateNotifier<List<Income>> {
  final Ref ref;
  final String activePeriodId;

  IncomeListNotifier(this.ref, this.activePeriodId) : super([]) {
    loadIncomes();
  }

  void loadIncomes() {
    state = HiveService.getIncomesForPeriod(activePeriodId);
  }

  Future<void> addIncome(Income income) async {
    await HiveService.saveIncome(income);
    loadIncomes();
    await ref.read(periodListProvider.notifier).recalculateAllPeriodsChain();
  }

  Future<void> updateIncome(Income income) async {
    await HiveService.saveIncome(income);
    loadIncomes();
    await ref.read(periodListProvider.notifier).recalculateAllPeriodsChain();
  }

  Future<void> deleteIncome(String incomeId) async {
    await HiveService.deleteIncome(incomeId);
    loadIncomes();
    await ref.read(periodListProvider.notifier).recalculateAllPeriodsChain();
  }
}
