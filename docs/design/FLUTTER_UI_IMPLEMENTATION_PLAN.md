# Flutter UI Implementation & Harmonization Plan

This document outlines the execution plan for implementing the refined design system across all 9 screens of the Aloca application.

---

## 📋 Implementation Checklist by Phase

### Phase 2.1: Design Tokens & Theme Foundations
- [x] `lib/theme/app_colors.dart` — Centralized color palette & semantic feedback tokens.
- [x] `lib/theme/app_typography.dart` — Standardized font hierarchy and styles.
- [x] `lib/theme/app_spacing.dart` — Normalized spacing scale and button height (`48dp`).
- [x] `lib/theme/app_radius.dart` — Normalized corner radii (`16dp` cards, `20dp` sheets, `12dp` inputs).
- [x] `lib/theme/app_theme.dart` — Global MaterialApp ThemeData.
- [x] `lib/app.dart` — Connect global `AppTheme.lightTheme`.

### Phase 2.2: Shared Components Refinement
- [x] `lib/widgets/custom_card.dart` — Refined with `AppColors`, `AppRadius`, `AppSpacing`.
- [x] `lib/widgets/progress_bar.dart` — Refined with pill radius `AppRadius.md`.
- [x] `lib/widgets/status_badge.dart` — Refined with `AppColors`, `AppRadius.radiusSm`, `AppTypography.captionBadge`.

### Phase 2.3: Screen UI Refinement & Token Consumption
- [x] `lib/screens/onboarding/initial_setup_screen.dart` — Harmonize button height (52dp -> 48dp), padding, colors.
- [x] `lib/screens/dashboard/dashboard_screen.dart` — Harmonize section header font size (15sp), stat label sizes (11sp), colors.
- [x] `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart` — Harmonize modal top radius (20dp), horizontal padding (20dp), button heights.
- [x] `lib/screens/transaction/quick_add_transaction_screen.dart` — Harmonize modal top radius (24dp -> 20dp), horizontal padding (20dp), button height (48dp).
- [x] `lib/screens/transaction/transactions_list_screen.dart` — Harmonize filter chips, colors, typography.
- [x] `lib/screens/settings/allocation_management_screen.dart` — Harmonize button height (50dp -> 48dp), modal top radius (20dp), padding.
- [x] `lib/screens/settings/categories_screen.dart` — Harmonize FAB, dialogs, card padding.
- [x] `lib/screens/settings/backup_restore_screen.dart` — Harmonize status card, export/import button heights (48dp).
- [x] `lib/screens/reports/monthly_report_screen.dart` — Harmonize report table styling, headers, variance badge tokens.

---

## 🔒 Business Logic Risk Assessment
- **Risk Level**: LOW / ZERO
- **Mitigation**: All state management, Riverpod notifiers, Hive persistence, Excel export/import, and 2-pass allocation logic are strictly preserved.
