import 'package:hive_flutter/hive_flutter.dart';
import '../../models/financial_period.dart';
import '../../models/income.dart';
import '../../models/category.dart';
import '../../models/allocation_template.dart';
import '../../models/allocation.dart';
import '../../models/transaction.dart';
import '../../models/planned_expense.dart';

class HiveService {
  static const String periodsBoxName = 'financial_periods';
  static const String incomesBoxName = 'incomes';
  static const String categoriesBoxName = 'categories';
  static const String templatesBoxName = 'allocation_templates';
  static const String templateItemsBoxName = 'template_items';
  static const String allocationsBoxName = 'allocations';
  static const String transactionsBoxName = 'transactions';
  static const String plannedExpensesBoxName = 'planned_expenses';
  static const String settingsBoxName = 'app_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    await Hive.openBox(periodsBoxName);
    await Hive.openBox(incomesBoxName);
    await Hive.openBox(categoriesBoxName);
    await Hive.openBox(templatesBoxName);
    await Hive.openBox(templateItemsBoxName);
    await Hive.openBox(allocationsBoxName);
    await Hive.openBox(transactionsBoxName);
    await Hive.openBox(plannedExpensesBoxName);
    await Hive.openBox(settingsBoxName);

    await _seedDefaultsIfNeeded();
  }

  static Future<void> _seedDefaultsIfNeeded() async {
    final categoriesBox = Hive.box(categoriesBoxName);
    if (categoriesBox.isEmpty) {
      for (final cat in Category.defaultCategories()) {
        await categoriesBox.put(cat.id, cat.toMap());
      }
    }

    final templatesBox = Hive.box(templatesBoxName);
    final itemsBox = Hive.box(templateItemsBoxName);
    if (templatesBox.isEmpty) {
      const defaultTemplateId = 'tmpl_monthly_salary';
      final defaultTemplate = AllocationTemplate(
        id: defaultTemplateId,
        name: 'Gaji Bulanan Standard',
        isDefault: true,
      );
      await templatesBox.put(defaultTemplateId, defaultTemplate.toMap());

      final defaultItems = [
        AllocationTemplateItem(
          id: 'item_1',
          templateId: defaultTemplateId,
          categoryId: 'cat_housing',
          method: 'percentage',
          value: 20.0,
        ),
        AllocationTemplateItem(
          id: 'item_2',
          templateId: defaultTemplateId,
          categoryId: 'cat_food',
          method: 'percentage',
          value: 15.0,
        ),
        AllocationTemplateItem(
          id: 'item_3',
          templateId: defaultTemplateId,
          categoryId: 'cat_investment',
          method: 'percentage',
          value: 20.0,
        ),
        AllocationTemplateItem(
          id: 'item_4',
          templateId: defaultTemplateId,
          categoryId: 'cat_emergency',
          method: 'percentage',
          value: 10.0,
        ),
        AllocationTemplateItem(
          id: 'item_5',
          templateId: defaultTemplateId,
          categoryId: 'cat_lifestyle',
          method: 'percentage',
          value: 10.0,
        ),
        AllocationTemplateItem(
          id: 'item_6',
          templateId: defaultTemplateId,
          categoryId: 'cat_family',
          method: 'percentage',
          value: 25.0,
        ),
      ];

      for (final item in defaultItems) {
        await itemsBox.put(item.id, item.toMap());
      }
    }
  }

  // --- Financial Period Operations ---
  static List<FinancialPeriod> getAllPeriods() {
    final box = Hive.box(periodsBoxName);
    final list = box.values
        .map((e) => FinancialPeriod.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  static FinancialPeriod? getPeriod(String periodId) {
    final box = Hive.box(periodsBoxName);
    final data = box.get(periodId);
    if (data == null) return null;
    return FinancialPeriod.fromMap(Map<String, dynamic>.from(data as Map));
  }

  static Future<void> savePeriod(FinancialPeriod period) async {
    final box = Hive.box(periodsBoxName);
    await box.put(period.id, period.toMap());
  }

  // --- Income Operations ---
  static List<Income> getIncomesForPeriod(String periodId) {
    final box = Hive.box(incomesBoxName);
    return box.values
        .map((e) => Income.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((inc) => inc.periodId == periodId)
        .toList();
  }

  static List<Income> getAllIncomes() {
    final box = Hive.box(incomesBoxName);
    return box.values
        .map((e) => Income.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> saveIncome(Income income) async {
    final box = Hive.box(incomesBoxName);
    await box.put(income.id, income.toMap());
  }

  static Future<void> deleteIncome(String incomeId) async {
    final box = Hive.box(incomesBoxName);
    await box.delete(incomeId);
  }

  // --- Category Operations ---
  static List<Category> getAllCategories() {
    final box = Hive.box(categoriesBoxName);
    final list = box.values
        .map((e) => Category.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  static Future<void> saveCategory(Category category) async {
    final box = Hive.box(categoriesBoxName);
    await box.put(category.id, category.toMap());
  }

  static Future<void> deleteCategory(String categoryId) async {
    final box = Hive.box(categoriesBoxName);
    await box.delete(categoryId);
  }

  // --- Template Operations ---
  static List<AllocationTemplate> getAllTemplates() {
    final box = Hive.box(templatesBoxName);
    return box.values
        .map((e) => AllocationTemplate.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static List<AllocationTemplateItem> getTemplateItems(String templateId) {
    final box = Hive.box(templateItemsBoxName);
    return box.values
        .map((e) => AllocationTemplateItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((item) => item.templateId == templateId)
        .toList();
  }

  static Future<void> saveTemplate(AllocationTemplate template, List<AllocationTemplateItem> items) async {
    final tBox = Hive.box(templatesBoxName);
    await tBox.put(template.id, template.toMap());

    final iBox = Hive.box(templateItemsBoxName);
    // remove old items
    final keysToRemove = iBox.values
        .where((e) => (e as Map)['templateId'] == template.id)
        .map((e) => (e as Map)['id'])
        .toList();
    for (final k in keysToRemove) {
      await iBox.delete(k);
    }
    for (final item in items) {
      await iBox.put(item.id, item.toMap());
    }
  }

  // --- Allocation Operations ---
  static List<Allocation> getAllocationsForPeriod(String periodId) {
    final box = Hive.box(allocationsBoxName);
    return box.values
        .map((e) => Allocation.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((alloc) => alloc.periodId == periodId)
        .toList();
  }

  static List<Allocation> getAllAllocations() {
    final box = Hive.box(allocationsBoxName);
    return box.values
        .map((e) => Allocation.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> saveAllocations(List<Allocation> allocations) async {
    final box = Hive.box(allocationsBoxName);
    for (final alloc in allocations) {
      await box.put(alloc.id, alloc.toMap());
    }
  }

  static Future<void> deleteAllocationsForPeriod(String periodId) async {
    final box = Hive.box(allocationsBoxName);
    final keysToRemove = box.values
        .where((e) => (e as Map)['periodId'] == periodId)
        .map((e) => (e as Map)['id'])
        .toList();
    for (final k in keysToRemove) {
      await box.delete(k);
    }
  }

  // --- Transaction Operations ---
  static List<Transaction> getTransactionsForPeriod(String periodId) {
    final box = Hive.box(transactionsBoxName);
    final list = box.values
        .map((e) => Transaction.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((t) => t.periodId == periodId)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static List<Transaction> getAllTransactions() {
    final box = Hive.box(transactionsBoxName);
    return box.values
        .map((e) => Transaction.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> saveTransaction(Transaction transaction) async {
    final box = Hive.box(transactionsBoxName);
    await box.put(transaction.id, transaction.toMap());
  }

  static Future<void> deleteTransaction(String transactionId) async {
    final box = Hive.box(transactionsBoxName);
    await box.delete(transactionId);
  }

  // --- Planned Expense Operations ---
  static List<PlannedExpense> getPlannedExpensesForPeriod(String periodId) {
    final box = Hive.box(plannedExpensesBoxName);
    return box.values
        .map((e) => PlannedExpense.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((pe) => pe.periodId == periodId)
        .toList();
  }

  static List<PlannedExpense> getPlannedExpensesForCategory(String periodId, String categoryId) {
    final box = Hive.box(plannedExpensesBoxName);
    return box.values
        .map((e) => PlannedExpense.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((pe) => pe.periodId == periodId && pe.categoryId == categoryId)
        .toList();
  }

  static List<PlannedExpense> getAllPlannedExpenses() {
    final box = Hive.box(plannedExpensesBoxName);
    return box.values
        .map((e) => PlannedExpense.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> savePlannedExpense(PlannedExpense plannedExpense) async {
    final box = Hive.box(plannedExpensesBoxName);
    await box.put(plannedExpense.id, plannedExpense.toMap());
  }

  static Future<void> deletePlannedExpense(String plannedExpenseId) async {
    final box = Hive.box(plannedExpensesBoxName);
    await box.delete(plannedExpenseId);
  }

  // --- Settings Operations ---
  static String? getSetting(String key) {
    final box = Hive.box(settingsBoxName);
    return box.get(key) as String?;
  }

  static Future<void> setSetting(String key, String value) async {
    final box = Hive.box(settingsBoxName);
    await box.put(key, value);
  }

  // --- Full Database Replace / Restore ---
  static Future<void> replaceDatabase({
    required List<FinancialPeriod> periods,
    required List<Income> incomes,
    required List<Category> categories,
    required List<AllocationTemplate> templates,
    required List<AllocationTemplateItem> templateItems,
    required List<Allocation> allocations,
    required List<Transaction> transactions,
    List<PlannedExpense> plannedExpenses = const [],
  }) async {
    final pBox = Hive.box(periodsBoxName);
    final incBox = Hive.box(incomesBoxName);
    final cBox = Hive.box(categoriesBoxName);
    final tBox = Hive.box(templatesBoxName);
    final tiBox = Hive.box(templateItemsBoxName);
    final aBox = Hive.box(allocationsBoxName);
    final trBox = Hive.box(transactionsBoxName);
    final peBox = Hive.box(plannedExpensesBoxName);

    await pBox.clear();
    await incBox.clear();
    await cBox.clear();
    await tBox.clear();
    await tiBox.clear();
    await aBox.clear();
    await trBox.clear();
    await peBox.clear();

    for (final item in periods) {
      await pBox.put(item.id, item.toMap());
    }
    for (final item in incomes) {
      await incBox.put(item.id, item.toMap());
    }
    for (final item in categories) {
      await cBox.put(item.id, item.toMap());
    }
    for (final item in templates) {
      await tBox.put(item.id, item.toMap());
    }
    for (final item in templateItems) {
      await tiBox.put(item.id, item.toMap());
    }
    for (final item in allocations) {
      await aBox.put(item.id, item.toMap());
    }
    for (final item in transactions) {
      await trBox.put(item.id, item.toMap());
    }
    for (final item in plannedExpenses) {
      await peBox.put(item.id, item.toMap());
    }

    await setSetting('last_backup_date', DateTime.now().toIso8601String());
  }
}
