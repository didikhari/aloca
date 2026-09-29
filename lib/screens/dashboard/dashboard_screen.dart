import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/financial_period.dart';
import '../../models/income.dart';
import '../../providers/income_provider.dart';
import '../../providers/period_provider.dart';
import '../../providers/summary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/progress_bar.dart';
import '../transaction/transactions_list_screen.dart';
import '../settings/allocation_management_screen.dart';
import '../settings/categories_screen.dart';
import '../settings/backup_restore_screen.dart';
import '../reports/monthly_report_screen.dart';
import 'monthly_category_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePeriod = ref.watch(activePeriodProvider);
    final periods = ref.watch(periodListProvider);
    final summary = ref.watch(monthlySummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        title: const Text(
          'Aloca',
          style: AppTypography.headingLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined,
                color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector Bar
              _buildPeriodSelectorBar(context, ref, activePeriod, periods),

              const SizedBox(height: AppSpacing.lg),

              // Financial Position Summary Card
              _buildSummaryCard(summary, ref, context),

              const SizedBox(height: AppSpacing.lg),

              // Unallocated or Overallocated Warning Banner
              if (summary.unallocatedAmount < 0) ...[
                _buildOverallocatedBanner(summary.unallocatedAmount.abs()),
                const SizedBox(height: AppSpacing.lg),
              ] else if (summary.unallocatedAmount > 0 &&
                  summary.totalAvailable > 0) ...[
                _buildUnallocatedBanner(summary.unallocatedAmount),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Category Budget Status Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Alokasi & Progress Kategori',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sectionTitle,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllocationManagementScreen(),
                        ),
                      );
                    },
                    borderRadius: AppRadius.radiusSm,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tune,
                              size: 16, color: AppColors.brandPrimary),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Kelola',
                            style: AppTypography.bodySecondary.copyWith(
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Dynamic Category Cards List
              if (summary.categoryStatuses.isEmpty) ...[
                CustomCard(
                  child: Center(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        children: [
                          const Icon(Icons.category_outlined,
                              size: 36, color: AppColors.textMuted),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Belum ada alokasi kategori untuk bulan ini.',
                            style: AppTypography.bodyPrimary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPrimary,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AllocationManagementScreen(),
                                ),
                              );
                            },
                            child: const Text('Buat Alokasi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: summary.categoryStatuses.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final cs = summary.categoryStatuses[index];
                    return _buildCategoryCard(cs, context);
                  },
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelectorBar(
    BuildContext context,
    WidgetRef ref,
    FinancialPeriod activePeriod,
    List<FinancialPeriod> periods,
  ) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () async {
              int prevMonth = activePeriod.month - 1;
              int prevYear = activePeriod.year;
              if (prevMonth < 1) {
                prevMonth = 12;
                prevYear -= 1;
              }
              final p = await ref
                  .read(periodListProvider.notifier)
                  .getOrCreatePeriod(prevYear, prevMonth);
              ref.read(activePeriodIdProvider.notifier).state = p.id;
            },
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(activePeriod.year, activePeriod.month, 1),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                final p = await ref
                    .read(periodListProvider.notifier)
                    .getOrCreatePeriod(picked.year, picked.month);
                ref.read(activePeriodIdProvider.notifier).state = p.id;
              }
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: AppColors.brandPrimary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  activePeriod.displayText,
                  style: AppTypography.headingSmall,
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () async {
              int nextMonth = activePeriod.month + 1;
              int nextYear = activePeriod.year;
              if (nextMonth > 12) {
                nextMonth = 1;
                nextYear += 1;
              }
              final p = await ref
                  .read(periodListProvider.notifier)
                  .getOrCreatePeriod(nextYear, nextMonth);
              ref.read(activePeriodIdProvider.notifier).state = p.id;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      MonthlySummary summary, WidgetRef ref, BuildContext context) {
    final isMasked = ref.watch(isBalanceMaskedProvider);

    return CustomCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: AppColors.surfaceWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Available Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.brandPrimary, AppColors.brandDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Tersedia',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isMasked
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: isMasked
                          ? 'Tampilkan Nominal'
                          : 'Sembunyikan Nominal',
                      onPressed: () {
                        ref
                            .read(isBalanceMaskedProvider.notifier)
                            .toggleMask();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        isMasked
                            ? 'Rp ••••••••'
                            : CurrencyFormatter.format(summary.totalAvailable),
                        style: AppTypography.displaySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    InkWell(
                      onTap: () => _showAddIncomeBottomSheet(context, ref),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildSummaryStatItem(
                  'Total Dialokasi',
                  CurrencyFormatter.format(summary.totalAllocated),
                  AppColors.infoBlue,
                ),
              ),
              Expanded(
                child: _buildSummaryStatItem(
                  'Pengeluaran',
                  CurrencyFormatter.format(summary.totalActualExpenses),
                  AppColors.expenseRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _buildSummaryStatItem(
                  'Sisa Anggaran',
                  CurrencyFormatter.format(summary.remainingBudget),
                  summary.remainingBudget >= 0
                      ? AppColors.incomeGreen
                      : AppColors.expenseRed,
                ),
              ),
              Expanded(
                child: _buildSummaryStatItem(
                  'Saldo Akhir',
                  CurrencyFormatter.format(summary.closingBalance),
                  AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddIncomeBottomSheet(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSheet,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            width: MediaQuery.of(ctx).size.width,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.dividerBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: const BoxDecoration(
                          color: AppColors.successBgLight,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: const Icon(
                          Icons.arrow_downward,
                          color: AppColors.incomeGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Text(
                          'Tambah Pemasukan',
                          style: AppTypography.headingMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Sumber / Deskripsi Pemasukan',
                      hintText: 'Misal: Gaji Bulan Ini, Bonus, Freelance',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Nominal Pemasukan (Rp)',
                      hintText: '0',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
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
                        setSheetState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Pemasukan',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMMM yyyy', 'id_ID')
                              .format(selectedDate)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusLg,
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandPrimary,
                            foregroundColor: AppColors.textInverse,
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusLg,
                            ),
                            textStyle: AppTypography.buttonLarge,
                          ),
                          onPressed: () {
                            final desc = descriptionController.text.trim();
                            final amount = CurrencyFormatter.parse(
                                amountController.text);

                            if (amount > 0) {
                              final activePeriodId =
                                  ref.read(activePeriodIdProvider);
                              const uuid = Uuid();
                              final newIncome = Income(
                                id: 'inc_${uuid.v4()}',
                                periodId: activePeriodId,
                                date: selectedDate,
                                description: desc.isNotEmpty
                                    ? desc
                                    : 'Pendapatan Tambahan',
                                amount: amount,
                                type: 'Other',
                              );

                              ref
                                  .read(incomeListProvider.notifier)
                                  .addIncome(newIncome);

                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Pemasukan ${CurrencyFormatter.format(amount)} berhasil ditambahkan!',
                                  ),
                                  backgroundColor: AppColors.brandPrimary,
                                ),
                              );
                            }
                          },
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySecondary.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildUnallocatedBanner(int unallocatedAmount) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.infoBgLight,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.infoBlue.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.infoBlueDark),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Anda masih memiliki sisa dana belum dialokasikan sebesar ${CurrencyFormatter.format(unallocatedAmount)}.',
              style: AppTypography.labelStandard
                  .copyWith(color: AppColors.infoBlueDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallocatedBanner(int overallocatedAmount) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.expenseBgLight,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.expenseRed.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.expenseRedDark),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Total alokasi Anda melebihi dana tersedia sebesar ${CurrencyFormatter.format(overallocatedAmount)}.',
              style: AppTypography.labelStandard
                  .copyWith(color: AppColors.expenseRedDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryBudgetStatus cs, BuildContext context) {
    Color color;
    try {
      color = Color(int.parse(
          'FF${cs.category.colorHex.replaceAll('#', '')}',
          radix: 16));
    } catch (_) {
      color = AppColors.brandPrimary;
    }

    final isPaidFull = cs.paidItemsCount == cs.totalPlannedItems &&
        cs.totalPlannedItems > 0;

    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MonthlyCategoryDetail(
              category: cs.category,
              allocatedAmount: cs.allocated,
              actualExpense: cs.actual,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Category Name, Status Badge, Chevron
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  cs.category.name,
                  style: AppTypography.headingSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (cs.totalPlannedItems > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPaidFull
                        ? AppColors.successBgLight
                        : AppColors.warningBadgeBg,
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: Text(
                    '${cs.paidItemsCount}/${cs.totalPlannedItems} Lunas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPaidFull
                          ? const Color(0xFF166534)
                          : const Color(0xFF92400E),
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Row 2: Progress Bar
          CustomProgressBar(
            ratio: cs.allocated > 0 ? cs.actual / cs.allocated : 0,
            color: cs.actual > cs.allocated
                ? AppColors.expenseRed
                : AppColors.brandPrimary,
          ),

          const SizedBox(height: AppSpacing.md),

          // Row 3: Financial Figures
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alokasi', style: AppTypography.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(cs.allocated),
                    style: AppTypography.labelStandard,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Terpakai', style: AppTypography.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(cs.actual),
                    style: AppTypography.labelStandard
                        .copyWith(color: AppColors.expenseRed),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Sisa Anggaran',
                      style: AppTypography.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(cs.remaining),
                    style: AppTypography.labelStandard.copyWith(
                      color: cs.remaining >= 0
                          ? AppColors.brandPrimary
                          : AppColors.expenseRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.brandPrimary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Aloca',
                  style: TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Plan → Allocate → Track',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Riwayat Transaksi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TransactionsListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart_outline),
            title: const Text('Pengaturan Alokasi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AllocationManagementScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Kelola Kategori'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Laporan Bulanan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup & Restore Excel'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
