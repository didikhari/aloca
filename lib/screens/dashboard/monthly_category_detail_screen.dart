import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/category.dart';
import '../../models/monthly_expense.dart';
import '../../providers/planned_expense_provider.dart';
import '../../providers/summary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_card.dart';

class MonthlyCategoryDetail extends ConsumerStatefulWidget {
  final Category category;
  final int allocatedAmount;
  final int actualExpense;

  const MonthlyCategoryDetail({
    super.key,
    required this.category,
    required this.allocatedAmount,
    required this.actualExpense,
  });

  @override
  ConsumerState<MonthlyCategoryDetail> createState() =>
      _MonthlyCategoryDetailState();
}

class _MonthlyCategoryDetailState
    extends ConsumerState<MonthlyCategoryDetail> {
  void _showAddExpenseBottomSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    bool isPaid = false;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSheet,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                  Text(
                    'Tambah Pengeluaran: ${widget.category.name}',
                    style: AppTypography.headingMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pengeluaran',
                      hintText: 'Misal: Pulsa, Token Listrik, Belanja',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sudah Dibayar?'),
                    value: isPaid,
                    onChanged: (val) {
                      setSheetState(() {
                        isPaid = val;
                      });
                    },
                  ),
                  if (isPaid) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsSeparatorInputFormatter()],
                      decoration: const InputDecoration(
                        labelText: 'Nominal Dibayar (Rp)',
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
                          labelText: 'Tanggal Pembayaran',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: noteController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Pembayaran',
                        hintText: 'Misal: Dibayarkan dengan GoPay, Tokopedia',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
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
                            final title = titleController.text.trim();
                            final amount =
                                CurrencyFormatter.parse(amountController.text);

                            if (title.isNotEmpty) {
                              ref
                                  .read(plannedExpenseListProvider.notifier)
                                  .addPlannedExpense(
                                    categoryId: widget.category.id,
                                    title: title,
                                    isPaid: isPaid,
                                    amount: isPaid ? amount : null,
                                    paymentDate: isPaid ? selectedDate : null,
                                    note: isPaid ? noteController.text.trim() : null,
                                  );
                              Navigator.pop(ctx);
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

  void _showPayBottomSheet(MonthlyExpense item) {
    final amountController = TextEditingController(
      text: item.amount != null && item.amount! > 0
          ? CurrencyFormatter.formatNumberOnly(item.amount!)
          : '',
    );
    final noteController = TextEditingController(text: item.note ?? '');
    DateTime selectedDate = item.paymentDate ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSheet,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                      const Icon(Icons.payment, color: AppColors.brandPrimary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Bayar: ${item.title}',
                          style: AppTypography.headingMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Nominal yang Dibayarkan (Rp)',
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
                        labelText: 'Tanggal Pembayaran',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: noteController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Pembayaran',
                      hintText: 'Misal: Dibayarkan dengan GoPay, Tokopedia',
                      border: OutlineInputBorder(),
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
                            final actualAmount =
                                CurrencyFormatter.parse(amountController.text);

                            if (actualAmount > 0) {
                              ref
                                  .read(plannedExpenseListProvider.notifier)
                                  .payPlannedExpense(
                                    item: item,
                                    actualPaidAmount: actualAmount,
                                    paymentDate: selectedDate,
                                    note: noteController.text.trim(),
                                  );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item.title} sebesar ${CurrencyFormatter.format(actualAmount)} berhasil dibayarkan!',
                                  ),
                                  backgroundColor: AppColors.brandPrimary,
                                ),
                              );
                            }
                          },
                          child: const Text('Konfirmasi Bayar'),
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

  Future<bool?> _confirmDeleteExpense(MonthlyExpense item) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: AppColors.textInverse,
            ),
            onPressed: () {
              Navigator.pop(ctx, true);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(plannedExpenseListProvider.notifier)
                    .deletePlannedExpense(item.id);
              });
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allMonthlyExpenses = ref.watch(plannedExpenseListProvider);
    final categoryExpenses = allMonthlyExpenses
        .where((me) => me.categoryId == widget.category.id)
        .toList();
    categoryExpenses
        .sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    final paidCount = categoryExpenses.where((me) => me.isPaid).length;
    final totalCount = categoryExpenses.length;

    final monthlySummary = ref.watch(monthlySummaryProvider);
    final catStatusList = monthlySummary.categoryStatuses
        .where((cs) => cs.category.id == widget.category.id);
    final catStatus = catStatusList.isNotEmpty ? catStatusList.first : null;
    final allocatedAmount = catStatus?.allocated ?? widget.allocatedAmount;
    final actualExpense = catStatus?.actual ?? widget.actualExpense;
    final remainingBudget =
        catStatus?.remaining ?? (allocatedAmount - actualExpense);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: AppTypography.headingLarge,
        ),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header Card
              CustomCard(
                backgroundColor: AppColors.surfaceWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: const BoxDecoration(
                            color: AppColors.brandTint,
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: const Icon(
                            Icons.category_outlined,
                            color: AppColors.brandPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.category.name,
                            style: AppTypography.headingMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: paidCount == totalCount && totalCount > 0
                                ? AppColors.successBgLight
                                : AppColors.warningBadgeBg,
                            borderRadius: AppRadius.radiusLg,
                          ),
                          child: Text(
                            '$paidCount/$totalCount Lunas',
                            style: AppTypography.labelStandard.copyWith(
                              color: paidCount == totalCount && totalCount > 0
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF92400E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Alokasi Anggaran',
                                style: AppTypography.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                CurrencyFormatter.format(allocatedAmount),
                                style: AppTypography.labelStandard.copyWith(
                                  color: AppColors.textPrimary,
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
                                'Sudah Dibayar',
                                style: AppTypography.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                CurrencyFormatter.format(actualExpense),
                                style: AppTypography.labelStandard.copyWith(
                                  color: AppColors.expenseRed,
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
                                'Sisa Anggaran',
                                style: AppTypography.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                CurrencyFormatter.format(remainingBudget),
                                style: AppTypography.labelStandard.copyWith(
                                  color: remainingBudget >= 0
                                      ? AppColors.brandPrimary
                                      : AppColors.expenseRed,
                                  fontWeight: FontWeight.bold,
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

              const SizedBox(height: AppSpacing.md),

              // Section Title & Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Daftar Pengeluaran',
                      style: AppTypography.sectionTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: _showAddExpenseBottomSheet,
                    icon: const Icon(Icons.add,
                        size: 18, color: AppColors.brandPrimary),
                    label: const Text(
                      'Tambah Pengeluaran',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Expenses List
              Expanded(
                child: categoryExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checklist_rtl_outlined,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Belum ada pengeluaran untuk ${widget.category.name}.',
                              style: AppTypography.bodySecondary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            OutlinedButton.icon(
                              onPressed: _showAddExpenseBottomSheet,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Tambah Pengeluaran'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: categoryExpenses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (ctx, index) {
                          final item = categoryExpenses[index];
                          return _SlidableExpenseTile(
                            key: ValueKey(item.id),
                            item: item,
                            onTap: () {
                              if (item.isPaid) {
                                _showExpenseOptionsBottomSheet(item);
                              } else {
                                _showPayBottomSheet(item);
                              }
                            },
                            onDelete: () {
                              _confirmDeleteExpense(item);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpenseOptionsBottomSheet(MonthlyExpense item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSheet,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                Text(
                  item.title,
                  style: AppTypography.headingMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.isPaid && item.amount != null
                      ? 'Status: Lunas • ${CurrencyFormatter.format(item.amount!)}${item.paymentDate != null ? " (${DateFormat('d MMM yyyy', 'id_ID').format(item.paymentDate!)})" : ""}'
                      : 'Status: Belum Dibayar',
                  style: AppTypography.bodySecondary,
                ),
                if (item.isPaid && item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Catatan: ${item.note}',
                    style: AppTypography.bodySecondary.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                if (item.isPaid)
                  ListTile(
                    leading: const Icon(Icons.undo, color: AppColors.brandPrimary),
                    title: const Text('Batalkan Pembayaran'),
                    subtitle: const Text('Ubah status pengeluaran kembali menjadi Belum Dibayar'),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pop(ctx);
                      ref
                          .read(plannedExpenseListProvider.notifier)
                          .unpayPlannedExpense(item);
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.payment, color: AppColors.brandPrimary),
                    title: const Text('Bayar Pengeluaran'),
                    subtitle: const Text('Catat nominal dan tanggal pembayaran'),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pop(ctx);
                      _showPayBottomSheet(item);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.expenseRed),
                  title: const Text(
                    'Hapus Pengeluaran',
                    style: TextStyle(color: AppColors.expenseRed),
                  ),
                  subtitle: const Text('Hapus pengeluaran ini secara permanen'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(ctx);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _confirmDeleteExpense(item);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _SlidableExpenseTile extends StatefulWidget {
  final MonthlyExpense item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SlidableExpenseTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_SlidableExpenseTile> createState() => _SlidableExpenseTileState();
}

class _SlidableExpenseTileState extends State<_SlidableExpenseTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragOffset = 0.0;
  static const double _actionWidth = 84.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _dragOffset = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _animation = Tween<double>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward(from: 0.0);
  }

  void _close() {
    _animateTo(0.0);
  }

  void _open() {
    _animateTo(-_actionWidth);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isPaid = item.isPaid;
    final isRevealed = _dragOffset < -10;

    return ClipRRect(
      borderRadius: AppRadius.radiusCard,
      child: Stack(
        children: [
          // Background Red Delete Button
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: _actionWidth,
            child: Material(
              color: AppColors.expenseRed,
              child: InkWell(
                onTap: () {
                  _close();
                  widget.onDelete();
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.textInverse,
                      size: 22,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: AppColors.textInverse,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Foreground Sliding Card
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragOffset += details.primaryDelta!;
                if (_dragOffset > 0) _dragOffset = 0;
                if (_dragOffset < -_actionWidth) _dragOffset = -_actionWidth;
              });
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < -200 || _dragOffset < -_actionWidth / 2) {
                _open();
              } else {
                _close();
              }
            },
            child: Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: CustomCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: isPaid ? AppColors.paidTileBg : AppColors.surfaceWhite,
                onTap: () {
                  if (isRevealed) {
                    _close();
                  } else {
                    widget.onTap();
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status Checkbox
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPaid ? AppColors.brandPrimary : AppColors.surfaceWhite,
                        border: Border.all(
                          color: isPaid ? AppColors.brandPrimary : AppColors.textMuted,
                          width: 2,
                        ),
                      ),
                      child: isPaid
                          ? const Icon(Icons.check,
                              size: 16, color: AppColors.textInverse)
                          : null,
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // Title & Amount
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isPaid
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          if (isPaid && item.amount != null) ...[
                            Text(
                              'Sudah Dibayar: ${CurrencyFormatter.format(item.amount!)}${item.paymentDate != null ? " • ${DateFormat('d MMM', 'id_ID').format(item.paymentDate!)}" : ""}',
                              style: AppTypography.labelStandard.copyWith(
                                color: const Color(0xFF166534),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.note != null && item.note!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2, right: 4),
                                    child: Icon(
                                      Icons.notes,
                                      size: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.note!,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ] else
                            Text(
                              'Belum Dibayar',
                              style: AppTypography.labelStandard.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    // Action Option Hint Chevron
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
