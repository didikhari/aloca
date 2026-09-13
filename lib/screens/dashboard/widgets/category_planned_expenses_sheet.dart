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
              decoration: const InputDecoration(
                labelText: 'Nama Tagihan / Rencana',
                hintText: 'Misal: Listrik PLN, Internet, Kos',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
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
              backgroundColor: const Color(0xFF00A884),
              foregroundColor: Colors.white,
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
              decoration: const InputDecoration(
                labelText: 'Keterangan Transaksi',
                hintText: 'Misal: Beli Kopi, Tambal Ban, Jajanan',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
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
              backgroundColor: const Color(0xFF00A884),
              foregroundColor: Colors.white,
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

                ref.read(transactionListProvider.notifier).addTransaction(newTx);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Transaksi ${newTx.description} (${CurrencyFormatter.format(amount)}) berhasil ditambahkan.',
                    ),
                    backgroundColor: const Color(0xFF00A884),
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
            const Icon(Icons.payment, color: Color(0xFF00A884)),
            const SizedBox(width: 8),
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
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 8),
            const Text(
              'Jika nominal aktual melebihi rencana, aplikasi akan memberikan indikator "Di atas rencana".',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
              backgroundColor: const Color(0xFF00A884),
              foregroundColor: Colors.white,
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
                    backgroundColor: const Color(0xFF00A884),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(transactionListProvider.notifier).deleteTransaction(tx.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaksi ${tx.description} berhasil dihapus.'),
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

    final allTransactions = ref.watch(transactionListProvider);
    final categoryTransactions = allTransactions
        .where((tx) => tx.categoryId == widget.category.id && tx.type == 'Expense')
        .toList();

    final paidTxIds = categoryPlanned
        .map((pe) => pe.paidTransactionId)
        .where((id) => id != null)
        .toSet();

    final unplannedTransactions = categoryTransactions
        .where((tx) => !paidTxIds.contains(tx.id))
        .toList();
    unplannedTransactions.sort((a, b) => b.date.compareTo(a.date));

    final paidCount = categoryPlanned.where((pe) => pe.isPaid).length;
    final totalCount = categoryPlanned.length;
    final totalPlannedNominal =
        categoryPlanned.fold<int>(0, (sum, pe) => sum + pe.plannedAmount);
    final totalUnplannedNominal =
        unplannedTransactions.fold<int>(0, (sum, tx) => sum + tx.amount);
    final remainingBudget = widget.allocatedAmount - widget.actualExpense;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Header Card
          CustomCard(
            backgroundColor: const Color(0xFFF8FAFC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x1A00A884),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.category_outlined,
                        color: Color(0xFF00A884),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: paidCount == totalCount && totalCount > 0
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$paidCount/$totalCount Lunas',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: paidCount == totalCount && totalCount > 0
                              ? const Color(0xFF166534)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alokasi Anggaran',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(widget.allocatedAmount),
                            style: const TextStyle(
                              fontSize: 12,
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
                            'Total Rencana',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(totalPlannedNominal),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Non-Rencana',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(totalUnplannedNominal),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
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
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyFormatter.format(remainingBudget),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: remainingBudget >= 0
                                  ? const Color(0xFF00A884)
                                  : const Color(0xFFEF4444),
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

          const SizedBox(height: 12),

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
                          ? const Color(0xFF00A884)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Rencana (${categoryPlanned.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _selectedTab == 0
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedTab == 1
                          ? const Color(0xFF00A884)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Diluar Rencana (${unplannedTransactions.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _selectedTab == 1
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tab Content
          if (_selectedTab == 0) ...[
            // Section Title & Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Daftar Rencana Pengeluaran',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _showAddPlannedDialog,
                  icon: const Icon(Icons.add, size: 18, color: Color(0xFF00A884)),
                  label: const Text(
                    'Tambah Item',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00A884),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

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
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada rencana pengeluaran untuk ${widget.category.name}.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
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
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _showAddUnplannedTransactionDialog,
                  icon: const Icon(Icons.add, size: 18, color: Color(0xFF00A884)),
                  label: const Text(
                    'Tambah Transaksi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00A884),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

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
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada transaksi diluar rencana untuk ${widget.category.name}.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
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
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(12),
      backgroundColor: isPaid ? const Color(0xFFF0FDF4) : Colors.white,
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
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF00A884))
                    : Colors.white,
                border: Border.all(
                  color: isPaid
                      ? (isOverrun
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF00A884))
                      : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: isPaid
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),

          const SizedBox(width: 12),

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
                        ? const Color(0xFF64748B)
                        : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Rencana: ${CurrencyFormatter.format(item.plannedAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (isPaid && item.actualPaidAmount != null) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '• Dibayar: ${CurrencyFormatter.format(item.actualPaidAmount!)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isOverrun
                                ? const Color(0xFFD97706)
                                : const Color(0xFF166534),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),

                // Visual Overrun Warning Indicator if actual paid > planned
                if (isOverrun) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 12, color: Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Di atas rencana (+${CurrencyFormatter.format(item.overrunAmount)})',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
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

          const SizedBox(width: 8),

          // Action Button / Popup Menu
          if (!isPaid)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A884),
                foregroundColor: Colors.white,
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
              icon: const Icon(Icons.undo, size: 18, color: Color(0xFF64748B)),
              tooltip: 'Batalkan Pembayaran',
              onPressed: () {
                ref
                    .read(plannedExpenseListProvider.notifier)
                    .unpayPlannedExpense(item);
              },
            ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
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
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Rencana', style: TextStyle(color: Colors.red)),
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
      padding: const EdgeInsets.all(12),
      backgroundColor: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 20,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      DateFormat('d MMM yyyy', 'id_ID').format(tx.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (tx.note != null && tx.note!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '• ${tx.note}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
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
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(tx.amount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
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
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Transaksi', style: TextStyle(color: Colors.red)),
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
