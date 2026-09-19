import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/category.dart';
import '../../../models/planned_expense.dart';
import '../../../models/transaction.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/period_provider.dart';
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
  int _selectedTab = 0; // 0: Rencana Pengeluaran, 1: Diluar Rencana

  void _showAddPlannedDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Rencana ${widget.category.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Tagihan / Rencana',
                hintText: 'Misal: Listrik PLN, Internet, Kos',
              ),
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Nominal Rencana (Rp)',
                hintText: '0',
                prefixText: 'Rp ',
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
              final title = titleController.text.trim();
              final amount = CurrencyFormatter.parse(amountController.text);

              if (title.isNotEmpty && amount > 0) {
                ref.read(plannedExpenseListProvider.notifier).addPlannedExpense(
                      categoryId: widget.category.id,
                      title: title,
                      plannedAmount: amount,
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan Rencana'),
          ),
        ],
      ),
    );
  }

  void _showAddUnplannedTransactionDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Transaksi ${widget.category.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Keterangan Transaksi',
                hintText: 'Misal: Beli Kopi, Tambal Ban, Jajanan',
              ),
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                hintText: '0',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: noteController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
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
              final title = titleController.text.trim();
              final amount = CurrencyFormatter.parse(amountController.text);
              final note = noteController.text.trim();

              if (title.isNotEmpty && amount > 0) {
                final activePeriodId = ref.read(activePeriodIdProvider);
                const uuid = Uuid();
                final newTx = Transaction(
                  id: 'tx_${uuid.v4()}',
                  periodId: activePeriodId,
                  date: DateTime.now(),
                  description: title,
                  categoryId: widget.category.id,
                  amount: amount,
                  type: 'Expense',
                  note: note.isNotEmpty ? note : null,
                );

                ref
                    .read(transactionListProvider.notifier)
                    .addTransaction(newTx);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Transaksi ${newTx.description} (${CurrencyFormatter.format(amount)}) berhasil ditambahkan.',
                    ),
                    backgroundColor: AppColors.brandPrimary,
                  ),
                );
              }
            },
            child: const Text('Simpan Transaksi'),
          ),
        ],
      ),
    );
  }

  void _showPayDialog(PlannedExpense item) {
    final actualAmountController = TextEditingController(
      text: CurrencyFormatter.formatNumberOnly(item.plannedAmount),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            Text(
              'Rencana Nominal: ${CurrencyFormatter.format(item.plannedAmount)}',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: actualAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Nominal Aktual yang Dibayarkan (Rp)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Jika nominal aktual melebihi rencana, aplikasi akan memberikan indikator "Di atas rencana".',
              style: AppTypography.labelSmall,
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
                  CurrencyFormatter.parse(actualAmountController.text);

              if (actualAmount > 0) {
                ref.read(plannedExpenseListProvider.notifier).payPlannedExpense(
                      item: item,
                      actualPaidAmount: actualAmount,
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
    );
  }

  void _confirmDeleteUnplannedTransaction(Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi "${tx.description}" sebesar ${CurrencyFormatter.format(tx.amount)}?',
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
            onPressed: () {
              ref
                  .read(transactionListProvider.notifier)
                  .deleteTransaction(tx.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Transaksi ${tx.description} berhasil dihapus.'),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPlanned = ref.watch(plannedExpenseListProvider);
    final categoryPlanned =
        allPlanned.where((pe) => pe.categoryId == widget.category.id).toList();
    categoryPlanned
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    final allTransactions = ref.watch(transactionListProvider);
    final categoryTransactions = allTransactions
        .where(
            (tx) => tx.categoryId == widget.category.id && tx.type == 'Expense')
        .toList();

    final paidTxIds = categoryPlanned
        .map((pe) => pe.paidTransactionId)
        .where((id) => id != null)
        .toSet();

    final unplannedTransactions =
        categoryTransactions.where((tx) => !paidTxIds.contains(tx.id)).toList();
    unplannedTransactions.sort((a, b) => b.date.compareTo(a.date));

    final paidCount = categoryPlanned.where((pe) => pe.isPaid).length;
    final totalCount = categoryPlanned.length;
    final totalPlannedNominal =
        categoryPlanned.fold<int>(0, (sum, pe) => sum + pe.plannedAmount);
    final totalUnplannedNominal =
        unplannedTransactions.fold<int>(0, (sum, tx) => sum + tx.amount);
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
                            'Total Rencana',
                            style: AppTypography.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(totalPlannedNominal),
                            style: AppTypography.labelStandard.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Non-Rencana',
                            style: AppTypography.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(totalUnplannedNominal),
                            style: AppTypography.labelStandard.copyWith(
                              color: AppColors.expenseRed,
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

          // Tab Switcher Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedTab == 0
                          ? AppColors.brandPrimary
                          : AppColors.chipSubSurface,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Center(
                      child: Text(
                        'Rencana (${categoryPlanned.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _selectedTab == 0
                              ? AppColors.textInverse
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedTab == 1
                          ? AppColors.brandPrimary
                          : AppColors.chipSubSurface,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Center(
                      child: Text(
                        'Diluar Rencana (${unplannedTransactions.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _selectedTab == 1
                              ? AppColors.textInverse
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Tab Content
          if (_selectedTab == 0) ...[
            // Section Title & Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Daftar Rencana Pengeluaran',
                    style: AppTypography.sectionTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton.icon(
                  onPressed: _showAddPlannedDialog,
                  icon: const Icon(Icons.add,
                      size: 18, color: AppColors.brandPrimary),
                  label: const Text(
                    'Tambah Item',
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

            // Planned Items List
            Expanded(
              child: categoryPlanned.isEmpty
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
                            'Belum ada rencana pengeluaran untuk ${widget.category.name}.',
                            style: AppTypography.bodySecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: _showAddPlannedDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Buat Rencana Pertama'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: categoryPlanned.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (ctx, index) {
                        final item = categoryPlanned[index];
                        return _buildPlannedItemTile(context, item);
                      },
                    ),
            ),
          ] else ...[
            // Section Title & Add Button for Unplanned
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Transaksi Non-Rencana',
                    style: AppTypography.sectionTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton.icon(
                  onPressed: _showAddUnplannedTransactionDialog,
                  icon: const Icon(Icons.add,
                      size: 18, color: AppColors.brandPrimary),
                  label: const Text(
                    'Tambah Transaksi',
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

            // Unplanned Transactions List
            Expanded(
              child: unplannedTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Tidak ada transaksi diluar rencana untuk ${widget.category.name}.',
                            style: AppTypography.bodySecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: _showAddUnplannedTransactionDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Catat Transaksi Baru'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: unplannedTransactions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (ctx, index) {
                        final tx = unplannedTransactions[index];
                        return _buildUnplannedTransactionTile(context, tx);
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlannedItemTile(BuildContext context, PlannedExpense item) {
    final isPaid = item.isPaid;
    final isOverrun = item.isPaidAbovePlanned;

    return CustomCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: isPaid ? AppColors.paidTileBg : AppColors.surfaceWhite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox / Status Icon
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
                color: isPaid
                    ? (isOverrun
                        ? AppColors.warningAmber
                        : AppColors.brandPrimary)
                    : AppColors.surfaceWhite,
                border: Border.all(
                  color: isPaid
                      ? (isOverrun
                          ? AppColors.warningAmber
                          : AppColors.brandPrimary)
                      : AppColors.textMuted,
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

          // Content Title & Amounts
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
                Row(
                  children: [
                    Text(
                      'Rencana: ${CurrencyFormatter.format(item.plannedAmount)}',
                      style: AppTypography.labelStandard,
                    ),
                    if (isPaid && item.actualPaidAmount != null) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '• Dibayar: ${CurrencyFormatter.format(item.actualPaidAmount!)}',
                          style: AppTypography.labelStandard.copyWith(
                            color: isOverrun
                                ? AppColors.warningAmberDark
                                : const Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),

                // Visual Overrun Warning Indicator if actual paid > planned
                if (isOverrun) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warningBadgeBg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.warningAmber),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 12, color: AppColors.warningAmberDark),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            'Di atas rencana (+${CurrencyFormatter.format(item.overrunAmount)})',
                            style: AppTypography.captionBadge.copyWith(
                              color: const Color(0xFFB45309),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Action Button / Popup Menu
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
                    Text('Hapus Rencana',
                        style: TextStyle(color: AppColors.expenseRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnplannedTransactionTile(BuildContext context, Transaction tx) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.surfaceWhite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.expenseBgLight,
              borderRadius: AppRadius.radiusSm,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 20,
              color: AppColors.expenseRed,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: AppTypography.bodyPrimary,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      DateFormat('d MMM yyyy', 'id_ID').format(tx.date),
                      style: AppTypography.labelStandard,
                    ),
                    if (tx.note != null && tx.note!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '• ${tx.note}',
                          style: AppTypography.labelStandard.copyWith(
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(tx.amount),
                style: AppTypography.bodySecondary.copyWith(
                  color: AppColors.expenseRed,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                size: 18, color: AppColors.textMuted),
            onSelected: (val) {
              if (val == 'delete') {
                _confirmDeleteUnplannedTransaction(tx);
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
                    Text('Hapus Transaksi',
                        style: TextStyle(color: AppColors.expenseRed)),
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
