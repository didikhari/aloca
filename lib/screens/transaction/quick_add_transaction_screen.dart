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
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class QuickAddTransactionScreen extends ConsumerStatefulWidget {
  const QuickAddTransactionScreen({super.key});

  @override
  ConsumerState<QuickAddTransactionScreen> createState() =>
      _QuickAddTransactionScreenState();
}

class _QuickAddTransactionScreenState
    extends ConsumerState<QuickAddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Expense'; // 'Expense' or 'Income'
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(categoryListProvider).where((c) => c.isActive).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: AppRadius.radiusSheet,
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
                    _selectedType == 'Expense'
                        ? 'Catat Pengeluaran'
                        : 'Catat Pendapatan',
                    style: AppTypography.headingMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Segmented type toggle (Expense vs Income)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Pengeluaran')),
                      selected: _selectedType == 'Expense',
                      selectedColor: AppColors.expenseBgLight,
                      labelStyle: TextStyle(
                        color: _selectedType == 'Expense'
                            ? AppColors.expenseRed
                            : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = 'Expense');
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Pendapatan')),
                      selected: _selectedType == 'Income',
                      selectedColor: AppColors.brandTint,
                      labelStyle: TextStyle(
                        color: _selectedType == 'Income'
                            ? AppColors.brandPrimary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = 'Income');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Amount Input
              const Text(
                'Nominal (Rp)',
                style: AppTypography.bodyPrimary,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                autofocus: true,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandPrimary,
                  ),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Description
              const Text(
                'Deskripsi / Catatan',
                style: AppTypography.bodyPrimary,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: _selectedType == 'Expense'
                      ? 'Contoh: Belanja Bulanan'
                      : 'Contoh: Gaji Bulanan',
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusLg,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              if (_selectedType == 'Expense') ...[
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Kategori',
                  style: AppTypography.bodyPrimary,
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
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusLg,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'Expense'
                        ? AppColors.expenseRed
                        : AppColors.brandPrimary,
                    foregroundColor: AppColors.textInverse,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusLg,
                    ),
                    textStyle: AppTypography.buttonLarge,
                  ),
                  onPressed: _saveTransaction,
                  child: const Text('Simpan'),
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
    const uuid = Uuid();
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
