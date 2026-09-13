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
                    const Text(
                      'Posisi Finansial Berkelanjutan (Continuous Position)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildReportRow('Opening Balance (Bawaan Bulan Lalu)', summary.openingBalance),
                    _buildReportRow('+ Total Income Bulan Ini', summary.totalIncome, color: Colors.green),
                    const Divider(),
                    _buildReportRow('= Total Available Funds', summary.totalAvailable, isBold: true),
                    _buildReportRow('- Total Pengeluaran Aktual', summary.totalActualExpenses, color: Colors.red),
                    const Divider(),
                    _buildReportRow('= Closing Balance (Saldo Akhir)', summary.closingBalance, isBold: true, color: const Color(0xFF00A884)),
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
                      'Budget vs Actual Variance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.5),
                        2: FlexColumnWidth(1.5),
                      },
                      children: [
                        const TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('Alokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('Aktual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        ...summary.categoryStatuses.map((cs) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(cs.category.name, style: const TextStyle(fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(CurrencyFormatter.formatShort(cs.allocated), style: const TextStyle(fontSize: 12)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  CurrencyFormatter.formatShort(cs.actual),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.status == 'Over Budget' ? Colors.red : Colors.black,
                                    fontWeight: cs.status == 'Over Budget' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
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

  Widget _buildReportRow(String label, int amount, {bool isBold = false, Color? color}) {
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
            CurrencyFormatter.format(amount),
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
