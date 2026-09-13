import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/income.dart';
import '../../models/transaction.dart';
import '../../providers/period_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';

class QuickAddTransactionScreen extends ConsumerStatefulWidget {
  const QuickAddTransactionScreen({super.key});

  @override
  ConsumerState<QuickAddTransactionScreen> createState() => _QuickAddTransactionScreenState();
}

class _QuickAddTransactionScreenState extends ConsumerState<QuickAddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Expense'; // 'Expense' or 'Income'
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider).where((c) => c.isActive).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedType == 'Expense' ? 'Catat Pengeluaran' : 'Catat Pendapatan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Segmented type toggle (Expense vs Income)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Pengeluaran')),
                      selected: _selectedType == 'Expense',
                      selectedColor: const Color(0xFFEF4444).withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: _selectedType == 'Expense' ? const Color(0xFFEF4444) : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = 'Expense');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Pendapatan')),
                      selected: _selectedType == 'Income',
                      selectedColor: const Color(0xFF00A884).withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: _selectedType == 'Income' ? const Color(0xFF00A884) : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = 'Income');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amount Input
              const Text(
                'Nominal (Rp)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                autofocus: true,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A884),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                'Deskripsi / Catatan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: _selectedType == 'Expense' ? 'Contoh: Belanja Bulanan' : 'Contoh: Gaji Bulanan',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              if (_selectedType == 'Expense') ...[
                const SizedBox(height: 16),
                const Text(
                  'Kategori',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  hint: const Text('Pilih Kategori'),
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryId = val;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'Expense' ? const Color(0xFFEF4444) : const Color(0xFF00A884),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveTransaction,
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount <= 0) return;

    final activePeriodId = ref.read(activePeriodIdProvider);
    final uuid = const Uuid();
    final description = _descriptionController.text.trim().isEmpty
        ? (_selectedType == 'Expense' ? 'Pengeluaran' : 'Pendapatan')
        : _descriptionController.text.trim();

    if (_selectedType == 'Expense') {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih kategori pengeluaran.')),
        );
        return;
      }
      final transaction = Transaction(
        id: 'tx_${uuid.v4()}',
        periodId: activePeriodId,
        date: DateTime.now(),
        description: description,
        categoryId: _selectedCategoryId!,
        amount: amount,
        type: 'Expense',
      );
      ref.read(transactionListProvider.notifier).addTransaction(transaction);
    } else {
      final income = Income(
        id: 'inc_${uuid.v4()}',
        periodId: activePeriodId,
        date: DateTime.now(),
        description: description,
        amount: amount,
        type: 'Salary',
      );
      ref.read(incomeListProvider.notifier).addIncome(income);
    }

    Navigator.pop(context);
  }
}
