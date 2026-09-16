import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/financial_period.dart';
import '../../providers/period_provider.dart';
import '../../providers/summary_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/status_badge.dart';
import '../transaction/quick_add_transaction_screen.dart';
import '../transaction/transactions_list_screen.dart';
import '../settings/allocation_management_screen.dart';
import '../settings/categories_screen.dart';
import '../settings/backup_restore_screen.dart';
import '../reports/monthly_report_screen.dart';
import 'widgets/category_planned_expenses_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePeriod = ref.watch(activePeriodProvider);
    final periods = ref.watch(periodListProvider);
    final summary = ref.watch(monthlySummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Aloca',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Color(0xFF0F172A)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF0F172A)),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector Bar
              _buildPeriodSelectorBar(context, ref, activePeriod, periods),

              const SizedBox(height: 16),

              // Financial Position Summary Card
              _buildSummaryCard(summary),

              const SizedBox(height: 16),

              // Unallocated or Overallocated Warning Banner
              if (summary.unallocatedAmount < 0) ...[
                _buildOverallocatedBanner(summary.unallocatedAmount.abs()),
                const SizedBox(height: 16),
              ] else if (summary.unallocatedAmount > 0 && summary.totalAvailable > 0) ...[
                _buildUnallocatedBanner(summary.unallocatedAmount),
                const SizedBox(height: 16),
              ],

              // Category Budget Status Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Alokasi & Progress Kategori',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
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
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.tune, size: 16, color: Color(0xFF00A884)),
                          SizedBox(width: 4),
                          Text(
                            'Kelola',
                            style: TextStyle(
                              color: Color(0xFF00A884),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Dynamic Category Cards List
              if (summary.categoryStatuses.isEmpty) ...[
                CustomCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.category_outlined, size: 36, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text('Belum ada alokasi kategori untuk bulan ini.'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A884),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AllocationManagementScreen(),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        backgroundColor: const Color(0xFF00A884),
        foregroundColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                const Icon(Icons.calendar_today, size: 18, color: Color(0xFF00A884)),
                const SizedBox(width: 8),
                Text(
                  activePeriod.displayText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
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

  Widget _buildSummaryCard(MonthlySummary summary) {
    final isMasked = ref.watch(isBalanceMaskedProvider);

    return CustomCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Available Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00A884), Color(0xFF008B74)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Dana Tersedia (Total Available)',
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
                      tooltip: isMasked ? 'Tampilkan Nominal' : 'Sembunyikan Nominal',
                      onPressed: () {
                        ref.read(isBalanceMaskedProvider.notifier).toggleMask();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isMasked
                      ? 'Rp ••••••••'
                      : CurrencyFormatter.format(summary.totalAvailable),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(color: Colors.white30, height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Opening: ${isMasked ? "Rp ••••••••" : CurrencyFormatter.format(summary.openingBalance)}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Income: ${isMasked ? "Rp ••••••••" : CurrencyFormatter.format(summary.totalIncome)}',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildSummaryStatItem(
                  'Total Dialokasi',
                  CurrencyFormatter.format(summary.totalAllocated),
                  const Color(0xFF3B82F6),
                ),
              ),
              Expanded(
                child: _buildSummaryStatItem(
                  'Pengeluaran Aktual',
                  CurrencyFormatter.format(summary.totalActualExpenses),
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildSummaryStatItem(
                  'Sisa Anggaran Alokasi',
                  CurrencyFormatter.format(summary.remainingBudget),
                  summary.remainingBudget >= 0 ? const Color(0xFF10B981) : Colors.red,
                ),
              ),
              Expanded(
                child: _buildSummaryStatItem(
                  'Closing Balance',
                  CurrencyFormatter.format(summary.closingBalance),
                  const Color(0xFF0F172A),
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
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildUnallocatedBanner(int unallocatedAmount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Anda masih memiliki sisa dana belum dialokasikan sebesar ${CurrencyFormatter.format(unallocatedAmount)}.',
              style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallocatedBanner(int overallocatedAmount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Total alokasi Anda melebihi dana tersedia sebesar ${CurrencyFormatter.format(overallocatedAmount)}! Harap sesuaikan alokasi.',
              style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12, fontWeight: FontWeight.w600),
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
      cardColor = const Color(0xFF00A884);
    }

    return CustomCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        CategoryPlannedExpensesSheet.show(
          context,
          category: cs.category,
          allocatedAmount: cs.allocated,
          actualExpense: cs.actual,
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cs.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: cs.status),
            ],
          ),

          const SizedBox(height: 8),

          CustomProgressBar(
            ratio: cs.usageRatio,
            height: 6.0,
            color: cs.status == 'Over Budget' ? Colors.red : cardColor,
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
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sisa: ${CurrencyFormatter.format(cs.remaining)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.remaining >= 0 ? const Color(0xFF10B981) : Colors.red,
                ),
              ),
            ],
          ),

          if (cs.totalPlannedItems > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.paidItemsCount == cs.totalPlannedItems
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(6),
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
                        : const Color(0xFFB45309),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rencana: ${cs.paidItemsCount}/${cs.totalPlannedItems} Lunas (${CurrencyFormatter.format(cs.totalPlannedAmount)})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.paidItemsCount == cs.totalPlannedItems
                            ? const Color(0xFF166534)
                            : const Color(0xFFB45309),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Color(0xFF94A3B8),
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
            decoration: BoxDecoration(color: Color(0xFF00A884)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Aloca',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
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
                MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
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
                MaterialPageRoute(builder: (_) => const AllocationManagementScreen()),
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
