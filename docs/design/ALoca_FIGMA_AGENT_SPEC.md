# Aloca — Figma Agent Master Design Specification

**Document Version**: 1.0.0-Master  
**Target Engine**: Figma Agent / Code-to-Canvas / Design System Engineers  
**Source Baseline**: Aloca Phase 1 (Reverse Engineering) & Phase 2 (Design System Refinement)  
**Output Target**: Native, Editable Aloca Figma Design File (.fig)

---

## 1. Document Purpose

This document serves as the **single, self-contained, authoritative visual and structural design specification** for generating the official Aloca Figma Design System and native UI screens via **Figma Agent**.

It consolidates:
- **Phase 1**: Reverse-engineered visual tokens, screen layout inventories, component specs, and interaction states extracted from the baseline Flutter codebase.
- **Phase 2**: Refined semantic design tokens (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`), normalized button/sheet dimensions, harmonized typography scales, and component-to-Flutter mapping.

Figma Agent must consume this document as its sole visual truth to construct native, fully editable Figma layers, frames, variables, text styles, and component variants **without needing to access or parse Flutter source code**.

---

## 2. Aloca Product Context

**Aloca** is a local-first, privacy-focused personal financial allocation mobile application designed around the **Plan → Allocate → Track** paradigm.

### Key Financial Workflow Concepts
1. **Plan (Perencanaan)**: Establish opening balances and mandatory monthly bill items (*Planned Expenses*).
2. **Allocate (Alokasi)**: Divide total available funds (*Total Available = Opening Balance + Total Income*) across spending categories using 3 flexible allocation methods:
   - **Nominal (Rp)**: Fixed IDR amount.
   - **Persentase (%)**: Percentage of Total Available.
   - **Sisa Dana (Balancer)**: Automatically absorbs remaining unallocated funds via 2-Pass calculation.
3. **Track (Pelacakan)**: 1-Tap Pay for planned expenses (with overrun indicators) and quick-add tracking for unplanned expenses and income.
4. **Continuous Carry-Over**: The closing balance of month $M-1$ automatically becomes the opening balance of month $M$ ($\text{Opening}_M = \text{Closing}_{M-1}$).

---

## 3. Design Principles

1. **Financial Clarity & Readability**: Financial figures (Total Available, Allocated, Expense, Remaining) must follow strict visual hierarchy with high contrast and explicit status badges.
2. **Visual Consistency & Predictability**: All cards, inputs, buttons, and sheets adhere strictly to normalized design tokens (`16dp` cards, `20dp` top sheet radii, `48dp` button heights, `16dp` outer paddings).
3. **Low Cognitive Load**: Clean surfaces, minimal visual noise, and predictable card-based layouts.
4. **Touch-Friendly Interaction**: Standard touch targets (minimum `48dp` CTA heights, clear ripple splash feedback, large input fields).
5. **Accessibility Beyond Color**: Status indicators (*Under Budget*, *On Budget*, *Over Budget*, *Lunas*, *Overrun*) combine background tinting, distinct text colors, explicit labels, and vector icons.

---

## 4. Figma File Architecture

Figma Agent must organize the generated Figma file into the following 6 standardized pages:

```text
Aloca
├── 00 Cover
│   └── File Thumbnail, Title, Version, System Overview, Color Swatches Preview
├── 01 Foundations
│   ├── Color Variables & Tokens
│   ├── Typography Styles Scale
│   ├── Spacing Scale Tokens
│   ├── Corner Radius & Elevation Tokens
│   └── Iconography & Badge Foundations
├── 02 Components
│   ├── Primitive Components (Buttons, Inputs, Chips, Dividers)
│   ├── Composite Components (AppBars, Cards, Section Headers, Item Tiles)
│   └── Financial Components (Position Banners, Category Progress, Status Badges)
├── 03 Patterns
│   ├── Financial Position Summary Pattern
│   ├── Allocation 2-Pass Category Pattern
│   ├── Planned Expenses Checklist Pattern
│   └── Transactions History List Pattern
├── 04 Screens
│   ├── InitialSetupScreen (Onboarding)
│   ├── DashboardScreen (Main Hub)
│   ├── CategoryPlannedExpensesSheet (Modal Sheet)
│   ├── QuickAddTransactionScreen (Modal Sheet)
│   ├── TransactionsListScreen (History & Filters)
│   ├── AllocationManagementScreen (2-Pass Editor)
│   ├── CategoriesScreen (Dynamic Category Editor)
│   ├── BackupRestoreScreen (8-Sheet Excel Export/Import)
│   └── MonthlyReportScreen (Variance Table & Financial Position)
└── 05 Archive
    └── Baseline Raw UI Snapshots (Phase 1 Screenshots)
```

---

## 5. Design Tokens

### 5.1 Color Tokens

Figma Agent must register the following semantic color variables:

```text
color/brand/primary          #00A884  (Primary Brand Emerald Teal)
color/brand/dark             #008B74  (Gradient End & Secondary Brand Teal)
color/brand/tint             #00A8841A (10% Opacity Container Background)

color/background/default     #F8FAFC  (Page & Scaffold Background)
color/surface/default        #FFFFFF  (Card & Modal Sheet Base Background)
color/surface/subsurface     #F8FAFC  (Inner Card / Input Container Background)
color/surface/chip           #F1F5F9  (Unselected Tab & Chip Container Background)
color/border/divider         #E2E8F0  (Input Borders & Dividers)

color/text/primary           #00F172A (Primary Heading & Title Text - Slate 900)
color/text/secondary         #64748B  (Subtitles & Stat Labels - Slate 500)
color/text/muted             #94A3B8  (Hints & Inactive Icons - Slate 400)
color/text/inverse           #FFFFFF  (Text on Primary Buttons & Banners)

color/state/expense          #EF4444  (Expense Nominal & Negative Amounts)
color/state/expense-dark     #DC2626  (Overallocated Alert Text)
color/state/expense-bg       #FEF2F2  (Overallocated Alert Container BG)
color/state/overbudget-bg    #FCE8E6  (Over Budget Badge Background)
color/state/overbudget-fg    #C5221F  (Over Budget Badge Foreground Text)

color/state/income           #10B981  (Income Nominal & Positive Balances)
color/state/success-bg       #DCFCE7  (Lunas Badge Background)
color/state/paid-tile-bg     #F0FDF4  (Paid Item Tile Background)
color/state/underbudget-bg   #E6F4EA  (Under Budget Badge Background)
color/state/underbudget-fg   #137333  (Under Budget Badge Foreground Text)

color/state/warning          #F59E0B  (Overrun Payment Indicator)
color/state/warning-dark     #D97706  (Backup Overdue Icon Color)
color/state/warning-bg       #FFFBEB  (14-Day Backup Warning Container BG)
color/state/warning-badge-bg #FEF3C7  (Partial Lunas Badge Background)

color/state/info             #3B82F6  (Total Allocated Stat Text)
color/state/info-dark        #2563EB  (Unallocated Alert Icon & Link Text)
color/state/info-bg          #EFF6FF  (Unallocated Alert Container BG)
color/state/onbudget-bg      #E8F0FE  (On Budget Badge Background)
color/state/onbudget-fg      #1A73E8  (On Budget Badge Foreground Text)

color/shadow/card            #0000000A (4% Black Shadow Opacity)
```

---

### 5.2 Typography Tokens

All text styles use the **`Roboto`** font family:

| Style Token Name | Font Size | Weight | Line Height | Color Token | Primary Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `typography/display/large` | `24sp` | Bold (700) | `32dp` | `color/text/primary` | Welcome Onboarding Title |
| `typography/display/medium` | `22sp` | Bold (700) | `28dp` | `color/text/inverse` | Hero Total Available Amount (Allocation) |
| `typography/display/small` | `20sp` | Semi-bold (600) | `26dp` | `color/text/inverse` | Hero Total Available Amount (Dashboard) |
| `typography/heading/large` | `20sp` | Bold (700) | `26dp` | `color/text/primary` | AppBar Title ("Aloca") |
| `typography/heading/medium` | `18sp` | Bold (700) | `24dp` | `color/text/primary` | Modal Sheet Titles |
| `typography/heading/small` | `16sp` | Bold (700) | `22dp` | `color/text/primary` | Period Bar Selector, Primary Titles |
| `typography/section/title` | `15sp` | Bold (700) | `20dp` | `#1E293B` | **Normalized Section Headers** across all screens |
| `typography/body/primary` | `14sp` | Semi-bold (600) | `20dp` | `color/text/primary` | Category Names, Field Values |
| `typography/body/secondary` | `13sp` | Semi-bold (600) | `18dp` | `color/text/secondary` | Subtitles, Helper Text, Stat Values |
| `typography/label/standard` | `12sp` | Semi-bold (600) | `16dp` | `color/text/secondary` | Card Stat Sub-labels |
| `typography/label/small` | `11sp` | Medium (500) | `14dp` | `color/text/secondary` | **Normalized Stat Headers & Badge Text** |
| `typography/caption/badge` | `10sp` | Medium (500) | `12dp` | Dynamic Status FG | Category Status Badges |
| `typography/button/large` | `16sp` | Bold (700) | `20dp` | `color/text/inverse` | Primary & Secondary CTA Buttons |

---

### 5.3 Spacing Tokens

Figma Agent must utilize the normalized spacing scale:

```text
space/xxs :  2dp  (Micro Gaps)
space/xs  :  4dp  (Icon-to-text Gaps, Chip Insets)
space/sm  :  8dp  (Standard Item Spacing, Sub-element Padding)
space/md  : 12dp  (Card Inner Component Separator, ListView Gap)
space/lg  : 16dp  (Standard Outer Screen Padding, Card Default Padding)
space/xl  : 20dp  (Modal Sheet Insets & Horizontal Padding)
space/xxl : 24dp  (Section Spacing & Form Insets)
space/xxxl: 32dp  (Hero Section Spacing)

Normalized CTA Button Height: 48.0dp
Normalized Screen Padding    : 16.0dp
Normalized Modal Sheet Inset : 20.0dp
```

---

### 5.4 Corner Radius Tokens

```text
radius/handle :  2dp  (Drag Handle Indicator - 40x4dp)
radius/sm     :  6dp  (Status Badges, Sub-container Badges)
radius/md     : 10dp  (Progress Bar Pill, Segmented ChoiceChips)
radius/lg     : 12dp  (TextFields, Buttons, Inner Banner Containers)
radius/card   : 16dp  (CustomCard Container Radius)
radius/sheet  : 20dp  (Modal Bottom Sheet Top Corners)
```

---

### 5.5 Elevation & Shadow Tokens

```text
elevation/flat : 0dp (AppBars, Scaffold Background)
elevation/card : BoxShadow(
  color: color/shadow/card (#0000000A),
  blurRadius: 10dp,
  offset: (x: 0, y: 4)
)
```

---

### 5.6 Iconography System

- **Icon Family**: Material Symbols / Material Icons Vector Set.
- **Default Sizes**:
  - Small: `14dp` / `16dp` (Badge icons, link arrows)
  - Medium: `20dp` / `24dp` (AppBar actions, list item icons, leading icons)
  - Large: `32dp` / `36dp` (Header feature icons, empty state graphic icons)
- **Rules**: Icons must align vertically with text labels and retain `#64748B` for secondary/muted contexts, `#00A884` for active/brand contexts, `#EF4444` for expenses/deletes, and `#10B981` for incomes.

---

## 6. Financial Semantic System

Figma Agent must apply explicit, unified visual rules for all financial concepts across every screen:

| Financial Concept | Definition | Primary Visual Representation | Color Token | Typography Token |
| :--- | :--- | :--- | :--- | :--- |
| **Opening Balance** | Saldo bawaan dari bulan sebelumnya | Text row in Financial Position card & report | `color/text/inverse` or `color/text/primary` | `typography/label/standard` |
| **Total Income** | Pemasukan baru bulan berjalan | Sub-row text with `+` prefix | `color/state/income` | `typography/label/standard` Bold |
| **Total Available** | `Opening Balance + Income` | **Teal Gradient Hero Card Banner** | `#FFFFFF` text on Teal Gradient (`#00A884` -> `#008B74`) | `typography/display/small` (20sp) |
| **Total Allocated** | Total alokasi seluruh kategori | Stat Grid item | `color/state/info` (`#3B82F6`) | `typography/body/secondary` Bold |
| **Unallocated Amount** | `Available - Allocated` | Blue Alert Banner (Info) | `color/state/info-dark` on `color/state/info-bg` | `typography/label/standard` |
| **Actual Expense** | Total pengeluaran aktual | Stat Grid item, Transaction tile with `-` prefix | `color/state/expense` (`#EF4444`) | `typography/body/secondary` Bold |
| **Remaining Budget** | `Allocated - Actual` per category | Category card progress text & sheet header | `color/state/income` (>=0) / `color/state/expense` (<0) | `typography/label/standard` Bold |
| **Over Budget / Overrun** | `Actual > Allocated` | Red progress bar, `Over Budget` status badge | `color/state/overbudget-fg` on `color/state/overbudget-bg` | `typography/caption/badge` |
| **Closing Balance** | `Available - Actual Expenses` | Stat Grid item & Monthly Report final row | `color/brand/primary` or `color/text/primary` | `typography/body/secondary` Bold |
| **Continuous Carry-over** | $\text{Opening}_M = \text{Closing}_{M-1}$ | Auto-calculated; displayed as Opening Balance | `color/text/primary` | `typography/label/standard` |

---

## 7. Component Architecture

Components are organized into 7 standardized Figma component categories:

```text
Foundations ──► Primitives ──► Composites ──► Financial ──► Screens
```

### 7.1 Navigation Components
- **`Navigation/AppBar`**: Height `56dp`, Flat white `#FFFFFF`, Title `20sp` Bold `#0F172A`, Action IconButtons (`20dp`).
- **`Navigation/Drawer`**: Header Teal `#00A884`, Title `24sp` Bold, Subtitle `12sp` White70, ListTiles (`14sp` Medium).

### 7.2 Action Components
- **`Button/Primary`**: Height `48dp`, Radius `12dp`, Fill `#00A884` or `#EF4444`, Text `16sp` Bold White.
- **`Button/Secondary`**: Height `48dp`, Radius `12dp`, Border `1.5dp` (`#3B82F6`), Text `16sp` Bold.
- **`Button/FAB`**: Floating Action Button, Teal `#00A884`, Icon `+`, Label `"Tambah Transaksi"`.

### 7.3 Input Components
- **`Input/TextField`**: Height `48-56dp`, Background `#F8FAFC`, Radius `12dp`, Prefix `"Rp "` (`#00A884` Bold).
- **`Input/Dropdown`**: Height `48dp`, Background `#F8FAFC`, Radius `12dp`, Trailing Chevron.
- **`Chip/Segmented`**: Height `36-40dp`, Radius `10dp`, ChoiceChip states (Selected Teal/Red fill, Unselected `#F1F5F9`).

### 7.4 Data Display Components
- **`Card/Base` (`CustomCard`)**: Background `#FFFFFF`, Radius `16dp`, Shadow `0x0000000A Blur 10 Offset(0,4)`.
- **`Badge/Status` (`StatusBadge`)**: Radius `6dp`, Text `10sp` Medium (Variants: *Under Budget*, *On Budget*, *Over Budget*).
- **`DataTable/Variance`**: Horizontal scrollable DataTable, Header `#0F172A` Bold, Rows with currency format.

### 7.5 Financial Components
- **`Financial/PositionBanner`**: Radius `12dp`, Gradient `#00A884` -> `#008B74`, Mask Eye Icon Toggle (`Icons.visibility_off_outlined`).
- **`Financial/ProgressBar`**: Height `6dp`, Pill shape (`Radius.circular(3)`), Track `15% Opacity`, Fill `100% Opacity`.
- **`Item/PlannedExpenseTile`**: Checkbox CTA, Title `15sp` Bold, Subtitle `12sp`, Nominal `14sp` Bold, Variants: *Unpaid*, *Paid Normal*, *Paid Overrun*.
- **`Item/TransactionTile`**: Circular type icon (Income Down Arrow `#10B981` / Expense Up Arrow `#EF4444`), Title `15sp`, Sub-text, Amount `14sp` Bold.

### 7.6 Feedback Components
- **`Banner/Alert`**: Unallocated Blue (`#EFF6FF`), Overallocated Red (`#FEF2F2`), Radius `12dp`, Leading Icon.
- **`Dialog/Confirmation`**: Alert Dialog, Radius `16dp`, Title `18sp` Bold, Content `14sp`, Action Buttons Row.

### 7.7 Container Components
- **`Sheet/ModalContainer`**: Top Radius `20dp`, Background `#FFFFFF`, Drag Handle `40x4dp` Radius `2dp` (`#CBD5E1`).

---

## 8. Component Variants

Figma Agent must construct the following explicit component variants:

```text
Button/Primary
├── Variant: Brand Teal (Default)
├── Variant: Expense Red (Destructive)
├── Variant: Disabled (_isLoading == true)
└── State: Pressed (Ripple Overlay)

Input/TextField
├── Variant: Default (Border #CBD5E1)
├── Variant: Focused (Border #00A884 2dp)
└── Variant: Currency (Prefix "Rp ")

Badge/Status
├── Variant: Under Budget (BG #E6F4EA, FG #137333)
├── Variant: On Budget (BG #E8F0FE, FG #1A73E8)
└── Variant: Over Budget (BG #FCE8E6, FG #C5221F)

Item/PlannedExpense
├── Variant: Unpaid (White BG, Gray Checkbox, "Bayar" CTA)
├── Variant: Paid Normal (Green BG #F0FDF4, Teal Checked Icon, "Lunas")
└── Variant: Paid Overrun (Green BG #F0FDF4, Amber Checked Icon, Badge "+Rp X Overrun")

Financial/PositionBanner
├── Variant: Unmasked (Shows "Rp 10.000.000")
└── Variant: Masked (Default: Shows "Rp ••••••••")
```

---

## 9. Auto Layout Rules

All Figma layers must use **Figma Auto Layout** according to these explicit constraints:

1. **Screen Frame**: `390 x 844 dp` (Fixed width, vertical scrolling).
2. **Main Scroll Content Column**: Auto Layout Vertical, `Gap: 16dp`, `Padding: 16dp` (Left, Right, Top, Bottom).
3. **Card Contents**: Auto Layout Vertical/Horizontal, `Padding: 16dp`, `Gap: 8dp` or `12dp`.
4. **Summary Card Stats Grid**: 2 Horizontal Auto Layout Rows inside a Vertical Column. Each item uses `Fill Container` (`flex: 1`).
5. **Modal Bottom Sheets**: Auto Layout Vertical, Top Radius `20dp`, `Padding: 20dp` (Top, Left, Right, Bottom), `Gap: 16dp`.
6. **Sizing Constraints**:
   - `Fill Container` for horizontal cards, banners, full-width buttons, and text fields.
   - `Hug Contents` for badges, tags, chips, and button labels.

---

## 10. Reusable Composed Patterns

1. **Pattern: Financial Position Summary**: `PositionBanner` + `Divider` + 2x2 `StatsGrid` inside `CustomCard`.
2. **Pattern: 2-Pass Category Allocation Card**: Header (`Name`, `Method Text`, `Live Nominal`), Sub-badge (`+ Tambah Rencana Tagihan`), Action (`Ubah >`).
3. **Pattern: Planned Expenses Checklist**: Header Card + Segmented Tab Switcher + Item Tiles List with 1-Tap Pay CTA.
4. **Pattern: History Transactions List**: ChoiceChip Filter Bar + Category Filter Chip + Income/Expense Item Tiles.

---

## 11. Screen Inventory

Figma Agent must construct the following **9 complete screens**:

1. **`InitialSetupScreen`**: Onboarding period date picker, opening balance field, "Mulai Mengelola Keuangan" primary CTA.
2. **`DashboardScreen`**: Main hub with Period selector bar, Financial Position summary card, Warning banners, Category progress cards list, FAB "+ Tambah Transaksi".
3. **`CategoryPlannedExpensesSheet`**: Modal sheet (Top Radius 20dp) with category overview card, Rencana vs Diluar Rencana tabs, 1-tap pay checklist items.
4. **`QuickAddTransactionScreen`**: Modal sheet with Expense/Income ChoiceChips, large 20sp amount field, description field, category dropdown.
5. **`TransactionsListScreen`**: History screen with All/Income/Expense filter chips, category active filter chip, transaction cards list with delete actions.
6. **`AllocationManagementScreen`**: 2-Pass allocation editor screen with Available Funds banner, category allocation cards, template picker action, "Simpan Alokasi" CTA.
7. **`CategoriesScreen`**: Dynamic categories list screen with color indicators, edit name dialog, delete validation logic, FAB "+".
8. **`BackupRestoreScreen`**: 14-Day backup status indicator card, Export to 8-Sheet Excel card, Import/Restore Excel card with Replace All confirmation modal.
9. **`MonthlyReportScreen`**: Continuous financial position summary card and Category Budget vs Actual Variance DataTable.

---

## 12. Screen-by-Screen Design Specification

### Screen 1: InitialSetupScreen (Onboarding)
- **Purpose**: Onboard user by establishing first Financial Period and initial Opening Balance.
- **Frame**: `390 x 844 dp` (Scaffold BG `#F8FAFC`)
- **Layout**: SafeArea -> Column (Padding `24dp`)
- **Sections**:
  1. Circle Icon Header: Wallet icon (`36dp`, `#00A884`) inside `#00A8841A` circle (`padding 12dp`).
  2. Welcome Heading: `24sp` Bold (`#0F172A`), Subtitle `14sp` (`#64748B`).
  3. Period Date Tile: Label `16sp` Bold, Container (`#FFFFFF`, Radius `12dp`, Border `#CBD5E1`), Date Text `"MM / YYYY"`, Calendar icon.
  4. Opening Balance Input: Label `16sp` Bold, TextField (`#FFFFFF`, Radius `12dp`, Prefix `"Rp "`), Hint `"Contoh: 500000"`.
  5. CTA Button: Height `48dp`, Radius `12dp`, Teal `#00A884`, Text `"Mulai Mengelola Keuangan"` (`16sp` Bold White).

### Screen 2: DashboardScreen (Main Hub)
- **Purpose**: Primary dashboard presenting financial position, category progress, and transaction triggers.
- **Frame**: `390 x 844 dp` (Scaffold BG `#F8FAFC`)
- **Layout**: Scaffold -> SafeArea -> SingleChildScrollView (Padding `16dp`) -> Column -> FloatingActionButton
- **Sections**:
  1. AppBar: Title `"Aloca"` (`20sp` Bold), Actions: Analytics Icon & Settings Icon.
  2. Period Selector Bar: `CustomCard` (Padding `16x12dp`), Left Chevron, Month Picker Button (`Icons.calendar_today`, Text `16sp` Bold), Right Chevron.
  3. Financial Position Summary Card: `CustomCard`, Teal Gradient Banner (`#00A884` -> `#008B74`), Eye Mask Toggle, Hero Balance `"Rp ••••••••"` (`20sp` Bold White), Dividers, Stats Grid (2x2: Total Dialokasi `#3B82F6`, Pengeluaran `#EF4444`, Sisa Anggaran `#10B981`, Closing Balance `#0F172A`).
  4. Alert Banner (Conditional): Blue `#EFF6FF` (Unallocated) or Red `#FEF2F2` (Overallocated).
  5. Section Header: Text `"Alokasi & Progress Kategori"` (`15sp` Bold `#1E293B`), Link `"Kelola"` (`#00A884`).
  6. Category Progress List: `ListView.separated` (`Gap 12dp`), Category Cards with color dot, Name (`13sp` Bold), `StatusBadge`, `CustomProgressBar` (6dp), Terpakai/Sisa row, Planned badge (`x/y Lunas`).
  7. FAB: Extended Teal `#00A884`, Label `"+ Tambah Transaksi"`.

### Screen 3: CategoryPlannedExpensesSheet (Modal Sheet)
- **Purpose**: Manage category planned expenses checklist and view unplanned transactions.
- **Frame**: `390 x 717 dp` (Modal Sheet Top Radius `20dp`, Max Height 85%)
- **Layout**: Column (Padding `20dp`) -> Header Card -> Tab Switcher -> Tab List Content
- **Sections**:
  1. Drag Handle: `40x4dp`, Radius `2dp`, Color `#CBD5E1`.
  2. Category Summary Card: Sub-surface `#F8FAFC`, Icon, Name (`18sp` Bold), Lunas Badge, Alokasi Amount vs Total Rencana, Non-Rencana vs Sisa Anggaran (`12sp` Bold).
  3. Tab Switcher: Segmented ChoiceChips `"Rencana (N)"` vs `"Diluar Rencana (N)"`.
  4. Tab 0 Content: Header Row (`"Daftar Rencana Pengeluaran"`, `"+ Tambah Item"`), ListView of Planned Item Tiles with 1-Tap Pay button.
  5. Tab 1 Content: Header Row (`"Transaksi Non-Rencana"`, `"+ Tambah Transaksi"`), ListView of Unplanned Transaction Tiles with delete button.

### Screen 4: QuickAddTransactionScreen (Modal Sheet)
- **Purpose**: Quick entry for expense or income transactions.
- **Frame**: `390 x 500 dp` (Modal Sheet Top Radius `20dp`)
- **Layout**: Column (Padding `20dp`)
- **Sections**:
  1. Header: Title `"Catat Pengeluaran"` / `"Catat Pendapatan"` (`18sp` Bold), Close Icon.
  2. Type Toggle: ChoiceChips `"Pengeluaran"` (Red `#EF4444`) vs `"Pendapatan"` (Teal `#00A884`).
  3. Amount Input: Label `13sp` Bold, TextField (`#F8FAFC`, Radius `12dp`, Font `20sp` Bold, Prefix `"Rp "`).
  4. Description Input: TextField (`#F8FAFC`, Radius `12dp`, Title Case).
  5. Category Dropdown: DropdownFormField (`#F8FAFC`, Radius `12dp`, Visible when type == Expense).
  6. Submit Button: Height `48dp`, Radius `12dp`, Color Red (Expense) / Teal (Income), Text `"Simpan"`.

### Screen 5: TransactionsListScreen (History & Filters)
- **Purpose**: Period transaction history with tab and category filters.
- **Frame**: `390 x 844 dp` (Scaffold BG `#F8FAFC`)
- **Layout**: Column -> Filter Tab Bar -> Category Active Filter Chip -> ListView
- **Sections**:
  1. AppBar: Title `"Riwayat Transaksi"` / `"Riwayat: [Category]"`.
  2. Filter Bar: ChoiceChips `"Semua"`, `"Pendapatan"`, `"Pengeluaran"`.
  3. Category Filter Indicator (Conditional): Blue `#EFF6FF` bar, `"Filter: [Name]"`, `"Hapus Filter"` button.
  4. Transaction Cards List: `CustomCard` tiles with Income down arrow (`#10B981`) or Expense up arrow (`#EF4444`), description, date, formatted amount, delete action.

### Screen 6: AllocationManagementScreen (2-Pass Editor)
- **Purpose**: Edit category allocation methods (Rp, %, Sisa Dana) and preview results.
- **Frame**: `390 x 844 dp` (Scaffold BG `#F8FAFC`)
- **Layout**: SingleChildScrollView (Padding `16dp`) -> Column
- **Sections**:
  1. AppBar: Title `"Alokasi: [Period]"`, Template Picker Icon (`Icons.auto_awesome`).
  2. Available Funds Banner: `CustomCard`, Teal/Red BG, Hero Available Amount (`22sp` Bold White), Total Alokasi vs Sisa/Defisit.
  3. Section Title: `"Atur Persentase / Nominal per Kategori"` (`16sp` Bold).
  4. Category Cards List: Name (`14sp` Bold), Method Label, Live Nominal (`14sp` Bold `#00A884`), `"Ubah >"` link, `"+ Tambah Rencana Tagihan"` badge button.
  5. Save Button: Height `48dp`, Radius `12dp`, Teal `#00A884`, Text `"Simpan Alokasi"`.

### Screen 7: CategoriesScreen (Dynamic Category Management)
- **Purpose**: Create, edit, and delete spending categories.
- **Frame**: `390 x 844 dp` (Scaffold BG `#F8FAFC`)
- **Layout**: ListView.separated (Padding `16dp`) -> FloatingActionButton
- **Sections**:
  1. AppBar: Title `"Kelola Kategori"`.
  2. Category Tiles: `CustomCard`, Color circle dot, Name (`15sp` Bold), Edit Icon (`#64748B`), Delete Icon (`#EF4444`).
  3. FAB: Teal `#00A884`, Icon `+`.

### Screen 8: BackupRestoreScreen (8-Sheet Excel Export/Import)
- **Purpose**: Export data to 8-sheet Excel file and restore database with 14-day reminder system.
- **Frame**: `390 x 844 dp` (Scaffold BG `#F8FAFC`)
- **Layout**: SingleChildScrollView (Padding `16dp`) -> Column
- **Sections**:
  1. AppBar: Title `"Backup & Restore Excel"`.
  2. 14-Day Status Card: Status Icon, Title (`14sp` Bold), Timestamp text.
  3. Export Card: `CustomCard`, Title `"Export Data ke Excel (.xlsx)"`, Description, Button `"Export & Simpan Excel"` (`#00A884`, Height `48dp`).
  4. Import Card: `CustomCard`, Title `"Import / Restore Data dari Excel"`, Description, Button `"Pilih File Excel Backup"` (Outlined `#3B82F6`, Height `48dp`).

### Screen 9: MonthlyReportScreen (Variance Table & Position)
- **Purpose**: Financial reporting screen featuring continuous carry-over breakdown and Category Variance DataTable.
- **Frame**: `390 x 844 dp` (Scaffold BG `#F8FAFC`)
- **Layout**: SingleChildScrollView (Padding `16dp`) -> Column
- **Sections**:
  1. AppBar: Title `"Laporan: [Period]"`.
  2. Financial Position Card: Opening Balance, + Income, = Available, - Expenses, = Closing Balance (`#00A884` Bold).
  3. Category Variance Card: Title `"Laporan Variansi Anggaran per Kategori"`, Horizontal scrollable `DataTable` (Columns: Kategori, Alokasi, Aktual, Sisa, Status Badge).

---

## 13. UI States Matrix

```text
Global Masked State:
  - Masked (Default): Balance rendered as "Rp ••••••••", Eye Icon (visibility_off_outlined)
  - Unmasked: Balance rendered as formatted IDR (e.g. "Rp 10.000.000"), Eye Icon (visibility_outlined)

Button States:
  - Default: Brand Fill (#00A884 / #EF4444), White Text
  - Pressed: Material InkWell ripple overlay
  - Disabled: Greyed out background, non-interactive

Planned Expense Checklist States:
  - Unpaid: White tile, gray circle border, "Bayar" CTA button
  - Paid Normal: Light green tile (#F0FDF4), Teal checked icon, green amount text
  - Paid Overrun: Light green tile (#F0FDF4), Amber checked icon, warning badge "+Rp X Overrun"

Allocation Defisit State:
  - Live Sisa < 0: Red summary banner (#DC2626), Yellow warning text (#FEF08A), warning box
```

---

## 14. Responsive & Viewport Rules

- **Target Canvas Size**: `390 x 844 dp` (Mobile Portrait).
- **Horizontal Screen Padding**: `16dp` fixed outer margin (`AppSpacing.screenPadding`).
- **Modal Sheet Insets**: `20dp` horizontal and bottom padding (`AppSpacing.modalPadding`).
- **Dynamic Keyboard Inset**: Modal containers pad bottom dynamically with `MediaQuery.viewInsets.bottom`.
- **Bottom Clearance**: Dashboard adds `80dp` bottom spacing to prevent FAB overlap.

---

## 15. Accessibility & Readability Rules

1. **High Text Contrast**: Dark slate `#0F172A` text on `#FFFFFF` / `#F8FAFC` backgrounds; White text on `#00A884` primary buttons.
2. **Minimum Touch Target**: All CTA buttons use normalized height `48dp`. Icon buttons use minimum padding `8dp` around `20dp` icons.
3. **Multi-cue Status Indicators**: Over Budget status uses Red Tint BG (`#FCE8E6`) + Dark Red Text (`#C5221F`) + Explicit Text Label (`"Over Budget"`) + Red Progress Bar.

---

## 16. Assets Catalog

- **Typography**: Google Font `Roboto`.
- **Icons**: Material Icons vector set (`account_balance_wallet_outlined`, `analytics_outlined`, `settings_outlined`, `chevron_left`, `chevron_right`, `calendar_today`, `visibility_off_outlined`, `visibility_outlined`, `info_outline`, `warning_amber_rounded`, `category_outlined`, `tune`, `add`, `check_circle_outline`, `pending_actions_outlined`, `playlist_add_check`, `auto_awesome`, `payment`, `receipt_long_outlined`, `edit_outlined`, `delete_outline`, `file_upload_outlined`, `file_download_outlined`, `folder_open`, `verified_user_outlined`, `arrow_downward`, `arrow_upward`, `filter_list`, `close`).
- **Mockup Artifact References**: `aloca_dashboard_ui_1788589940084.jpg`, `aloca_allocation_ui_1788589980104.jpg`, `aloca_history_ui_1788589996009.jpg`.

---

## 17. Figma Layer Mapping Reference

```text
Flutter Concept                      Figma Layer Equivalent
---------------                      ----------------------
Scaffold                             Frame (Screen Container, 390x844)
SafeArea -> Column                   Vertical Auto Layout Frame (Padding 16dp, Gap 16dp)
SingleChildScrollView                Vertical Auto Layout Scroll Frame
CustomCard                           Frame (Radius 16dp, White BG, Shadow 0x0000000A)
ElevatedButton                       Component / Frame (Radius 12dp, Height 48dp, Fill #00A884)
TextField                            Component / Frame (Radius 12dp, Height 48-56dp, Fill #F8FAFC)
ChoiceChip                           Component / Frame (Radius 10dp, Fill #F1F5F9 or #00A884)
StatusBadge                          Component / Frame (Radius 6dp, Padding 6x2dp)
CustomProgressBar                    Component / Frame (Radius 3dp Pill, Height 6dp)
ModalBottomSheet                     Frame (Top Radius 20dp, White BG)
```

---

## 18. Flutter ↔ Figma Mapping

```text
Figma Variable                       Flutter Implementation Code
--------------                       ---------------------------
color/brand/primary                  AppColors.brandPrimary (lib/theme/app_colors.dart:8)
color/background/default            AppColors.pageBackground (lib/theme/app_colors.dart:14)
color/surface/default               AppColors.surfaceWhite (lib/theme/app_colors.dart:15)
color/text/primary                  AppColors.textPrimary (lib/theme/app_colors.dart:22)
typography/section/title             AppTypography.sectionTitle (lib/theme/app_typography.dart:53)
space/button/height                  AppSpacing.buttonHeight = 48.0 (lib/theme/app_spacing.dart:21)
radius/card                          AppRadius.radiusCard = Radius 16.0 (lib/theme/app_radius.dart:16)
radius/sheet                         AppRadius.radiusSheet = Top Radius 20.0 (lib/theme/app_radius.dart:17)
```

---

## 19. Visual Consistency Rules

1. **Token Mandatory**: Never use raw color hexes or arbitrary pixel paddings in screen widgets; always consume `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`.
2. **Card Standard**: All card containers must use `CustomCard` (`16dp` radius, `#FFFFFF` background, `4% opacity` shadow).
3. **Button Standard**: All primary and secondary buttons must be `48dp` tall with `12dp` radius.
4. **Sheet Standard**: All bottom sheets must have `20dp` top corner radius and `20dp` horizontal padding.
5. **Auto Layout**: Every frame and component generated in Figma must use native Figma Auto Layout.

---

## 20. Visual Inconsistency Resolutions Log

All 5 minor visual inconsistencies identified in Phase 1 have been explicitly harmonized and resolved in Phase 2:

1. **Button Heights**: Normalized from mixed `52dp/50dp/48dp` to uniform **`48.0dp`** (`AppSpacing.buttonHeight`).
2. **Modal Sheet Corner Radii**: Normalized from mixed `24dp/20dp` to uniform **`20.0dp` top radius** (`AppRadius.sheet`).
3. **Modal Sheet Horizontal Padding**: Normalized from mixed `16dp/20dp` to uniform **`20.0dp`** (`AppSpacing.xl`).
4. **Section Header Typography**: Normalized from mixed `16sp/15sp` to uniform **`15.0sp` bold `#1E293B`** (`AppTypography.sectionTitle`).
5. **Stat Label Typography**: Normalized from mixed `13sp/11sp` to uniform **`11.0sp` medium `#64748B`** (`AppTypography.labelSmall`).

---

## 21. Figma Agent Generation Rules

### Rule 1: Master Authority
Use this document as the sole visual source of truth.

### Rule 2: Token-First Construction
Do not invent raw colors, font sizes, or paddings. Use defined Figma color variables, text styles, and spacing tokens.

### Rule 3: Native Figma Layers & Auto Layout
All layers must be native, fully editable Figma shapes, text layers, frames, and components with Auto Layout enabled. Do not use flattened bitmap images.

### Rule 4: Component Reuse
Create master Figma components on Page `02 Components` first, then instantiate component instances across screens on Page `04 Screens`.

### Rule 5: Financial Semantics Preservation
Strictly apply the visual rules for financial states (*Total Available Teal Gradient*, *Allocated Blue*, *Expense Red*, *Income Green*, *Over Budget Badges*).

### Rule 6: Zero Logic Alteration
Do not alter application workflow or business model.

---

## 22. Figma Generation Sequence

Figma Agent must execute generation in the following strict order:

1. Page `00 Cover`: Generate thumbnail & overview card.
2. Page `01 Foundations`: Generate Color Swatches, Typography Scale, Spacing Tokens, Radius Tokens, Elevation Cards, Iconography Catalog.
3. Page `02 Components`: Build Master Components & Variants (`Button/Primary`, `Input/TextField`, `Badge/Status`, `Card/Base`, `Financial/ProgressBar`, `Item/PlannedExpenseTile`, `Item/TransactionTile`, `Sheet/ModalContainer`).
4. Page `03 Patterns`: Assemble Composed Patterns (Financial Position Summary, 2-Pass Allocation Card, Planned Checklist, History List).
5. Page `04 Screens`: Construct the 9 Native Screens (`InitialSetupScreen`, `DashboardScreen`, `CategoryPlannedExpensesSheet`, `QuickAddTransactionScreen`, `TransactionsListScreen`, `AllocationManagementScreen`, `CategoriesScreen`, `BackupRestoreScreen`, `MonthlyReportScreen`).

---

## 23. Validation Checklist for Figma Agent

### Foundations Validation
- [ ] All colors use defined semantic variables (`color/brand/primary`, `color/background/default`, etc.).
- [ ] Typography uses defined text styles (`typography/heading/large`, `typography/section/title`, etc.).
- [ ] Spacing scale uses defined tokens (`space/sm`, `space/md`, `space/lg`, `space/xl`).
- [ ] Corner radii match tokens (`16dp` cards, `20dp` top sheets, `12dp` buttons).

### Components Validation
- [ ] Reusable master components created on Page `02 Components`.
- [ ] Auto Layout enabled on all component frames.
- [ ] Component variants constructed for states (Normal, Hover/Pressed, Disabled, Paid, Overrun, Masked).

### Screens & Quality Validation
- [ ] All 9 documented screens generated natively on Page `04 Screens`.
- [ ] Screens constructed from component instances.
- [ ] Financial semantics (Total Available, Expense, Remaining, Over Budget) visually accurate.
- [ ] No flattened screenshots used; all layers fully editable.

---

## 24. Open Decisions

`No unresolved design decisions identified.`

All token values, component specifications, financial visual rules, and screen layouts have been fully resolved and harmonized between Phase 1 and Phase 2.
