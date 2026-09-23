import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/hive_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/allocation.dart';
import '../../models/allocation_template.dart';
import '../../models/category.dart';
import '../../providers/allocation_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/period_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_card.dart';
import '../dashboard/dashboard_screen.dart';

class InitialSetupScreen extends ConsumerStatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  ConsumerState<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends ConsumerState<InitialSetupScreen> {
  int _currentStep =
      0; // 0: Period & Balance, 1: Categories, 2: Allocation, 3: Review

  // Step 0: Period & Opening Balance
  DateTime _selectedDate = DateTime.now();
  final _amountController = TextEditingController();

  // Step 2: Allocation State Maps
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _methods = {}; // 'percentage', 'fixed', 'remaining'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAllocationFields();
    });
  }

  void _initAllocationFields() {
    final categories = ref.read(categoryListProvider);
    final allocations = ref.read(allocationListProvider);
    final templates = HiveService.getAllTemplates();
    final defaultTemplate = templates.isNotEmpty
        ? templates.firstWhere((t) => t.isDefault, orElse: () => templates.first)
        : null;
    final defaultItems = defaultTemplate != null
        ? HiveService.getTemplateItems(defaultTemplate.id)
        : <AllocationTemplateItem>[];

    for (final cat in categories) {
      if (!_methods.containsKey(cat.id)) {
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
        _controllers[cat.id] = TextEditingController(
          text: method == 'percentage'
              ? val.toStringAsFixed(0)
              : (method == 'fixed'
                  ? CurrencyFormatter.formatNumberOnly(val.toInt())
                  : ''),
        );
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _openingBalance {
    return CurrencyFormatter.parse(_amountController.text);
  }

  Map<String, int> _calculateLiveAllocations(
      int totalAvailable, List<Category> categories) {
    final liveNominals = <String, int>{};
    int nonRemainingTotal = 0;

    // Pass 1: Fixed and percentage allocations
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

    // Remaining funds
    int remainingAvailable = totalAvailable - nonRemainingTotal;
    if (remainingAvailable < 0) {
      remainingAvailable = 0;
    }

    // Pass 2: Remaining allocation
    for (final cat in categories) {
      final method = _methods[cat.id] ?? 'percentage';
      if (method == 'remaining') {
        liveNominals[cat.id] = remainingAvailable;
        remainingAvailable = 0;
      }
    }

    return liveNominals;
  }

  void _nextStep() {
    if (_currentStep == 0 && _openingBalance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan saldo awal yang valid.')),
      );
      return;
    }

    if (_currentStep == 1) {
      final activeCategories =
          ref.read(categoryListProvider).where((c) => c.isActive).toList();
      if (activeCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Pilih setidaknya 1 kategori aktif untuk melanjutkan.')),
        );
        return;
      }
      _initAllocationFields();
    }

    if (_currentStep == 2) {
      final activeCategories =
          ref.read(categoryListProvider).where((c) => c.isActive).toList();
      for (final cat in activeCategories) {
        final method = _methods[cat.id] ?? 'percentage';
        if (method != 'remaining') {
          final text = _controllers[cat.id]?.text ?? '0';
          final val = method == 'fixed'
              ? CurrencyFormatter.parse(text).toDouble()
              : (double.tryParse(text) ?? 0.0);

          if (val <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Alokasi ${cat.name} belum diatur')),
            );
            return;
          }
        }
      }
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final available = _openingBalance;
    final period = await ref
        .read(periodListProvider.notifier)
        .getOrCreatePeriod(_selectedDate.year, _selectedDate.month);

    await ref
        .read(periodListProvider.notifier)
        .updateInitialOpeningBalance(period.id, available);

    final activeCategories =
        ref.read(categoryListProvider).where((c) => c.isActive).toList();
    final liveNominals = _calculateLiveAllocations(available, activeCategories);

    const uuid = Uuid();
    final newAllocations = <Allocation>[];

    for (final cat in activeCategories) {
      final method = _methods[cat.id] ?? 'percentage';
      final text = _controllers[cat.id]?.text ?? '0';
      final val = method == 'fixed'
          ? CurrencyFormatter.parse(text).toDouble()
          : (double.tryParse(text) ?? 0.0);
      final calculatedNominal = liveNominals[cat.id] ?? 0;

      newAllocations.add(Allocation(
        id: 'alloc_${uuid.v4()}',
        periodId: period.id,
        categoryId: cat.id,
        method: method,
        value: val,
        allocatedAmount: calculatedNominal,
      ));
    }

    await ref
        .read(allocationListProvider.notifier)
        .saveAllocations(newAllocations);
    ref.read(activePeriodIdProvider.notifier).state = period.id;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 0) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppColors.pageBackground,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: _buildStepPeriodAndBalance(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: _buildCurrentStepWidget(),
              ),
            ),

            // Footer Control Buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(top: BorderSide(color: AppColors.dividerBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusLg,
                        ),
                      ),
                      onPressed: _prevStep,
                      child: const Text('Kembali'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: AppColors.textInverse,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusLg,
                        ),
                        textStyle: AppTypography.buttonLarge,
                      ),
                      onPressed: _nextStep,
                      child: Text(
                        _currentStep == 3
                            ? 'Selesai'
                            : 'Lanjut',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return _buildStepPeriodAndBalance();
      case 1:
        return _buildStepCategories();
      case 2:
        return _buildStepAllocation();
      case 3:
        return _buildStepReview();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 0: Select Period & Opening Balance Combined (Matches design mock 100%)
  Widget _buildStepPeriodAndBalance() {
    String formattedDate;
    try {
      formattedDate = DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);
    } catch (_) {
      formattedDate = '${_selectedDate.month} ${_selectedDate.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxxl),

        // Centered Wallet Icon Badge
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: AppColors.brandTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.brandPrimary,
              size: 38,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Centered Title
        Center(
          child: Text(
            'Selamat Datang di Aloca!',
            textAlign: TextAlign.center,
            style: AppTypography.displayLarge
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Centered Subtitle
        Center(
          child: Text(
            'Mulai kelola keuangan Anda dengan mudah',
            textAlign: TextAlign.center,
            style: AppTypography.bodyPrimary
                .copyWith(color: AppColors.textSecondary),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // Section 1: Period Selection Label
        const Text('Periode Finansial Pertama',
            style: AppTypography.headingSmall),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          borderRadius: AppRadius.radiusLg,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.dividerBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: AppTypography.bodyPrimary.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Section 2: Opening Balance Label
        const Text('Saldo Awal', style: AppTypography.headingSmall),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsSeparatorInputFormatter()],
          decoration: InputDecoration(
            hintText: 'Contoh: 500000',
            hintStyle: AppTypography.bodyPrimary.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.normal,
            ),
            prefixText: 'Rp  ',
            prefixStyle: AppTypography.bodyPrimary.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.brandPrimary,
            ),
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: 14),
            border: const OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.dividerBorder),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.dividerBorder),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(color: AppColors.brandPrimary, width: 2),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // Submit CTA Button
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
            onPressed: _nextStep,
            child: const Text('Mulai Mengelola Keuangan'),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  // STEP 1: Categories
  Widget _buildStepCategories() {
    final categories = ref.watch(categoryListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        // Centered Wallet Icon Badge
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: AppColors.brandTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.brandPrimary,
              size: 38,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori Keuangan', style: AppTypography.headingLarge),
                  SizedBox(height: 2),
                  Text(
                    'Aktifkan kategori yang ingin Anda gunakan.',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _showAddCategoryDialog,
              icon: const Icon(Icons.add,
                  size: 18, color: AppColors.brandPrimary),
              label: const Text(
                'Tambah',
                style: TextStyle(
                    color: AppColors.brandPrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return CustomCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.brandPrimary,
                title: Text(cat.name, style: AppTypography.bodyPrimary),
                subtitle: Text(
                  cat.isActive ? 'Aktif' : 'Non-aktif',
                  style: AppTypography.labelSmall.copyWith(
                    color: cat.isActive
                        ? AppColors.incomeGreen
                        : AppColors.textMuted,
                  ),
                ),
                value: cat.isActive,
                onChanged: (_) {
                  ref
                      .read(categoryListProvider.notifier)
                      .toggleCategoryActive(cat.id);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Kategori Baru'),
        content: TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama Kategori',
            hintText: 'Misal: Tabungan, Hobi, Investasi',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: AppColors.textInverse,
            ),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                const uuid = Uuid();
                final newCat = Category(
                  id: 'cat_${uuid.v4()}',
                  name: name,
                  colorHex: '#00A884',
                  iconName: 'category',
                );
                ref.read(categoryListProvider.notifier).addCategory(newCat);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  // STEP 2: Allocation
  Widget _buildStepAllocation() {
    final available = _openingBalance;
    final activeCategories =
        ref.watch(categoryListProvider).where((c) => c.isActive).toList();
    final liveNominals = _calculateLiveAllocations(available, activeCategories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        // Centered Wallet Icon Badge
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: AppColors.brandTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.brandPrimary,
              size: 38,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        const Text('Atur Alokasi Kategori', style: AppTypography.headingSmall),
        const SizedBox(height: AppSpacing.sm),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeCategories.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final cat = activeCategories[index];
            final controller =
                _controllers[cat.id] ??= TextEditingController(text: '0');
            final method = _methods[cat.id] ??= 'percentage';
            final liveNominal = liveNominals[cat.id] ?? 0;

            return CustomCard(
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: () => _showEditAllocationBottomSheet(cat, available),
                borderRadius: AppRadius.radiusLg,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat.name, style: AppTypography.bodyPrimary),
                            const SizedBox(height: 2),
                            Text(
                              _getMethodLabelText(method, controller.text),
                              style: AppTypography.labelStandard,
                            ),
                          ],
                        ),
                      ),
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
                            children: [
                              Text('Ubah',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted)),
                              Icon(Icons.chevron_right,
                                  size: 14, color: AppColors.textMuted),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getMethodLabelText(String method, String text) {
    if (method == 'percentage') {
      final val = text.isEmpty ? '0' : text;
      return 'Persentase ($val%)';
    } else if (method == 'fixed') {
      final val = text.isEmpty ? '0' : text;
      return 'Nominal (Rp $val)';
    } else if (method == 'remaining') {
      return 'Sisa Dana Otomatis';
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
                      Text('Edit Alokasi: ${cat.name}',
                          style: AppTypography.headingMedium),
                      const SizedBox(height: AppSpacing.xl),
                      const Text('Pilih Metode Alokasi',
                          style: AppTypography.bodySecondary),
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
                                child: Text('Persentase (%)',
                                    overflow: TextOverflow.ellipsis),
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
                                child: Text('Nominal (Rp)',
                                    overflow: TextOverflow.ellipsis),
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
                                child: Text('Sisa Dana',
                                    overflow: TextOverflow.ellipsis),
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
                          child: Text(
                            'Perkiraan Hasil: ${CurrencyFormatter.format(estimatedResult)}',
                            style: AppTypography.bodySecondary.copyWith(
                              color: AppColors.brandPrimary,
                              fontWeight: FontWeight.bold,
                            ),
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
                          child: const Text(
                            'Kategori ini otomatis menyerap sisa dana yang belum dialokasikan.',
                            style: AppTypography.labelStandard,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
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
                              child: const Text('Simpan'),
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

  // STEP 3: Review
  Widget _buildStepReview() {
    final available = _openingBalance;
    final activeCategories =
        ref.watch(categoryListProvider).where((c) => c.isActive).toList();
    final liveNominals = _calculateLiveAllocations(available, activeCategories);

    String formattedDate;
    try {
      formattedDate = DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);
    } catch (_) {
      formattedDate = '${_selectedDate.month} ${_selectedDate.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        // Centered Wallet Icon Badge
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: AppColors.brandTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.brandPrimary,
              size: 38,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        const Text('Ringkasan Penyiapan Keuangan',
            style: AppTypography.headingLarge),
        const SizedBox(height: 4),
        const Text(
          'Periksa kembali seluruh pengaturan finansial awal Anda sebelum disimpan.',
          style: AppTypography.labelSmall,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Summary Card
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('Periode Finansial', formattedDate),
              const Divider(height: AppSpacing.lg),
              _buildReviewRow(
                  'Saldo Awal', CurrencyFormatter.format(available)),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        Text('Rincian Alokasi Kategori (${activeCategories.length})',
            style: AppTypography.headingSmall),
        const SizedBox(height: AppSpacing.sm),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeCategories.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final cat = activeCategories[index];
            final method = _methods[cat.id] ?? 'percentage';
            final text = _controllers[cat.id]?.text ?? '0';
            final nominal = liveNominals[cat.id] ?? 0;

            return CustomCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name, style: AppTypography.bodyPrimary),
                        Text(_getMethodLabelText(method, text),
                            style: AppTypography.labelSmall),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(nominal),
                    style: AppTypography.bodyPrimary.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySecondary),
        Text(
          value,
          style: AppTypography.bodyPrimary.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
