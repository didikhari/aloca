import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../database/hive_service.dart';
import '../../models/financial_period.dart';
import '../../models/income.dart';
import '../../models/category.dart';
import '../../models/allocation_template.dart';
import '../../models/allocation.dart';
import '../../models/transaction.dart';
import '../../models/monthly_expense.dart';

class ExcelService {
  static Future<String?> exportData() async {
    final excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    // 1. FinancialPeriods
    final sheetPeriods = excel['FinancialPeriods'];
    sheetPeriods.appendRow([
      TextCellValue('id'),
      TextCellValue('year'),
      TextCellValue('month'),
      TextCellValue('opening_balance'),
      TextCellValue('is_closed'),
    ]);
    for (final p in HiveService.getAllPeriods()) {
      sheetPeriods.appendRow([
        TextCellValue(p.id),
        IntCellValue(p.year),
        IntCellValue(p.month),
        IntCellValue(p.openingBalance),
        TextCellValue(p.isClosed ? 'true' : 'false'),
      ]);
    }

    // 2. Income
    final sheetIncome = excel['Income'];
    sheetIncome.appendRow([
      TextCellValue('id'),
      TextCellValue('period_id'),
      TextCellValue('date'),
      TextCellValue('description'),
      TextCellValue('amount'),
      TextCellValue('type'),
    ]);
    for (final inc in HiveService.getAllIncomes()) {
      sheetIncome.appendRow([
        TextCellValue(inc.id),
        TextCellValue(inc.periodId),
        TextCellValue(inc.date.toIso8601String()),
        TextCellValue(inc.description),
        IntCellValue(inc.amount),
        TextCellValue(inc.type),
      ]);
    }

    // 3. Categories
    final sheetCategories = excel['Categories'];
    sheetCategories.appendRow([
      TextCellValue('id'),
      TextCellValue('name'),
      TextCellValue('type'),
      TextCellValue('color_hex'),
      TextCellValue('icon_name'),
      TextCellValue('is_active'),
      TextCellValue('display_order'),
    ]);
    for (final c in HiveService.getAllCategories()) {
      sheetCategories.appendRow([
        TextCellValue(c.id),
        TextCellValue(c.name),
        TextCellValue(c.type),
        TextCellValue(c.colorHex),
        TextCellValue(c.iconName),
        TextCellValue(c.isActive ? 'true' : 'false'),
        IntCellValue(c.displayOrder),
      ]);
    }

    // 4. Allocations
    final sheetAllocations = excel['Allocations'];
    sheetAllocations.appendRow([
      TextCellValue('id'),
      TextCellValue('period_id'),
      TextCellValue('category_id'),
      TextCellValue('method'),
      TextCellValue('value'),
      TextCellValue('allocated_amount'),
    ]);
    for (final a in HiveService.getAllAllocations()) {
      sheetAllocations.appendRow([
        TextCellValue(a.id),
        TextCellValue(a.periodId),
        TextCellValue(a.categoryId),
        TextCellValue(a.method),
        DoubleCellValue(a.value),
        IntCellValue(a.allocatedAmount),
      ]);
    }

    // 5. AllocationTemplates
    final sheetTemplates = excel['AllocationTemplates'];
    sheetTemplates.appendRow([
      TextCellValue('id'),
      TextCellValue('name'),
      TextCellValue('is_default'),
    ]);
    final templates = HiveService.getAllTemplates();
    for (final t in templates) {
      sheetTemplates.appendRow([
        TextCellValue(t.id),
        TextCellValue(t.name),
        TextCellValue(t.isDefault ? 'true' : 'false'),
      ]);
    }

    // 6. AllocationTemplateItems
    final sheetTemplateItems = excel['AllocationTemplateItems'];
    sheetTemplateItems.appendRow([
      TextCellValue('id'),
      TextCellValue('template_id'),
      TextCellValue('category_id'),
      TextCellValue('method'),
      TextCellValue('value'),
    ]);
    for (final t in templates) {
      for (final item in HiveService.getTemplateItems(t.id)) {
        sheetTemplateItems.appendRow([
          TextCellValue(item.id),
          TextCellValue(item.templateId),
          TextCellValue(item.categoryId),
          TextCellValue(item.method),
          DoubleCellValue(item.value),
        ]);
      }
    }

    // 7. Transactions
    final sheetTransactions = excel['Transactions'];
    sheetTransactions.appendRow([
      TextCellValue('id'),
      TextCellValue('period_id'),
      TextCellValue('date'),
      TextCellValue('description'),
      TextCellValue('category_id'),
      TextCellValue('amount'),
      TextCellValue('type'),
      TextCellValue('note'),
    ]);
    for (final tr in HiveService.getAllTransactions()) {
      sheetTransactions.appendRow([
        TextCellValue(tr.id),
        TextCellValue(tr.periodId),
        TextCellValue(tr.date.toIso8601String()),
        TextCellValue(tr.description),
        TextCellValue(tr.categoryId),
        IntCellValue(tr.amount),
        TextCellValue(tr.type),
        TextCellValue(tr.note ?? ''),
      ]);
    }

    // 8. PlannedExpenses (MonthlyExpenses)
    final Sheet sheetPlannedExpenses = excel['PlannedExpenses'];
    sheetPlannedExpenses.appendRow([
      TextCellValue('id'),
      TextCellValue('period_id'),
      TextCellValue('category_id'),
      TextCellValue('title'),
      TextCellValue('is_paid'),
      TextCellValue('amount'),
      TextCellValue('payment_date'),
      TextCellValue('recurring_expense_id'),
      TextCellValue('paid_transaction_id'),
      TextCellValue('note'),
    ]);
    for (final pe in HiveService.getAllMonthlyExpenses()) {
      sheetPlannedExpenses.appendRow([
        TextCellValue(pe.id),
        TextCellValue(pe.periodId),
        TextCellValue(pe.categoryId),
        TextCellValue(pe.title),
        TextCellValue(pe.isPaid ? 'true' : 'false'),
        pe.amount != null ? IntCellValue(pe.amount!) : TextCellValue(''),
        TextCellValue(pe.paymentDate?.toIso8601String() ?? ''),
        TextCellValue(pe.recurringExpenseId ?? ''),
        TextCellValue(pe.paidTransactionId ?? ''),
        TextCellValue(pe.note ?? ''),
      ]);
    }

    final fileBytes = excel.save();
    if (fileBytes == null) return null;

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'Aloca_Backup_${DateTime.now().toString().split(' ')[0]}.xlsx';
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Aloca Financial Backup ($fileName)',
    );

