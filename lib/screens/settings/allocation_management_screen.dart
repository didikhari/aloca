import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/hive_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/allocation.dart';
import '../../models/allocation_template.dart';
import '../../models/category.dart';
import '../../providers/period_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/allocation_provider.dart';
import '../../providers/template_provider.dart';
import '../../providers/summary_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_card.dart';
import 'widgets/category_routine_expenses_sheet.dart';
import '../../providers/recurring_expense_provider.dart';

class AllocationManagementScreen extends ConsumerStatefulWidget {
  const AllocationManagementScreen({super.key});

  @override
  ConsumerState<AllocationManagementScreen> createState() =>
      _AllocationManagementScreenState();
}

class _AllocationManagementScreenState
    extends ConsumerState<AllocationManagementScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _methods = {}; // 'percentage', 'fixed', 'remaining'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFields();
    });
  }

  void _initFields() {
    final allocations = ref.read(allocationListProvider);
    final categories = ref.read(categoryListProvider);
    final templates = ref.read(templateListProvider);
    final defaultTemplate = templates.isNotEmpty
        ? templates.firstWhere((t) => t.isDefault, orElse: () => templates.first)
        : null;
    final defaultItems = defaultTemplate != null
        ? HiveService.getTemplateItems(defaultTemplate.id)
        : <AllocationTemplateItem>[];

    for (final cat in categories) {
      final matches = allocations.where((a) => a.categoryId == cat.id);
      final alloc = matches.isNotEmpty ? matches.first : null;

      String method;
      double val;

      if (alloc != null) {
        method = alloc.method;
        val = alloc.value;
      } else {
        final tItem =
            defaultItems.where((i) => i.categoryId == cat.id).firstOrNull;
        if (tItem != null) {
          method = tItem.method;
          val = tItem.value;
        } else {
          method = 'percentage';
          val = 0.0;
        }
      }

      _methods[cat.id] = method;
      final newText = method == 'percentage'
          ? val.toStringAsFixed(0)
          : (method == 'fixed'
              ? CurrencyFormatter.formatNumberOnly(val.toInt())
              : '');
      if (_controllers.containsKey(cat.id)) {
        _controllers[cat.id]!.text = newText;
      } else {
        _controllers[cat.id] = TextEditingController(text: newText);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, int> _calculateLiveAllocations(
      int totalAvailable, List<Category> categories) {
    final liveNominals = <String, int>{};
    int nonRemainingTotal = 0;

    // Pass 1: Calculate fixed and percentage allocations
    for (final cat in categories) {
      final method = _methods[cat.id] ?? 'percentage';
      final text = _controllers[cat.id]?.text ?? '0';
      final val = method == 'fixed'
          ? CurrencyFormatter.parse(text).toDouble()
          : (double.tryParse(text) ?? 0.0);

      int calculatedNominal = 0;
      if (method == 'percentage') {
        calculatedNominal = ((totalAvailable * val) / 100.0).floor();
      } else if (method == 'fixed') {
        calculatedNominal = val.toInt();
      }

      if (method != 'remaining') {
        nonRemainingTotal += calculatedNominal;
        liveNominals[cat.id] = calculatedNominal;
      }
    }

    // Remaining funds available after all non-remaining allocations
    int remainingAvailable = totalAvailable - nonRemainingTotal;
    if (remainingAvailable < 0) {
      remainingAvailable = 0;
    }

    // Pass 2: Assign remaining allocations
    for (final cat in categories) {
      final method = _methods[cat.id] ?? 'percentage';
      if (method == 'remaining') {
        liveNominals[cat.id] = remainingAvailable;
        remainingAvailable = 0;
      }
    }

    return liveNominals;
  }

  @override
  Widget build(BuildContext context) {
    final activePeriod = ref.watch(activePeriodProvider);
    final categories =
        ref.watch(categoryListProvider).where((c) => c.isActive).toList();
    final templates = ref.watch(templateListProvider);
    final summary = ref.watch(monthlySummaryProvider);
    final isMasked = ref.watch(isBalanceMaskedProvider);

    final liveNominals =
        _calculateLiveAllocations(summary.totalAvailable, categories);
    final liveTotalAllocated =
        liveNominals.values.fold<int>(0, (sum, val) => sum + val);
    final liveUnallocated = summary.totalAvailable - liveTotalAllocated;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text(
          'Alokasi: ${activePeriod.displayText}',
          style: AppTypography.headingLarge,
        ),
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Gunakan Template',
            onPressed: () => _showTemplatePicker(templates),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Funds Summary Banner (Live Updated)
              CustomCard(
                backgroundColor: liveUnallocated < 0
                    ? AppColors.expenseRed
                    : AppColors.brandPrimary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Dana Tersedia Bulan Ini',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13),
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
                            ref
                                .read(isBalanceMaskedProvider.notifier)
                                .toggleMask();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isMasked
                          ? 'Rp ••••••••'
                          : CurrencyFormatter.format(summary.totalAvailable),
                      style: AppTypography.displayMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Total Alokasi: ${CurrencyFormatter.format(liveTotalAllocated)}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSmall
                                .copyWith(color: AppColors.textInverse),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            liveUnallocated >= 0
                                ? 'Sisa: ${CurrencyFormatter.format(liveUnallocated)}'
                                : 'Defisit: -${CurrencyFormatter.format(liveUnallocated.abs())}',
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: liveUnallocated >= 0
                                  ? AppColors.textInverse
                                  : const Color(0xFFFEF08A),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (liveUnallocated < 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.radiusSm,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 14, color: AppColors.surfaceWhite),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Alokasi melebihi dana tersedia sebesar ${CurrencyFormatter.format(liveUnallocated.abs())}!',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textInverse,
                                  fontWeight: FontWeight.w600,
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

              const SizedBox(height: AppSpacing.lg),

              const Text(
                'Atur Persentase / Nominal per Kategori',
                style: AppTypography.headingSmall,
              ),

              const SizedBox(height: AppSpacing.md),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final controller =
                      _controllers[cat.id] ??= TextEditingController(text: '0');
                  final method = _methods[cat.id] ??= 'percentage';
                  final liveNominal = liveNominals[cat.id] ?? 0;

                  return CustomCard(
                    padding: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () => _showEditAllocationBottomSheet(
                        cat,
                        summary.totalAvailable,
                      ),
                      borderRadius: AppRadius.radiusLg,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat.name,
                                        style: AppTypography.bodyPrimary,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getMethodLabelText(
                                          method,
                                          controller.text,
                                        ),
                                        style: AppTypography.labelStandard,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(liveNominal),
                                      style: AppTypography.bodyPrimary.copyWith(
                                        color: AppColors.brandPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Ubah',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 14,
                                          color: AppColors.textMuted,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            // Button / Badge to manage routine expenses for this category
                            Consumer(
                              builder: (context, ref, _) {
                                final routineList = ref
                                    .watch(recurringExpenseListProvider)
                                    .where((re) => re.categoryId == cat.id)
                                    .toList();
                                return InkWell(
                                  onTap: () {
                                    CategoryRoutineExpensesSheet.show(
                                      context,
                                      category: cat,
                                    );
                                  },
                                  borderRadius: AppRadius.radiusSm,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: AppColors.chipSubSurface,
                                      borderRadius: AppRadius.radiusSm,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.playlist_add_check,
                                          size: 14,
                                          color: AppColors.brandPrimary,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          routineList.isEmpty
                                              ? '+ Tambah Pengeluaran Rutin'
                                              : '${routineList.length} Pengeluaran Rutin',
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: AppColors.brandPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: AppColors.textInverse,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusLg,
                    ),
                    textStyle: AppTypography.buttonLarge,
                  ),
                  onPressed: _saveAllocations,
                  child: const Text('Simpan Alokasi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplatePicker(List templates) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Allocation Template',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (templates.isEmpty)
                const Text('Belum ada template alokasi tersimpan.')
              else
                ...templates.map((t) {
                  return ListTile(
                    title: Text(t.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref
                          .read(allocationListProvider.notifier)
                          .generateFromTemplate(t);
                      _initFields();
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _saveAllocations() async {
    final activePeriodId = ref.read(activePeriodIdProvider);
    final summary = ref.read(monthlySummaryProvider);
    final categories =
        ref.read(categoryListProvider).where((c) => c.isActive).toList();

    int available = summary.totalAvailable;
    final liveNominals = _calculateLiveAllocations(available, categories);
    final liveTotalAllocated =
        liveNominals.values.fold<int>(0, (sum, val) => sum + val);
    final liveUnallocated = available - liveTotalAllocated;

    if (liveUnallocated < 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Alokasi Melebihi Dana Tersedia'),
          content: Text(
            'Total alokasi yang Anda atur (${CurrencyFormatter.format(liveTotalAllocated)}) melebihi dana tersedia (${CurrencyFormatter.format(available)}) sebesar ${CurrencyFormatter.format(liveUnallocated.abs())}.\n\nApakah Anda yakin ingin tetap menyimpan alokasi ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Sesuaikan'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A884),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Tetap Simpan'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final newAllocations = <Allocation>[];
    const uuid = Uuid();

    for (final cat in categories) {
      final method = _methods[cat.id] ?? 'percentage';
      final text = _controllers[cat.id]?.text ?? '0';
      final val = method == 'fixed'
          ? CurrencyFormatter.parse(text).toDouble()
          : (double.tryParse(text) ?? 0.0);
      final calculatedNominal = liveNominals[cat.id] ?? 0;

      newAllocations.add(Allocation(
        id: 'alloc_${uuid.v4()}',
        periodId: activePeriodId,
        categoryId: cat.id,
        method: method,
        value: val,
        allocatedAmount: calculatedNominal,
      ));
    }

    await ref
        .read(allocationListProvider.notifier)
        .saveAllocations(newAllocations);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alokasi berhasil disimpan!')),
      );
      Navigator.pop(context);
    }
  }

  String _getMethodLabelText(String method, String text) {
    if (method == 'percentage') {
      final val = text.isEmpty ? '0' : text;
      return 'Metode: Persentase ($val%)';
    } else if (method == 'fixed') {
      final val = text.isEmpty ? '0' : text;
      return 'Metode: Nominal (Rp $val)';
    } else if (method == 'remaining') {
      return 'Metode: Otomatis Sisa Dana';
    }
    return '';
  }

  void _showEditAllocationBottomSheet(Category cat, int totalAvailable) {
    String selectedMethod = _methods[cat.id] ?? 'percentage';
    final controller =
        _controllers[cat.id] ??= TextEditingController(text: '0');
    final valController = TextEditingController(text: controller.text);
    final valFocusNode = FocusNode();

    valFocusNode.addListener(() {
      if (valFocusNode.hasFocus) {
        if (valController.text == '0') {
          valController.clear();
        }
      } else {
        if (valController.text.trim().isEmpty) {
          valController.text = '0';
        }
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final valText = valController.text;
            final valNum = selectedMethod == 'fixed'
                ? CurrencyFormatter.parse(valText).toDouble()
                : (double.tryParse(valText) ?? 0.0);

            int estimatedResult = 0;
            if (selectedMethod == 'percentage') {
              estimatedResult = ((totalAvailable * valNum) / 100.0).floor();
            } else if (selectedMethod == 'fixed') {
              estimatedResult = valNum.toInt();
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: AppRadius.radiusSheet,
                ),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                                BorderRadius.circular(AppRadius.handle),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Header title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: const BoxDecoration(
                              color: AppColors.brandTint,
                              borderRadius: AppRadius.radiusMd,
                            ),
                            child: const Icon(
                              Icons.tune_outlined,
                              color: AppColors.brandPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Edit Alokasi: ${cat.name}',
                              style: AppTypography.headingMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Method Selection Chips
                      const Text(
                        'Pilih Metode Alokasi',
                        style: AppTypography.bodySecondary,
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              labelPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              label: const Center(
                                child: Text(
                                  'Persentase (%)',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              selected: selectedMethod == 'percentage',
                              selectedColor: AppColors.brandPrimary,
                              labelStyle: TextStyle(
                                color: selectedMethod == 'percentage'
                                    ? AppColors.textInverse
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              onSelected: (selected) {
                                if (selected && selectedMethod != 'percentage') {
                                  valFocusNode.unfocus();
                                  setSheetState(() {
                                    selectedMethod = 'percentage';
                                    valController.text = '0';
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ChoiceChip(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              labelPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              label: const Center(
                                child: Text(
                                  'Nominal (Rp)',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              selected: selectedMethod == 'fixed',
                              selectedColor: AppColors.brandPrimary,
                              labelStyle: TextStyle(
                                color: selectedMethod == 'fixed'
                                    ? AppColors.textInverse
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              onSelected: (selected) {
                                if (selected && selectedMethod != 'fixed') {
                                  valFocusNode.unfocus();
                                  setSheetState(() {
                                    selectedMethod = 'fixed';
                                    valController.text = '0';
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ChoiceChip(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              labelPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              label: const Center(
                                child: Text(
                                  'Sisa Dana',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              selected: selectedMethod == 'remaining',
                              selectedColor: AppColors.brandPrimary,
                              labelStyle: TextStyle(
                                color: selectedMethod == 'remaining'
                                    ? AppColors.textInverse
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              onSelected: (selected) {
                                if (selected && selectedMethod != 'remaining') {
                                  valFocusNode.unfocus();
                                  setSheetState(() {
                                    selectedMethod = 'remaining';
                                    valController.text = '0';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Value Input Field
                      if (selectedMethod != 'remaining') ...[
                        TextField(
                          controller: valController,
                          focusNode: valFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: selectedMethod == 'fixed'
                              ? [ThousandsSeparatorInputFormatter()]
                              : null,
                          onTap: () {
                            if (valController.text == '0') {
                              valController.clear();
                            }
                          },
                          onChanged: (val) {
                            if (val.length > 1 &&
                                val.startsWith('0') &&
                                !val.startsWith('0.')) {
                              final cleaned = val.replaceFirst(RegExp(r'^0+'), '');
                              final textToSet = cleaned.isEmpty ? '0' : cleaned;
                              valController.value = TextEditingValue(
                                text: textToSet,
                                selection: TextSelection.collapsed(
                                    offset: textToSet.length),
                              );
                            }
                            setSheetState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: selectedMethod == 'percentage'
                                ? 'Nilai Persentase (%)'
                                : 'Nominal Alokasi (Rp)',
                            prefixText:
                                selectedMethod == 'fixed' ? 'Rp ' : null,
                            suffixText:
                                selectedMethod == 'percentage' ? '%' : null,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.chipSubSurface,
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Perkiraan Hasil: ${CurrencyFormatter.format(estimatedResult)}',
                                  style: AppTypography.bodySecondary.copyWith(
                                    color: AppColors.brandPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: const BoxDecoration(
                            color: AppColors.chipSubSurface,
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome,
                                  size: 18, color: AppColors.brandPrimary),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Kategori ini akan otomatis menyerap seluruh sisa dana yang belum dialokasikan oleh kategori lainnya.',
                                  style: AppTypography.labelStandard,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xl),

                      // Action Buttons
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
                                setState(() {
                                  _methods[cat.id] = selectedMethod;
                                  controller.text =
                                      valController.text.trim().isEmpty
                                          ? '0'
                                          : valController.text;
                                });
                                Navigator.pop(ctx);
                              },
                              child: const Text('Simpan Alokasi'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      valFocusNode.dispose();
      valController.dispose();
    });
  }
}
