# Responsive & Layout Specification

This document details the responsive constraints, viewport boundaries, dynamic padding, and scroll behaviors observed in the Aloca codebase.

---

## 📱 Viewport & Layout Constraints

* **Primary Target Viewport**: Mobile Portrait (`360dp` to `412dp` width, `800dp` to `915dp` height). Standard Figma frame size recommendation: **`390 x 844 dp` (iPhone 14/15 / Android Standard)**.
* **Orientation Support**: Mobile Portrait default. No explicit landscape grid or tablet split view overrides implemented.
* **Safe Area Handling**: Every main screen wraps its body in a `SafeArea` widget to prevent status bar and home indicator occlusion (`lib/screens/dashboard/dashboard_screen.dart:62`).

---

## 📜 Scroll & Viewport Behavior

1. **Main Scrollable Screens**:
   - `DashboardScreen`, `InitialSetupScreen`, `AllocationManagementScreen`, `BackupRestoreScreen`, `MonthlyReportScreen`.
   - Implement `SingleChildScrollView` wrapped around vertical `Column` layouts.
   - Child `ListView.separated` widgets inside scroll views use `shrinkWrap: true` and `physics: NeverScrollableScrollPhysics()`.

2. **Modal Bottom Sheets**:
   - `CategoryPlannedExpensesSheet`, `QuickAddTransactionScreen`, `EditAllocationBottomSheet`, `TemplatePickerSheet`.
   - Wrap content in `BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85)` (Max height 85% of screen height).
   - Set `isScrollControlled: true` and `backgroundColor: Colors.transparent`.
   - Dynamically pad bottom inset for software keyboard:
     ```dart
     padding: EdgeInsets.only(
       bottom: MediaQuery.of(context).viewInsets.bottom + 16,
     )
     ```

3. **Fixed Bottom Margin**:
   - `DashboardScreen` adds `SizedBox(height: 80dp)` at the end of its scroll view to ensure the bottom content is not obscured by the extended `FloatingActionButton` (`lib/screens/dashboard/dashboard_screen.dart:179`).
