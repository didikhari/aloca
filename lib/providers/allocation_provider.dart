import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/hive_service.dart';
import '../../models/allocation.dart';
import '../../models/allocation_template.dart';
import 'period_provider.dart';
import 'income_provider.dart';

final allocationListProvider =
    StateNotifierProvider<AllocationListNotifier, List<Allocation>>((ref) {
  final activePeriodId = ref.watch(activePeriodIdProvider);
  return AllocationListNotifier(ref, activePeriodId);
});

class AllocationListNotifier extends StateNotifier<List<Allocation>> {
  final Ref ref;
  final String activePeriodId;

  AllocationListNotifier(this.ref, this.activePeriodId) : super([]) {
    loadAllocations();
  }

  void loadAllocations() {
    state = HiveService.getAllocationsForPeriod(activePeriodId);
  }

  Future<void> saveAllocations(List<Allocation> allocations) async {
    final targetPeriodId =
        allocations.isNotEmpty ? allocations.first.periodId : activePeriodId;
    await HiveService.deleteAllocationsForPeriod(targetPeriodId);
    await HiveService.saveAllocations(allocations);
    loadAllocations();
  }

  Future<void> generateFromTemplate(AllocationTemplate template) async {
    final items = HiveService.getTemplateItems(template.id);
    final period = ref.read(activePeriodProvider);
    final incomes = ref.read(incomeListProvider);

    final totalIncome = incomes.fold<int>(0, (sum, item) => sum + item.amount);
    final availableFunds = period.openingBalance + totalIncome;

    const uuid = Uuid();
    final newAllocations = <Allocation>[];

    int nonRemainingTotal = 0;
    final calculatedNominals = <String, int>{};

    // Pass 1: Calculate fixed and percentage allocations
    for (final item in items) {
      int calculatedNominal = 0;
      if (item.method == 'percentage') {
        calculatedNominal = ((availableFunds * item.value) / 100.0).floor();
      } else if (item.method == 'fixed') {
        calculatedNominal = item.value.toInt();
      }

      if (item.method != 'remaining') {
        nonRemainingTotal += calculatedNominal;
        calculatedNominals[item.id] = calculatedNominal;
      }
    }

    // Remaining funds available after non-remaining allocations
    int remainingAvailable = availableFunds - nonRemainingTotal;
    if (remainingAvailable < 0) {
      remainingAvailable = 0;
    }

    // Pass 2: Assign remaining allocations
    for (final item in items) {
      if (item.method == 'remaining') {
        calculatedNominals[item.id] = remainingAvailable;
        remainingAvailable = 0;
      }
    }

    for (final item in items) {
      final nominal = calculatedNominals[item.id] ?? 0;
      newAllocations.add(Allocation(
        id: 'alloc_${uuid.v4()}',
        periodId: activePeriodId,
        categoryId: item.categoryId,
        method: item.method,
        value: item.value,
        allocatedAmount: nominal,
      ));
    }

    await HiveService.deleteAllocationsForPeriod(activePeriodId);
    await HiveService.saveAllocations(newAllocations);
    loadAllocations();
  }
}
