import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/income.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_card.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;

  const TransactionsListScreen({
    super.key,
    this.initialCategoryId,
  });

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState
    extends ConsumerState<TransactionsListScreen> {
  int _selectedFilterTab = 0; // 0: Semua, 1: Pendapatan, 2: Pengeluaran
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryId != null) {
      _selectedCategoryId = widget.initialCategoryId;
      _selectedFilterTab = 2; // Default to Expense tab if category selected
    }
  }

  @override
  Widget build(BuildContext context) {
    final incomes = ref.watch(incomeListProvider);
    final expenses = ref.watch(transactionListProvider);
    final categories = ref.watch(categoryListProvider);

    final selectedCategory = _selectedCategoryId != null
        ? categories.firstWhere(
            (c) => c.id == _selectedCategoryId,
            orElse: () => null as dynamic,
          )
        : null;

    // Filter expenses by selected category if any
    final filteredExpenses = _selectedCategoryId != null
        ? expenses.where((t) => t.categoryId == _selectedCategoryId).toList()
        : expenses;

    // Merge into single list sorted by date desc
    final allItems = <dynamic>[];
    if (_selectedCategoryId == null &&
        (_selectedFilterTab == 0 || _selectedFilterTab == 1)) {
      allItems.addAll(incomes);
    }
    if (_selectedFilterTab == 0 || _selectedFilterTab == 2) {
      allItems.addAll(filteredExpenses);
    }
    allItems.sort((a, b) {
      final dateA = a is Income ? a.date : (a as Transaction).date;
      final dateB = b is Income ? b.date : (b as Transaction).date;
      return dateB.compareTo(dateA);
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(
          selectedCategory != null
              ? 'Riwayat: ${selectedCategory.name}'
              : 'Riwayat Transaksi',
          style: AppTypography.headingLarge,
        ),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tab Bar
            Container(
              color: AppColors.surfaceWhite,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    _buildTabChip('Semua', 0),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTabChip('Pendapatan', 1),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTabChip('Pengeluaran', 2),
                  ],
                ),
              ),
            ),

            // Active Category Filter Indicator
            if (_selectedCategoryId != null) ...[
              Container(
                color: AppColors.infoBgLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list,
                              size: 16, color: AppColors.infoBlueDark),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Filter: ${selectedCategory?.name ?? 'Kategori'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelStandard.copyWith(
                                color: AppColors.infoBlueDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.xs),
                        child: Row(
                          children: [
                            Text(
                              'Hapus Filter',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.infoBlueDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Icon(Icons.close,
                                size: 16, color: AppColors.infoBlueDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            Expanded(
              child: allItems.isEmpty
                  ? Center(
                      child: Text(
                        _selectedCategoryId != null
                            ? 'Belum ada transaksi pengeluaran untuk kategori ${selectedCategory?.name ?? ''} pada bulan ini.'
                            : 'Belum ada transaksi pada periode ini.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySecondary,
                      ),
                    )
                  : ListView.separated(
                      padding: AppSpacing.screenPadding,
                      itemCount: allItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = allItems[index];
                        if (item is Income) {
                          return _buildIncomeItem(item);
                        } else {
                          final tx = item as Transaction;
                          final catMatches =
                              categories.where((c) => c.id == tx.categoryId);
                          final category =
                              catMatches.isNotEmpty ? catMatches.first : null;
                          return _buildExpenseItem(
                              tx, category?.name ?? 'Category');
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int index) {
    final isSelected = _selectedFilterTab == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.brandTint,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.brandPrimary : AppColors.textMuted,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilterTab = index);
      },
    );
  }

  Widget _buildIncomeItem(Income income) {
    return CustomCard(
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.successBgLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_downward,
                      color: AppColors.incomeGreen, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        income.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headingSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pendapatan • ${DateFormat('d MMM yyyy', 'id_ID').format(income.date)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelStandard,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '+${CurrencyFormatter.format(income.amount)}',
            style: AppTypography.bodyPrimary.copyWith(
              color: AppColors.incomeGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.textMuted, size: 18),
            onPressed: () {
              ref.read(incomeListProvider.notifier).deleteIncome(income.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Transaction tx, String categoryName) {
    return CustomCard(
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.expenseBgLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward,
                      color: AppColors.expenseRed, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headingSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$categoryName • ${DateFormat('d MMM yyyy', 'id_ID').format(tx.date)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelStandard,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '-${CurrencyFormatter.format(tx.amount)}',
            style: AppTypography.bodyPrimary.copyWith(
              color: AppColors.expenseRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.textMuted, size: 18),
            onPressed: () {
              ref
                  .read(transactionListProvider.notifier)
                  .deleteTransaction(tx.id);
            },
          ),
        ],
      ),
    );
  }
}
