# Screen Inventory

This document provides a comprehensive inventory of all 9 user-facing screens, modals, and bottom sheets in the Aloca Flutter application.

---

## 1. Initial Setup Screen (`InitialSetupScreen`)

```text
Screen
├── Name: Initial Setup Screen (Onboarding)
├── Route: Initial route when no FinancialPeriod exists in Hive database
├── Source: lib/screens/onboarding/initial_setup_screen.dart
├── Purpose: Onboards new users by establishing the first Financial Period (Month/Year) and initial Opening Balance.
├── Layout: SafeArea -> Padding (24dp) -> Column (Icon, Welcome Text, Date Selector, Amount Field, Spacer, Action CTA)
├── Components:
│   ├── Header Circle Icon (Account Balance Wallet)
│   ├── Title & Subtitle Typography
│   ├── Period Date Picker Tile (Container + InkWell)
│   ├── Opening Balance TextField (ThousandsSeparatorInputFormatter)
│   └── Primary Action Button (ElevatedButton)
├── Actions:
│   ├── Tap Date Picker Tile -> Opens showDatePicker dialog (years 2020-2030)
│   ├── Type Opening Balance -> Formats input as IDR currency (e.g. 500.000)
│   └── Tap "Mulai Mengelola Keuangan" -> Creates period, sets opening balance, navigates to DashboardScreen
├── States:
│   ├── Default: Empty amount input, selected date = DateTime.now()
│   ├── Date Selected: Displays "MM / YYYY" in date tile
│   └── Amount Entered: Live formatted text with "Rp " prefix
└── Navigation: Replaces route with DashboardScreen upon submission
```

---

## 2. Dashboard Screen (`DashboardScreen`)

```text
Screen
├── Name: Dashboard Screen (Main Hub)
├── Route: Home screen (MaterialApp home)
├── Source: lib/screens/dashboard/dashboard_screen.dart
├── Purpose: Core financial overview presenting Financial Position, Available Funds, Allocation Status, Category Progress Cards, and Quick Add FAB.
├── Layout: Scaffold -> SafeArea -> SingleChildScrollView (Padding 16dp) -> Column -> FloatingActionButton
├── Components:
│   ├── AppBar (Title "Aloca", Monthly Report Action, Backup Settings Action)
│   ├── Navigation Drawer (Dashboard, Transactions, Allocation Settings, Categories, Reports, Backup)
│   ├── Period Selector Bar (Prev Chevron, Date Picker Tile, Next Chevron)
│   ├── Financial Position Summary Card (Total Available Banner, Mask Toggle Icon, Stats Grid)
│   ├── Unallocated / Overallocated Warning Banner (Conditional)
│   ├── Category Progress Cards List (ListView.separated)
│   │   ├── Category Header (Color Circle Indicator, Name, Status Badge)
│   │   ├── CustomProgressBar (Usage ratio)
│   │   ├── Terpakai vs Sisa Amount Row
│   │   └── Planned Expenses Summary Badge (x/y Lunas)
│   └── FloatingActionButton ("+ Tambah Transaksi")
├── Actions:
│   ├── Tap Prev/Next Month Chevron -> Navigates to previous/next month period (auto-recalculates chain)
│   ├── Tap Month Picker -> Opens showDatePicker
│   ├── Tap Mask Eye Icon -> Toggles balance visibility (isBalanceMaskedProvider)
│   ├── Tap Category Card -> Opens CategoryPlannedExpensesSheet modal
│   ├── Tap "Kelola" -> Navigates to AllocationManagementScreen
│   └── Tap FAB -> Opens QuickAddTransactionScreen modal
├── States:
│   ├── Masked Mode (Default): Balance rendered as "Rp ••••••••"
│   ├── Unmasked Mode: Balance rendered as formatted IDR (e.g., "Rp 10.000.000")
│   ├── Unallocated Funds State: Blue banner ("Anda masih memiliki sisa dana...")
│   ├── Overallocated State: Red banner ("Total alokasi Anda melebihi dana tersedia...")
│   └── Empty Categories State: Placeholder card with "Buat Alokasi" button
└── Navigation: Pushes to MonthlyReportScreen, BackupRestoreScreen, AllocationManagementScreen, TransactionsListScreen, CategoriesScreen
```

---

## 3. Category Planned Expenses Sheet (`CategoryPlannedExpensesSheet`)

