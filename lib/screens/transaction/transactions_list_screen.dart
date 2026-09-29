import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/income.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/period_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
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
                          return _SlidableIncomeTile(
                            key: ValueKey(item.id),
                            income: item,
                            onDelete: () => _confirmDeleteIncome(item),
                          );
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

  Future<void> _confirmDeleteIncome(Income income) async {
    final activePeriodId = ref.read(activePeriodIdProvider);
    final isCurrentPeriod = income.periodId == activePeriodId;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCurrentPeriod
            ? 'Hapus Pemasukan'
            : 'Hapus Pemasukan Bulan Lalu'),
        content: Text(
          isCurrentPeriod
              ? 'Apakah Anda yakin ingin menghapus pemasukan "${income.description}" sebesar ${CurrencyFormatter.format(income.amount)}?'
              : 'Menghapus "${income.description}" sebesar ${CurrencyFormatter.format(income.amount)} dari periode sebelumnya (${income.periodId}) akan mengurangi Saldo Awal dan Total Tersedia bulan ini.\n\nApakah Anda yakin ingin melanjutkan koreksi ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: AppColors.textInverse,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isCurrentPeriod ? 'Hapus' : 'Hapus & Koreksi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(incomeListProvider.notifier).deleteIncome(income.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentPeriod
                  ? 'Pemasukan berhasil dihapus.'
                  : 'Pemasukan bulan lalu berhasil dihapus dan saldo awal telah dikoreksi.',
            ),
            backgroundColor: AppColors.brandPrimary,
          ),
        );
      }
    }
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

  Widget _buildExpenseItem(Transaction tx, String categoryName) {
    String title = tx.description;
    String? note = tx.note;

    // Backward compatibility for legacy transactions where note was merged into description with parentheses: "Title (Note)"
    if ((note == null || note.trim().isEmpty) && title.contains('(') && title.endsWith(')')) {
      final openParenIndex = title.lastIndexOf('(');
      if (openParenIndex > 0) {
        note = title.substring(openParenIndex + 1, title.length - 1).trim();
        title = title.substring(0, openParenIndex).trim();
      }
    }

    final hasNote = note != null && note.trim().isNotEmpty;
    final formattedDate = DateFormat('d MMM yyyy', 'id_ID').format(tx.date);

    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column 1: Icon (merged next to top row and dedicated note row)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.expenseBgLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: AppColors.expenseRed,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Content Block (Column 2 & 3 top row, Note bottom row)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 2: Nama Pengeluaran & Kategori
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headingSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelStandard,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Column 3: Nominal Transaksi & Tanggal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '-${CurrencyFormatter.format(tx.amount)}',
                          style: AppTypography.bodyPrimary.copyWith(
                            color: AppColors.expenseRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: AppTypography.labelStandard,
                        ),
                      ],
                    ),
                  ],
                ),

                // Dedicated row for description/note if exists
                if (hasNote) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    note,
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidableIncomeTile extends StatefulWidget {
  final Income income;
  final VoidCallback onDelete;

  const _SlidableIncomeTile({
    super.key,
    required this.income,
    required this.onDelete,
  });

  @override
  State<_SlidableIncomeTile> createState() => _SlidableIncomeTileState();
}

class _SlidableIncomeTileState extends State<_SlidableIncomeTile> {
  double _dragOffset = 0.0;
  static const double _actionWidth = 80.0;

  void _close() {
    if (mounted) setState(() => _dragOffset = 0);
  }

  void _open() {
    if (mounted) setState(() => _dragOffset = -_actionWidth);
  }

  @override
  Widget build(BuildContext context) {
    final isRevealed = _dragOffset < -10;
    final formattedDate =
        DateFormat('d MMM yyyy', 'id_ID').format(widget.income.date);

    return Stack(
      children: [
        // Background Red Delete Button
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: _actionWidth,
              decoration: const BoxDecoration(
                color: AppColors.expenseRed,
                borderRadius: AppRadius.radiusCard,
              ),
              child: InkWell(
                onTap: () {
                  _close();
                  widget.onDelete();
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.textInverse,
                      size: 22,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: AppColors.textInverse,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Foreground Sliding Card
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dragOffset += details.primaryDelta!;
              if (_dragOffset > 0) _dragOffset = 0;
              if (_dragOffset < -_actionWidth) _dragOffset = -_actionWidth;
            });
          },
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < -200 ||
                _dragOffset < -_actionWidth / 2) {
              _open();
            } else {
              _close();
            }
          },
          child: Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: CustomCard(
              onTap: () {
                if (isRevealed) _close();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column 1: Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.successBgLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: AppColors.incomeGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Content Block (Column 2 & 3 top row)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Column 2: Nama & Jenis Pendapatan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.income.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.headingSmall,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Pendapatan',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelStandard,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),

                        // Column 3: Nominal Transaksi & Tanggal
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${CurrencyFormatter.format(widget.income.amount)}',
                              style: AppTypography.bodyPrimary.copyWith(
                                color: AppColors.incomeGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formattedDate,
                              style: AppTypography.labelStandard,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Slidable affordance cue (Right grey drag handle indicator)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF94A3B8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
