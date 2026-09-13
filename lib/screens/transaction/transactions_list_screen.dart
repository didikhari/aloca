import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/income.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_card.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;

  const TransactionsListScreen({
    super.key,
    this.initialCategoryId,
  });

  @override
  ConsumerState<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends ConsumerState<TransactionsListScreen> {
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
    if (_selectedCategoryId == null && (_selectedFilterTab == 0 || _selectedFilterTab == 1)) {
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          selectedCategory != null
              ? 'Riwayat: ${selectedCategory.name}'
              : 'Riwayat Transaksi',
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tab Bar
            Container(
              color: Colors.white,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTabChip('Semua', 0),
                    const SizedBox(width: 8),
                    _buildTabChip('Pendapatan', 1),
                    const SizedBox(width: 8),
                    _buildTabChip('Pengeluaran', 2),
                  ],
                ),
              ),
            ),

            // Active Category Filter Indicator
            if (_selectedCategoryId != null) ...[
              Container(
                color: const Color(0xFFEFF6FF),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, size: 16, color: Color(0xFF2563EB)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Filter: ${selectedCategory?.name ?? 'Kategori'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Text(
                              'Hapus Filter',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.close, size: 16, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            Expanded(
              child: allItems.isEmpty
                  ? Center(
                      child: Text(
                        _selectedCategoryId != null
                            ? 'Belum ada transaksi pengeluaran untuk kategori ${selectedCategory?.name ?? ''} pada bulan ini.'
                            : 'Belum ada transaksi pada periode ini.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: allItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = allItems[index];
                        if (item is Income) {
                          return _buildIncomeItem(item);
                        } else {
                          final tx = item as Transaction;
                          final catMatches = categories.where((c) => c.id == tx.categoryId);
                          final category = catMatches.isNotEmpty ? catMatches.first : null;
                          return _buildExpenseItem(tx, category?.name ?? 'Category');
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
      selectedColor: const Color(0xFF00A884).withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF00A884) : Colors.grey,
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_downward, color: Color(0xFF10B981), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        income.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pendapatan • ${DateFormat('d MMM yyyy', 'id_ID').format(income.date)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${CurrencyFormatter.format(income.amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF10B981),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward, color: Color(0xFFEF4444), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$categoryName • ${DateFormat('d MMM yyyy', 'id_ID').format(tx.date)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '-${CurrencyFormatter.format(tx.amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFFEF4444),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
            onPressed: () {
              ref.read(transactionListProvider.notifier).deleteTransaction(tx.id);
            },
          ),
        ],
      ),
    );
  }
}
