import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/allocation.dart';
import '../../models/category.dart';
import '../../providers/period_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/allocation_provider.dart';
import '../../providers/template_provider.dart';
import '../../providers/summary_provider.dart';
import '../../widgets/custom_card.dart';
import '../dashboard/widgets/category_planned_expenses_sheet.dart';
import '../../providers/planned_expense_provider.dart';

class AllocationManagementScreen extends ConsumerStatefulWidget {
  const AllocationManagementScreen({super.key});

  @override
  ConsumerState<AllocationManagementScreen> createState() => _AllocationManagementScreenState();
}

class _AllocationManagementScreenState extends ConsumerState<AllocationManagementScreen> {
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

    for (final cat in categories) {
      final matches = allocations.where((a) => a.categoryId == cat.id);
      final alloc = matches.isNotEmpty ? matches.first : null;

      final method = alloc?.method ?? 'percentage';
      final val = alloc?.value ?? 0.0;

      _methods[cat.id] = method;
      _controllers[cat.id] = TextEditingController(
        text: method == 'percentage'
            ? val.toStringAsFixed(0)
            : (method == 'fixed' ? CurrencyFormatter.formatNumberOnly(val.toInt()) : ''),
      );
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

  Map<String, int> _calculateLiveAllocations(int totalAvailable, List<Category> categories) {
    final liveNominals = <String, int>{};
    int remainingCounter = totalAvailable;

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
      } else if (method == 'remaining') {
        calculatedNominal = remainingCounter > 0 ? remainingCounter : 0;
      }

      remainingCounter -= calculatedNominal;
      liveNominals[cat.id] = calculatedNominal;
    }
    return liveNominals;
  }

  @override
  Widget build(BuildContext context) {
    final activePeriod = ref.watch(activePeriodProvider);
    final categories = ref.watch(categoryListProvider).where((c) => c.isActive).toList();
    final templates = ref.watch(templateListProvider);
    final summary = ref.watch(monthlySummaryProvider);
    final isMasked = ref.watch(isBalanceMaskedProvider);

    final liveNominals = _calculateLiveAllocations(summary.totalAvailable, categories);
    final liveTotalAllocated = liveNominals.values.fold<int>(0, (sum, val) => sum + val);
    final liveUnallocated = summary.totalAvailable - liveTotalAllocated;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Alokasi: ${activePeriod.displayText}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Funds Summary Banner (Live Updated)
              CustomCard(
                backgroundColor: liveUnallocated < 0
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF00A884),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Dana Tersedia Bulan Ini',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
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
                          tooltip: isMasked ? 'Tampilkan Nominal' : 'Sembunyikan Nominal',
                          onPressed: () {
                            ref.read(isBalanceMaskedProvider.notifier).toggleMask();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMasked
                          ? 'Rp ••••••••'
                          : CurrencyFormatter.format(summary.totalAvailable),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Total Alokasi: ${CurrencyFormatter.format(liveTotalAllocated)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            liveUnallocated >= 0
                                ? 'Sisa: ${CurrencyFormatter.format(liveUnallocated)}'
                                : 'Defisit: -${CurrencyFormatter.format(liveUnallocated.abs())}',
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: liveUnallocated >= 0 ? Colors.white : const Color(0xFFFEF08A),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (liveUnallocated < 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Alokasi melebihi dana tersedia sebesar ${CurrencyFormatter.format(liveUnallocated.abs())}!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
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

              const SizedBox(height: 16),

              const Text(
                'Atur Persentase / Nominal per Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final controller = _controllers[cat.id] ??= TextEditingController(text: '0');
                  final method = _methods[cat.id] ??= 'percentage';
                  final liveNominal = liveNominals[cat.id] ?? 0;

                  return CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Hasil: ${CurrencyFormatter.format(liveNominal)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF00A884),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Method Dropdown
                            DropdownButton<String>(
                              value: method,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'percentage', child: Text('%')),
                                DropdownMenuItem(value: 'fixed', child: Text('Rp')),
                                DropdownMenuItem(value: 'remaining', child: Text('Sisa')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _methods[cat.id] = val;
                                  });
                                }
                              },
                            ),

                            const SizedBox(width: 8),

                            // Value Input
                            if (method != 'remaining')
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: method == 'fixed'
                                      ? [ThousandsSeparatorInputFormatter()]
                                      : null,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    suffixText: method == 'percentage' ? '%' : '',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              )
                            else
                              const Expanded(
                                child: Text(
                                  'Otomatis Sisa',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Button / Badge to manage planned expenses for this category
                        Consumer(
                          builder: (context, ref, _) {
                            final plannedList = ref
                                .watch(plannedExpenseListProvider)
                                .where((pe) => pe.categoryId == cat.id)
                                .toList();
                            return InkWell(
                              onTap: () {
                                CategoryPlannedExpensesSheet.show(
                                  context,
                                  category: cat,
                                  allocatedAmount: liveNominal,
                                  actualExpense: 0,
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.playlist_add_check,
                                      size: 14,
                                      color: Color(0xFF00A884),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      plannedList.isEmpty
                                          ? '+ Tambah Rencana Tagihan'
                                          : '${plannedList.length} Rencana Tagihan',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF00A884),
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
                  );
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A884),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveAllocations,
                  child: const Text(
                    'Simpan Alokasi',
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
    final categories = ref.read(categoryListProvider).where((c) => c.isActive).toList();

    int available = summary.totalAvailable;
    final liveNominals = _calculateLiveAllocations(available, categories);
    final liveTotalAllocated = liveNominals.values.fold<int>(0, (sum, val) => sum + val);
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

    await ref.read(allocationListProvider.notifier).saveAllocations(newAllocations);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alokasi berhasil disimpan!')),
      );
      Navigator.pop(context);
    }
  }
}
