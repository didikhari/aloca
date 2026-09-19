# Component Inventory

This document details all reusable UI components and recurring component patterns identified in the Aloca codebase.

---

## 🧩 Shared Core Widgets

### 1. `CustomCard`
* **Source**: `lib/widgets/custom_card.dart`
* **Class**: `CustomCard` (`StatelessWidget`)
* **Properties**: `child` (`Widget`), `padding` (`EdgeInsetsGeometry`, default `16dp`), `backgroundColor` (`Color`, default `Colors.white`), `onTap` (`VoidCallback?`)
* **Visual Specs**:
  - Background: `backgroundColor` (default `#FFFFFF`)
  - Border Radius: `16.0dp`
  - Shadow: `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))`
  - InkWell Splash: Material wrapper with `Colors.transparent` and `onTap` feedback
* **Used By**: Dashboard Screen, Allocation Management Screen, Transactions List Screen, Categories Screen, Backup Screen, Monthly Report Screen, Category Planned Expenses Sheet

### 2. `CustomProgressBar`
* **Source**: `lib/widgets/progress_bar.dart`
* **Class**: `CustomProgressBar` (`StatelessWidget`)
* **Properties**: `ratio` (`double`, 0.0 to 1.0+), `color` (`Color`), `height` (`double`, default `8.0dp`)
* **Visual Specs**:
  - Track Background: `color.withOpacity(0.15)`
  - Track Border Radius: `height / 2` (Pill shape)
  - Fill Container: `color` clamped to `0.0 - 1.0` ratio via `FractionallySizedBox`
* **Used By**: Dashboard Screen Category Progress Cards

### 3. `StatusBadge`
* **Source**: `lib/widgets/status_badge.dart`
* **Class**: `StatusBadge` (`StatelessWidget`)
* **Properties**: `status` (`String`, 'Under Budget', 'On Budget', 'Over Budget')
* **Visual Specs**:
  - Padding: `symmetric(horizontal: 6dp, vertical: 2dp)`
  - Border Radius: `6.0dp`
  - Typography: `10sp`, `FontWeight.w500`
  - Variants:
    - **Under Budget**: Background `#E6F4EA`, Text `#137333` (Green)
    - **On Budget**: Background `#E8F0FE`, Text `#1A73E8` (Blue)
    - **Over Budget**: Background `#FCE8E6`, Text `#C5221F` (Red)
* **Used By**: Dashboard Screen Category Cards

---

## 🎨 Recurring Application Component Patterns

### 4. Financial Position Summary Card
* **Source**: `lib/screens/dashboard/dashboard_screen.dart:273-405`
* **Structure**: `CustomCard` containing a Gradient Banner and a 2x2 Stats Grid
* **Visual Specs**:
  - Banner Gradient: `LinearGradient([#00A884, #008B74])`, Radius `12dp`
  - Hero Amount: `20sp` / `22sp`, Semi-bold / Bold, White text
  - Sub-row Dividers: `Colors.white30`, height `14dp`
  - Stat Items: Label `11sp` (`#64748B`), Value `13sp` Semi-bold (Blue `#3B82F6`, Red `#EF4444`, Green `#10B981`, Dark `#0F172A`)

### 5. Period Selector Bar
* **Source**: `lib/screens/dashboard/dashboard_screen.dart:196-271`
* **Structure**: `CustomCard` with `symmetric(horizontal: 16dp, vertical: 12dp)` padding
* **Visual Specs**:
  - Left/Right Navigation Chevrons: `IconButton(icon: Icon(Icons.chevron_left))`
  - Center Date Picker Trigger: `InkWell` showing calendar icon (`#00A884`), Display Text `16sp` Bold (`#0F172A`), Arrow Dropdown icon

### 6. Category Progress Card
* **Source**: `lib/screens/dashboard/dashboard_screen.dart:478-620`
* **Structure**: `CustomCard` with `padding: EdgeInsets.all(12dp)`
* **Visual Specs**:
  - Header: Category color indicator dot (`10x10dp`), Category Name (`13sp` Bold), `StatusBadge`
  - Body: `CustomProgressBar` (height `6.0dp`), Terpakai vs Sisa amount row (`11sp`)
  - Footer (Optional): Planned Expenses badge container (`#F0FDF4` / `#FFFBEB`, border `1dp`, height padding `4dp`)

### 7. Unallocated / Overallocated Warning Banners
* **Source**: `lib/screens/dashboard/dashboard_screen.dart:432-476`, `lib/screens/settings/allocation_management_screen.dart:214-239`
* **Visual Specs**:
  - **Unallocated Banner**: Background `#EFF6FF`, Border `#93C5FD`, Icon `#2563EB` (Info), Text `#1E40AF`
  - **Overallocated Banner**: Background `#FEF2F2`, Border `#FCA5A5`, Icon `#DC2626` (Warning), Text `#991B1B`

### 8. ChoiceChip Filter Tab Bar
* **Source**: `lib/screens/transaction/transactions_list_screen.dart:85-101`, `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:551-606`
* **Visual Specs**:
  - Unselected: Background `#F1F5F9` / Default, Text `#64748B` / Grey
  - Selected: Background `#00A884` (Sheet) or `#00A884.withOpacity(0.15)` (Transactions List), Text White or `#00A884` Bold