```text
Screen
├── Name: Category Planned Expenses Sheet (Modal Bottom Sheet)
├── Route: Modal Bottom Sheet (showModalBottomSheet)
├── Source: lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart
├── Purpose: Interactive category details sheet for managing monthly Planned Expenses checklist and viewing Unplanned Expense transactions.
├── Layout: Modal Container (Rounded Top Radius 20dp, Max Height 85% Viewport) -> Column -> Tab Switcher -> Tab Content
├── Components:
│   ├── Drag Handle Indicator (40x4dp Rounded Container)
│   ├── Category Header Card (Icon, Name, Paid/Total Badge, Allocation, Total Planned, Unplanned, Sisa Anggaran)
│   ├── Segmented Tab Switcher ("Rencana (N)" vs "Diluar Rencana (N)")
│   ├── Planned Expenses List (Tab 0): Item Tiles with 1-Tap Pay Checkbox
│   └── Unplanned Transactions List (Tab 1): Transaction Tiles with Delete Action
├── Actions:
│   ├── Switch Tab -> Toggle between Rencana and Diluar Rencana
│   ├── Tap "+ Tambah Item" -> Opens _showAddPlannedDialog
│   ├── Tap "+ Tambah Transaksi" -> Opens _showAddUnplannedTransactionDialog
│   ├── Tap Checkbox / "Bayar" -> Opens _showPayDialog (1-Tap Pay)
│   ├── Tap Checked Icon -> Triggers unpayPlannedExpense
│   └── Tap Delete Icon on Unplanned Tx -> Opens _confirmDeleteUnplannedTransaction dialog
├── States:
│   ├── Tab 0 Selected: Displays planned expenses list
│   ├── Tab 1 Selected: Displays unplanned transactions list
│   ├── Item Paid (Under/On Budget): Green background tile (0xFFF0FDF4), checkmark icon
│   ├── Item Paid (Overrun): Orange background indicator, warning badge ("Dibayar di atas rencana")
│   └── Empty State: Centered icon, helper text, and CTA button
└── Navigation: Pops bottom sheet on finish
```

---

## 4. Quick Add Transaction Screen (`QuickAddTransactionScreen`)

```text
Screen
├── Name: Quick Add Transaction Screen (Modal Bottom Sheet)
├── Route: Modal Bottom Sheet (showModalBottomSheet)
├── Source: lib/screens/transaction/quick_add_transaction_screen.dart
├── Purpose: Fast entry sheet for recording new Expense or Income transactions.
├── Layout: Modal Container (Rounded Top Radius 24dp) -> Column (Header, Type Toggle, Amount Input, Description Input, Category Dropdown, Submit CTA)
├── Components:
│   ├── Bottom Sheet Header (Title, Close IconButton)
│   ├── Segmented Type ChoiceChips ("Pengeluaran" vs "Pendapatan")
│   ├── Large Amount TextField (Font Size 20sp, Bold, "Rp " prefix)
│   ├── Description TextField (TextCapitalization.words)
│   ├── Category DropdownFormField (Visible only when type == 'Expense')
│   └── Submit Button (ElevatedButton)
├── Actions:
│   ├── Toggle Type -> Switches between Expense (Red Theme) and Income (Teal Theme)
│   ├── Input Amount & Description -> Formats currency input
│   ├── Select Category -> Selects target expense category
│   └── Tap "Simpan" -> Adds transaction/income and pops sheet
├── States:
│   ├── Expense Mode (Default): Red submit button, category dropdown visible
│   └── Income Mode: Teal submit button, category dropdown hidden
└── Navigation: Pops modal sheet on save
```

---

## 5. Transactions List Screen (`TransactionsListScreen`)

```text
Screen
├── Name: Transactions List Screen
├── Route: Pushed via Drawer / Category Filter
├── Source: lib/screens/transaction/transactions_list_screen.dart
├── Purpose: Displays all Income and Expense transactions for the active period with filtering capabilities.
├── Layout: Scaffold -> SafeArea -> Column -> Filter Tab Bar -> Category Banner (Optional) -> ListView
├── Components:
│   ├── AppBar (Title "Riwayat Transaksi" or "Riwayat: [Category Name]")
│   ├── Horizontal ChoiceChip Tab Bar ("Semua", "Pendapatan", "Pengeluaran")
│   ├── Active Category Filter Banner (Dismissible chip)
│   └── Transaction Item Cards (CustomCard with type icon, description, category/date, amount)
├── Actions:
│   ├── Select Filter Tab -> Filters list by All, Income, or Expense
│   ├── Tap "Hapus Filter" -> Clears category filter
│   └── Tap Delete Icon on Item -> Deletes income or expense transaction
├── States:
│   ├── Tab 0 (Semua): Merged list of income (+Rp) and expenses (-Rp) sorted date desc
│   ├── Tab 1 (Pendapatan): Income items only
│   ├── Tab 2 (Pengeluaran): Expense items only
│   └── Empty State: Centered text "Belum ada transaksi pada periode ini."
└── Navigation: Standard Scaffold back button
```

---

## 6. Allocation Management Screen (`AllocationManagementScreen`)

