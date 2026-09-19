import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/period_provider.dart';
import '../../providers/summary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_card.dart';

class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePeriod = ref.watch(activePeriodProvider);
    final summary = ref.watch(monthlySummaryProvider);
    final isMasked = ref.watch(isBalanceMaskedProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(
          'Laporan: ${activePeriod.displayText}',
          style: AppTypography.headingLarge,
        ),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Continuous Financial Position Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Posisi Finansial Berkelanjutan',
                            style: AppTypography.headingMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isMasked
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
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
                    const SizedBox(height: AppSpacing.md),
                    _buildReportRow('Opening Balance (Bawaan Bulan Lalu)',
                        summary.openingBalance,
                        isMasked: isMasked),
                    _buildReportRow(
                        '+ Total Income Bulan Ini', summary.totalIncome,
                        color: AppColors.incomeGreen, isMasked: isMasked),
                    const Divider(),
                    _buildReportRow(
                        '= Total Available Funds', summary.totalAvailable,
                        isBold: true, isMasked: isMasked),
                    _buildReportRow('- Total Pengeluaran Aktual',
                        summary.totalActualExpenses,
                        color: AppColors.expenseRed, isMasked: isMasked),
                    const Divider(),
                    _buildReportRow('= Closing Balance (Saldo Akhir)',
                        summary.closingBalance,
                        isBold: true,
                        color: AppColors.brandPrimary,
                        isMasked: isMasked),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Category Budget vs Actual Variance Table
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laporan Variansi Anggaran per Kategori',
                      style: AppTypography.headingMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: AppSpacing.lg,
                        columns: const [
                          DataColumn(label: Text('Kategori')),
                          DataColumn(label: Text('Alokasi')),
                          DataColumn(label: Text('Aktual')),
                          DataColumn(label: Text('Sisa')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: summary.categoryStatuses.map((stat) {
                          return DataRow(
                            cells: [
                              DataCell(Text(stat.category.name)),
                              DataCell(Text(
                                  CurrencyFormatter.format(stat.allocated))),
                              DataCell(
                                  Text(CurrencyFormatter.format(stat.actual))),
                              DataCell(
                                Text(
                                  CurrencyFormatter.format(stat.remaining),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: stat.remaining >= 0
                                        ? AppColors.incomeGreen
                                        : AppColors.expenseRed,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: stat.remaining >= 0
                                        ? AppColors.successBgLight
                                        : AppColors.expenseBgLight,
                                    borderRadius: AppRadius.radiusLg,
                                  ),
                                  child: Text(
                                    stat.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: stat.remaining >= 0
                                          ? const Color(0xFF166534)
                                          : AppColors.expenseRedDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, int amount,
      {bool isBold = false, Color? color, bool isMasked = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isMasked ? 'Rp ••••••••' : CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
