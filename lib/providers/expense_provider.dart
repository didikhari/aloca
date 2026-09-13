import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/hive_service.dart';
import '../../models/transaction.dart';
import 'period_provider.dart';

final transactionListProvider = StateNotifierProvider<TransactionListNotifier, List<Transaction>>((ref) {
  final activePeriodId = ref.watch(activePeriodIdProvider);
  return TransactionListNotifier(ref, activePeriodId);
});

class TransactionListNotifier extends StateNotifier<List<Transaction>> {
  final Ref ref;
  final String activePeriodId;

  TransactionListNotifier(this.ref, this.activePeriodId) : super([]) {
    loadTransactions();
  }

  void loadTransactions() {
    state = HiveService.getTransactionsForPeriod(activePeriodId);
  }

  Future<void> addTransaction(Transaction transaction) async {
    await HiveService.saveTransaction(transaction);
    loadTransactions();
    await ref.read(periodListProvider.notifier).recalculateAllPeriodsChain();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await HiveService.saveTransaction(transaction);
    loadTransactions();
    await ref.read(periodListProvider.notifier).recalculateAllPeriodsChain();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await HiveService.deleteTransaction(transactionId);
    loadTransactions();
    await ref.read(periodListProvider.notifier).recalculateAllPeriodsChain();
  }
}
