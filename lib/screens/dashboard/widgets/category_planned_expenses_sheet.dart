import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/category.dart';
import '../../../models/monthly_expense.dart';
import '../../../providers/planned_expense_provider.dart';
import '../../../providers/summary_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/custom_card.dart';

class CategoryPlannedExpensesSheet extends ConsumerStatefulWidget {
  final Category category;
  final int allocatedAmount;
  final int actualExpense;

  const CategoryPlannedExpensesSheet({
    super.key,
    required this.category,
    required this.allocatedAmount,
    required this.actualExpense,
  });

  static void show(
    BuildContext context, {
    required Category category,
    required int allocatedAmount,
    required int actualExpense,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPlannedExpensesSheet(
        category: category,
        allocatedAmount: allocatedAmount,
        actualExpense: actualExpense,
      ),
    );
  }

  @override
  ConsumerState<CategoryPlannedExpensesSheet> createState() =>
      _CategoryPlannedExpensesSheetState();
}

class _CategoryPlannedExpensesSheetState
    extends ConsumerState<CategoryPlannedExpensesSheet> {

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isPaid = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Tambah Pengeluaran ${widget.category.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Pengeluaran',
                  hintText: 'Misal: Pulsa, Token Listrik, Belanja',
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sudah Dibayar?'),
                value: isPaid,
                onChanged: (val) {
                  setDialogState(() {
                    isPaid = val;
                  });
                },
              ),
              if (isPaid) ...[
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Nominal Dibayar (Rp)',
                    hintText: '0',
                    prefixText: 'Rp ',
                  ),
                ),
              ],
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
              onPressed: () {
                final title = titleController.text.trim();
                final amount = CurrencyFormatter.parse(amountController.text);

                if (title.isNotEmpty) {
                  ref
                      .read(plannedExpenseListProvider.notifier)
                      .addPlannedExpense(
                        categoryId: widget.category.id,
                        title: title,
                        isPaid: isPaid,
                        amount: isPaid ? amount : null,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(MonthlyExpense item) {
    final amountController = TextEditingController(
      text: item.amount != null && item.amount! > 0
          ? CurrencyFormatter.formatNumberOnly(item.amount!)
          : '',
    );
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.payment, color: AppColors.brandPrimary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Bayar: ${item.title}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Nominal yang Dibayarkan (Rp)',
                  hintText: '0',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Pembayaran',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate)),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
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
              onPressed: () {
                final actualAmount =
                    CurrencyFormatter.parse(amountController.text);

                if (actualAmount > 0) {
                  ref
                      .read(plannedExpenseListProvider.notifier)
                      .payPlannedExpense(
                        item: item,
                        actualPaidAmount: actualAmount,
                        paymentDate: selectedDate,
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${item.title} sebesar ${CurrencyFormatter.format(actualAmount)} berhasil dibayarkan!',
                      ),
                      backgroundColor: AppColors.brandPrimary,
                    ),
                  );
                }
              },
              child: const Text('Konfirmasi Bayar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allMonthlyExpenses = ref.watch(plannedExpenseListProvider);
    final categoryExpenses = allMonthlyExpenses
        .where((me) => me.categoryId == widget.category.id)
        .toList();
    categoryExpenses
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    final paidCount = categoryExpenses.where((me) => me.isPaid).length;
    final totalCount = categoryExpenses.length;

    final monthlySummary = ref.watch(monthlySummaryProvider);
    final catStatusList = monthlySummary.categoryStatuses
        .where((cs) => cs.category.id == widget.category.id);
    final catStatus = catStatusList.isNotEmpty ? catStatusList.first : null;
    final allocatedAmount = catStatus?.allocated ?? widget.allocatedAmount;
    final actualExpense = catStatus?.actual ?? widget.actualExpense;
    final remainingBudget =
        catStatus?.remaining ?? (allocatedAmount - actualExpense);

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
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
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

          // Category Header Card
          CustomCard(
            backgroundColor: AppColors.pageBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: const BoxDecoration(
                        color: AppColors.brandTint,
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: const Icon(
                        Icons.category_outlined,
                        color: AppColors.brandPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.category.name,
                        style: AppTypography.headingMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: paidCount == totalCount && totalCount > 0
                            ? AppColors.successBgLight
                            : AppColors.warningBadgeBg,
                        borderRadius: AppRadius.radiusLg,
                      ),
                      child: Text(
                        '$paidCount/$totalCount Lunas',
                        style: AppTypography.labelStandard.copyWith(
                          color: paidCount == totalCount && totalCount > 0
                              ? const Color(0xFF166534)
                              : const Color(0xFF92400E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alokasi Anggaran',
                            style: AppTypography.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(allocatedAmount),
                            style: AppTypography.labelStandard.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sudah Dibayar',
                            style: AppTypography.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(actualExpense),
                            style: AppTypography.labelStandard.copyWith(
                              color: AppColors.expenseRed,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sisa Anggaran',
                            style: AppTypography.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(remainingBudget),
                            style: AppTypography.labelStandard.copyWith(
                              color: remainingBudget >= 0
                                  ? AppColors.brandPrimary
                                  : AppColors.expenseRed,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Section Title & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Daftar Pengeluaran',
                  style: AppTypography.sectionTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton.icon(
                onPressed: _showAddExpenseDialog,
                icon: const Icon(Icons.add,
                    size: 18, color: AppColors.brandPrimary),
                label: const Text(
                  'Tambah Pengeluaran',
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

          // Expenses List
          Expanded(
            child: categoryExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist_rtl_outlined,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Belum ada pengeluaran untuk ${widget.category.name}.',
                          style: AppTypography.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: _showAddExpenseDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Tambah Pengeluaran'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: categoryExpenses.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (ctx, index) {
                      final item = categoryExpenses[index];
                      return _buildExpenseTile(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(BuildContext context, MonthlyExpense item) {
    final isPaid = item.isPaid;

    return CustomCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: isPaid ? AppColors.paidTileBg : AppColors.surfaceWhite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status Checkbox
          GestureDetector(
            onTap: () {
              if (isPaid) {
                ref
                    .read(plannedExpenseListProvider.notifier)
                    .unpayPlannedExpense(item);
              } else {
                _showPayDialog(item);
              }
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPaid ? AppColors.brandPrimary : AppColors.surfaceWhite,
                border: Border.all(
                  color: isPaid ? AppColors.brandPrimary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isPaid
                  ? const Icon(Icons.check,
                      size: 16, color: AppColors.textInverse)
                  : null,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Title & Amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: isPaid ? TextDecoration.lineThrough : null,
                    color: isPaid
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (isPaid && item.amount != null)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sudah Dibayar: ${CurrencyFormatter.format(item.amount!)}',
                          style: AppTypography.labelStandard.copyWith(
                            color: const Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.paymentDate != null)
                          TextSpan(
                            text: ' • ${DateFormat('d MMM', 'id_ID').format(item.paymentDate!)}',
                            style: AppTypography.labelStandard.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'Belum Dibayar: —',
                    style: AppTypography.labelStandard.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Action Button
          if (!isPaid)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: AppColors.textInverse,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _showPayDialog(item),
              child: const Text('Bayar', style: TextStyle(fontSize: 12)),
            )
          else
            IconButton(
              icon: const Icon(Icons.undo,
                  size: 18, color: AppColors.textSecondary),
              tooltip: 'Batalkan Pembayaran',
              onPressed: () {
                ref
                    .read(plannedExpenseListProvider.notifier)
                    .unpayPlannedExpense(item);
              },
            ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                size: 18, color: AppColors.textMuted),
            onSelected: (val) {
              if (val == 'delete') {
                ref
                    .read(plannedExpenseListProvider.notifier)
                    .deletePlannedExpense(item.id);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 16, color: AppColors.expenseRed),
                    SizedBox(width: AppSpacing.sm),
                    Text('Hapus', style: TextStyle(color: AppColors.expenseRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
