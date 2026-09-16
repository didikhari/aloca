import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/period_provider.dart';
import '../../providers/summary_provider.dart';
import '../../widgets/custom_card.dart';

class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePeriod = ref.watch(activePeriodProvider);
    final summary = ref.watch(monthlySummaryProvider);
    final isMasked = ref.watch(isBalanceMaskedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Laporan: ${activePeriod.displayText}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isMasked
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF64748B),
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
                    const SizedBox(height: 12),
                    _buildReportRow('Opening Balance (Bawaan Bulan Lalu)', summary.openingBalance, isMasked: isMasked),
                    _buildReportRow('+ Total Income Bulan Ini', summary.totalIncome, color: Colors.green, isMasked: isMasked),
                    const Divider(),
                    _buildReportRow('= Total Available Funds', summary.totalAvailable, isBold: true, isMasked: isMasked),
                    _buildReportRow('- Total Pengeluaran Aktual', summary.totalActualExpenses, color: Colors.red, isMasked: isMasked),
                    const Divider(),
                    _buildReportRow('= Closing Balance (Saldo Akhir)', summary.closingBalance, isBold: true, color: const Color(0xFF00A884), isMasked: isMasked),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category Budget vs Actual Variance Table
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Laporan Variansi Anggaran per Kategori',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16,
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
                              DataCell(Text(CurrencyFormatter.format(stat.allocated))),
                              DataCell(Text(CurrencyFormatter.format(stat.actual))),
                              DataCell(
                                Text(
                                  CurrencyFormatter.format(stat.remaining),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: stat.remaining >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: stat.remaining >= 0
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    stat.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: stat.remaining >= 0
                                          ? const Color(0xFF166534)
                                          : const Color(0xFF991B1B),
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
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isMasked ? 'Rp ••••••••' : CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