    await HiveService.setSetting(
        'last_backup_date', DateTime.now().toIso8601String());

    return filePath;
  }

  static Future<Map<String, dynamic>> importAndValidate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return {'success': false, 'message': 'Tidak ada file yang dipilih.'};
    }

    final bytes = result.files.first.bytes;
    if (bytes == null) {
      return {'success': false, 'message': 'Gagal membaca konten file Excel.'};
    }

    try {
      final excel = Excel.decodeBytes(bytes);
      final requiredSheets = [
        'FinancialPeriods',
        'Income',
        'Categories',
        'Allocations',
        'AllocationTemplates',
        'AllocationTemplateItems',
        'Transactions'
      ];

      for (final req in requiredSheets) {
        if (!excel.tables.containsKey(req)) {
          return {
            'success': false,
            'message':
                'Format backup tidak valid: Sheet "$req" tidak ditemukan.'
          };
        }
      }

      // Parse FinancialPeriods
      final List<FinancialPeriod> periods = [];
      final periodsTable = excel.tables['FinancialPeriods']!;
      for (int i = 1; i < periodsTable.maxRows; i++) {
        final row = periodsTable.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;
        periods.add(FinancialPeriod(
          id: row[0]!.value.toString(),
          year: int.parse(row[1]!.value.toString()),
          month: int.parse(row[2]!.value.toString()),
          openingBalance: int.parse(row[3]!.value.toString()),
          isClosed: row[4]?.value?.toString().toLowerCase() == 'true',
        ));
      }

      // Parse Income
      final List<Income> incomes = [];
      final incomeTable = excel.tables['Income']!;
      for (int i = 1; i < incomeTable.maxRows; i++) {
        final row = incomeTable.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;
        incomes.add(Income(
          id: row[0]!.value.toString(),
          periodId: row[1]!.value.toString(),
          date: DateTime.parse(row[2]!.value.toString()),
          description: row[3]?.value?.toString() ?? '',
          amount: int.parse(row[4]!.value.toString()),
          type: row[5]?.value?.toString() ?? 'Salary',
        ));
      }

      // Parse Categories
      final List<Category> categories = [];
      final catTable = excel.tables['Categories']!;
      for (int i = 1; i < catTable.maxRows; i++) {
        final row = catTable.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;
        categories.add(Category(
          id: row[0]!.value.toString(),
          name: row[1]?.value?.toString() ?? 'Category',
          type: row[2]?.value?.toString() ?? 'Expense',
          colorHex: row[3]?.value?.toString() ?? '#00A884',
          iconName: row[4]?.value?.toString() ?? 'category',
          isActive: row[5]?.value?.toString().toLowerCase() == 'true',
          displayOrder: int.parse(row[6]?.value?.toString() ?? '0'),
        ));
      }

      // Parse Allocations
      final List<Allocation> allocations = [];
      final allocTable = excel.tables['Allocations']!;
      for (int i = 1; i < allocTable.maxRows; i++) {
        final row = allocTable.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;
        allocations.add(Allocation(
          id: row[0]!.value.toString(),
          periodId: row[1]!.value.toString(),
          categoryId: row[2]!.value.toString(),
          method: row[3]?.value?.toString() ?? 'percentage',
          value: double.parse(row[4]!.value.toString()),
          allocatedAmount: int.parse(row[5]!.value.toString()),
        ));
      }

      // Parse AllocationTemplates
      final List<AllocationTemplate> templates = [];
      final tmplTable = excel.tables['AllocationTemplates']!;
      for (int i = 1; i < tmplTable.maxRows; i++) {
        final row = tmplTable.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;
        templates.add(AllocationTemplate(
          id: row[0]!.value.toString(),
          name: row[1]?.value?.toString() ?? 'Template',
          isDefault: row[2]?.value?.toString().toLowerCase() == 'true',
        ));
      }

      // Parse AllocationTemplateItems
      final List<AllocationTemplateItem> templateItems = [];
      final tmplItemsTable = excel.tables['AllocationTemplateItems']!;
      for (int i = 1; i < tmplItemsTable.maxRows; i++) {
        final row = tmplItemsTable.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;
        templateItems.add(AllocationTemplateItem(
          id: row[0]!.value.toString(),
          templateId: row[1]!.value.toString(),
          categoryId: row[2]!.value.toString(),
          method: row[3]?.value?.toString() ?? 'percentage',
          value: double.parse(row[4]!.value.toString()),
        ));
      }

      // Parse Transactions
      final List<Transaction> transactions = [];
      final trTable = excel.tables['Transactions']!;
      for (int i = 1; i < trTable.maxRows; i++) {
        final row = trTable.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;
        transactions.add(Transaction(
          id: row[0]!.value.toString(),
          periodId: row[1]!.value.toString(),
          date: DateTime.parse(row[2]!.value.toString()),
          description: row[3]?.value?.toString() ?? '',
          categoryId: row[4]!.value.toString(),
          amount: int.parse(row[5]!.value.toString()),
          type: row[6]?.value?.toString() ?? 'Expense',
          note: row[7]?.value?.toString(),
        ));
      }

      // Parse PlannedExpenses (Optional for backwards compatibility)
      final List<MonthlyExpense> plannedExpenses = [];
      if (excel.tables.containsKey('PlannedExpenses')) {
        final peTable = excel.tables['PlannedExpenses']!;
        for (int i = 1; i < peTable.maxRows; i++) {
          final row = peTable.rows[i];
          if (row.isEmpty || row[0]?.value == null) continue;
          final isPaid = row[4]?.value?.toString().toLowerCase() == 'true' ||
              (row.length > 6 && row[6]?.value?.toString().toLowerCase() == 'true');
          final amountStr = row[5]?.value?.toString() ?? row[4]?.value?.toString();
          final amountVal = amountStr != null && int.tryParse(amountStr) != null
              ? int.tryParse(amountStr)
              : null;
          final payDateStr = row.length > 6 ? row[6]?.value?.toString() : null;
          final payDate = payDateStr != null && payDateStr.isNotEmpty
              ? DateTime.tryParse(payDateStr)
              : null;

          final paidTxStr = row.length > 8 ? row[8]?.value?.toString() : null;
          final noteStr = row.length > 9 ? row[9]?.value?.toString() : (row.length > 8 ? row[8]?.value?.toString() : null);

          plannedExpenses.add(MonthlyExpense(
            id: row[0]!.value.toString(),
            periodId: row[1]!.value.toString(),
            categoryId: row[2]!.value.toString(),
            title: row[3]?.value?.toString() ?? '',
            isPaid: isPaid,
            amount: isPaid ? amountVal : null,
            paymentDate: payDate,
            recurringExpenseId: row.length > 7 ? row[7]?.value?.toString() : null,
            paidTransactionId: (paidTxStr != null && paidTxStr.isNotEmpty && paidTxStr.startsWith('tx_')) ? paidTxStr : null,
            note: noteStr,
          ));
        }
      }

      return {
        'success': true,
        'periods': periods,
        'incomes': incomes,
        'categories': categories,
        'templates': templates,
        'templateItems': templateItems,
        'allocations': allocations,
        'transactions': transactions,
        'plannedExpenses': plannedExpenses,
        'summaryText':
            'Ditemukan ${periods.length} Periode, ${incomes.length} Income, ${transactions.length} Transaksi, ${plannedExpenses.length} Rencana Pengeluaran, dan ${categories.length} Kategori.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memvalidasi atau membaca file Excel: $e',
      };
    }
  }
}