```text
Screen
├── Name: Allocation Management Screen
├── Route: Pushed via Dashboard "Kelola" or Drawer
├── Source: lib/screens/settings/allocation_management_screen.dart
├── Purpose: Primary editor for setting category allocation methods (Nominal, Percentage, Remaining), live previewing allocation totals, and generating allocations from templates.
├── Layout: Scaffold -> SafeArea -> SingleChildScrollView -> Column -> Banner Card -> Category Cards List -> Save CTA
├── Components:
│   ├── AppBar (Title "Alokasi: [Period]", Template Picker IconButton)
│   ├── Available Funds Summary Banner (Total Available, Live Total Allocated, Live Sisa/Defisit, Warning Chip)
│   ├── Category Allocation Cards List
│   │   ├── Name, Method Label, Resulting Live Nominal
│   │   └── Planned Expenses Badge Button ("+ Tambah Rencana Tagihan")
│   └── Save Allocations Button (ElevatedButton)
├── Actions:
│   ├── Tap Category Card -> Opens _showEditAllocationBottomSheet
│   ├── Tap "+ Tambah Rencana Tagihan" -> Opens CategoryPlannedExpensesSheet
│   ├── Tap Auto-Awesome Icon -> Opens _showTemplatePicker modal sheet
│   └── Tap "Simpan Alokasi" -> Validates overallocation and saves to Hive
├── States:
│   ├── Normal State: Live Sisa >= 0 (Green banner background)
│   ├── Defisit / Overallocated State: Live Sisa < 0 (Red banner background + Warning warning box)
│   └── Bottom Sheet Modal Edit State: Live preview calculation as user types % or Rp
└── Navigation: Pops screen on save
```

---

## 7. Categories Screen (`CategoriesScreen`)

```text
Screen
├── Name: Categories Screen
├── Route: Pushed via Drawer
├── Source: lib/screens/settings/categories_screen.dart
├── Purpose: Management screen for creating, editing, and deleting dynamic categories.
├── Layout: Scaffold -> SafeArea -> ListView.separated -> FloatingActionButton
├── Components:
│   ├── AppBar (Title "Kelola Kategori")
│   ├── Category Item Tiles (Color circle indicator, Category Name, Edit IconButton, Delete IconButton)
│   └── FloatingActionButton ("+")
├── Actions:
│   ├── Tap Edit Icon -> Opens _showEditCategoryDialog
│   ├── Tap Delete Icon -> Validates transactions/planned expenses, shows confirmation or error dialog
│   └── Tap FAB -> Opens _showAddCategoryDialog
├── States:
│   ├── Normal Category List
│   └── Cannot Delete Dialog: Shown if category has existing transactions or planned expenses
└── Navigation: Standard Scaffold back button
```

---

## 8. Backup & Restore Screen (`BackupRestoreScreen`)

```text
Screen
├── Name: Backup & Restore Screen
├── Route: Pushed via AppBar Settings / Drawer
├── Source: lib/screens/settings/backup_restore_screen.dart
├── Purpose: Handles exporting entire app data to an 8-sheet Excel file (.xlsx) and restoring database from a backup file with a 14-day reminder system.
├── Layout: Scaffold -> SafeArea -> SingleChildScrollView -> Column (14-Day Status Card, Export Card, Import Card)
├── Components:
│   ├── AppBar (Title "Backup & Restore Excel")
│   ├── 14-Day Backup Status Card (Status Icon, Title, Subtitle timestamp)
│   ├── Export Card (Header, Description, "Export & Simpan Excel" ElevatedButton)
│   └── Import/Restore Card (Header, Description, "Pilih File Excel Backup" OutlinedButton)
├── Actions:
│   ├── Tap "Export & Simpan Excel" -> Calls ExcelService.exportData() & opens native share sheet
│   └── Tap "Pilih File Excel Backup" -> Calls file_picker, validates schema, shows Replace All confirmation dialog
├── States:
│   ├── Backup OK State (<= 14 days): Green card background (0xFFE6F4EA)
│   ├── Backup Overdue State (> 14 days / null): Amber warning background (0xFFFFFBEB)
│   └── Loading State: Buttons disabled (_isLoading == true)
└── Navigation: Standard Scaffold back button
```

---

## 9. Monthly Report Screen (`MonthlyReportScreen`)

```text
Screen
├── Name: Monthly Report Screen
├── Route: Pushed via AppBar Analytics / Drawer
├── Source: lib/screens/reports/monthly_report_screen.dart
├── Purpose: Financial position reporting screen featuring continuous carry-over breakdown and Category Budget vs Actual Variance DataTable.
├── Layout: Scaffold -> SafeArea -> SingleChildScrollView -> Column (Financial Position Card, Category Variance Card)
├── Components:
│   ├── AppBar (Title "Laporan: [Period]")
│   ├── Continuous Financial Position Card (Opening Balance, + Income, = Total Available, - Expenses, = Closing Balance, Mask Toggle Icon)
│   └── Category Budget vs Actual Variance Table (DataTable inside horizontal SingleChildScrollView)
│       └── Columns: Kategori, Alokasi, Aktual, Sisa, Status Badge
├── Actions:
│   ├── Tap Mask Eye Icon -> Toggles balance visibility
│   └── Scroll Horizontal -> Scroll DataTable columns
├── States:
│   ├── Masked Mode: Amounts rendered as "Rp ••••••••"
│   └── Unmasked Mode: Amounts rendered as formatted IDR
└── Navigation: Standard Scaffold back button
```
