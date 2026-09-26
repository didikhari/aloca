import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/financial_period.dart';
import '../../providers/period_provider.dart';
import '../../providers/summary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/status_badge.dart';
import '../transaction/quick_add_transaction_screen.dart';
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
              _buildSummaryCard(summary, ref),

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

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.textInverse,
        onPressed: () {
          _showAddTransactionDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
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

  Widget _buildSummaryCard(MonthlySummary summary, WidgetRef ref) {
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
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
                        ref.read(isBalanceMaskedProvider.notifier).toggleMask();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isMasked
                      ? 'Rp ••••••••'
                      : CurrencyFormatter.format(summary.totalAvailable),
                  style: AppTypography.displaySmall,
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
              'Total alokasi Anda melebihi dana tersedia sebesar ${CurrencyFormatter.format(overallocatedAmount)}! Harap sesuaikan alokasi.',
              style: AppTypography.labelStandard.copyWith(
                color: AppColors.expenseRedDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryBudgetStatus cs, BuildContext context) {
    Color cardColor;
    try {
      final hex = cs.category.colorHex.replaceAll('#', '');
      cardColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      cardColor = AppColors.brandPrimary;
    }

    return CustomCard(
      padding: const EdgeInsets.all(AppSpacing.md),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        cs.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySecondary.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(status: cs.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomProgressBar(
            ratio: cs.usageRatio,
            height: 6.0,
            color:
                cs.status == 'Over Budget' ? AppColors.expenseRed : cardColor,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Terpakai: ${CurrencyFormatter.format(cs.actual)} / ${CurrencyFormatter.format(cs.allocated)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Sisa: ${CurrencyFormatter.format(cs.remaining)}',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.remaining >= 0
                      ? AppColors.incomeGreen
                      : AppColors.expenseRed,
                ),
              ),
            ],
          ),
          if (cs.totalPlannedItems > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cs.paidItemsCount == cs.totalPlannedItems
                    ? AppColors.paidTileBg
                    : AppColors.warningBgLight,
                borderRadius: AppRadius.radiusSm,
                border: Border.all(
                  color: cs.paidItemsCount == cs.totalPlannedItems
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    cs.paidItemsCount == cs.totalPlannedItems
                        ? Icons.check_circle_outline
                        : Icons.pending_actions_outlined,
                    size: 14,
                    color: cs.paidItemsCount == cs.totalPlannedItems
                        ? const Color(0xFF166534)
                        : AppColors.warningAmberDark,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rencana: ${cs.paidItemsCount}/${cs.totalPlannedItems} Lunas (${CurrencyFormatter.format(cs.totalPlannedAmount)})',
                      style: AppTypography.labelSmall.copyWith(
                        color: cs.paidItemsCount == cs.totalPlannedItems
                            ? const Color(0xFF166534)
                            : AppColors.warningAmberDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
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

  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickAddTransactionScreen(),
    );
  }
}
