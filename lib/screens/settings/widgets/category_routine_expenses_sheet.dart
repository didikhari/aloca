import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/hive_service.dart';
import '../../../models/category.dart';
import '../../../models/recurring_expense.dart';
import '../../../providers/period_provider.dart';
import '../../../providers/planned_expense_provider.dart';
import '../../../providers/recurring_expense_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/custom_card.dart';

class CategoryRoutineExpensesSheet extends ConsumerStatefulWidget {
  final Category category;

  const CategoryRoutineExpensesSheet({
    super.key,
    required this.category,
  });

  static void show(
    BuildContext context, {
    required Category category,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryRoutineExpensesSheet(category: category),
    );
  }

  @override
  ConsumerState<CategoryRoutineExpensesSheet> createState() =>
      _CategoryRoutineExpensesSheetState();
}

class _CategoryRoutineExpensesSheetState
    extends ConsumerState<CategoryRoutineExpensesSheet> {

  void _showAddDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Rutin: ${widget.category.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Pengeluaran Rutin',
                hintText: 'Misal: Listrik, Internet, Kos',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: AppColors.textInverse,
            ),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(recurringExpenseListProvider.notifier)
                    .addRecurringExpense(
                      categoryId: widget.category.id,
                      name: name,
                    );
                final activePeriodId = ref.read(activePeriodIdProvider);
                await HiveService.generateMonthlyExpensesFromRecurring(activePeriodId);
                ref.read(plannedExpenseListProvider.notifier).loadPlannedExpenses();
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(RecurringExpense item) {
    final controller = TextEditingController(text: item.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Pengeluaran Rutin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Pengeluaran Rutin',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: AppColors.textInverse,
            ),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final updated = item.copyWith(name: name);
                await ref
                    .read(recurringExpenseListProvider.notifier)
                    .updateRecurringExpense(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDialog(RecurringExpense item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengeluaran Rutin'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${item.name}" dari pengeluaran rutin ${widget.category.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: AppColors.textInverse,
            ),
            onPressed: () async {
              await ref
                  .read(recurringExpenseListProvider.notifier)
                  .deleteRecurringExpense(item.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allRecurring = ref.watch(recurringExpenseListProvider);
    final categoryRecurring = allRecurring
        .where((r) => r.categoryId == widget.category.id)
        .toList();
    categoryRecurring.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.radiusSheet,
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppRadius.handle),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header Card
          CustomCard(
            backgroundColor: AppColors.pageBackground,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.brandTint,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: const Icon(
                    Icons.repeat_outlined,
                    color: AppColors.brandPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: AppTypography.headingMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Kelola daftar master pengeluaran rutin',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Title & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Pengeluaran Rutin (${categoryRecurring.length})',
                  style: AppTypography.sectionTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add,
                    size: 18, color: AppColors.brandPrimary),
                label: const Text(
                  'Tambah Rutin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Items list
          Expanded(
            child: categoryRecurring.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.repeat_outlined,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Belum ada pengeluaran rutin untuk ${widget.category.name}.',
                          style: AppTypography.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: _showAddDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Tambah Pengeluaran Rutin'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: categoryRecurring.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (ctx, index) {
                      final item = categoryRecurring[index];
                      return CustomCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        backgroundColor: AppColors.surfaceWhite,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.horizontal_rule,
                              size: 16,
                              color: AppColors.brandPrimary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                item.name,
                                style: AppTypography.bodyPrimary,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.textSecondary),
                              tooltip: 'Edit Nama',
                              onPressed: () => _showEditDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.expenseRed),
                              tooltip: 'Hapus',
                              onPressed: () => _confirmDeleteDialog(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
