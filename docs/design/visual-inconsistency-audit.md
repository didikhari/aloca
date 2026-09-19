# Visual Inconsistency Audit

This document logs all empirical visual inconsistencies identified during the Phase 1 inspection of the Aloca Flutter codebase.

---

## 🔍 Audit Summary Table

| Category | Issue Description | Locations / Source Code | Current Implemented Values | Classification | Potential Impact |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Button Heights** | Inconsistent primary CTA button heights across screens | • `initial_setup_screen.dart:152`<br>• `allocation_management_screen.dart:414`<br>• `quick_add_transaction_screen.dart:187` | `52dp` (Onboarding)<br>`50dp` (Allocation)<br>`48dp` (Quick Add) | `MINOR_INCONSISTENCY` | Slight visual jump in button thickness between screens |
| **Modal Sheet Corner Radius** | Inconsistent top corner radii on bottom sheet containers | • `category_planned_expenses_sheet.dart:360`<br>• `allocation_management_screen.dart:583`<br>• `quick_add_transaction_screen.dart:37` | `20dp` (Category Sheet)<br>`20dp` (Edit Sheet)<br>`24dp` (Quick Add Sheet) | `MINOR_INCONSISTENCY` | Minor curvature disparity across modal sheets |
| **Modal Sheet Outer Padding** | Inconsistent horizontal padding inside modal containers | • `quick_add_transaction_screen.dart:34`<br>• `category_planned_expenses_sheet.dart:362`<br>• `allocation_management_screen.dart:586` | `20dp` (Quick Add)<br>`16dp` (Category Sheet)<br>`20dp` (Allocation Sheet) | `MINOR_INCONSISTENCY` | Slight horizontal margin alignment differences in modals |
| **Section Header Typography** | Section title headings use slightly different font sizes | • `dashboard_screen.dart:96`<br>• `allocation_management_screen.dart:250`<br>• `category_planned_expenses_sheet.dart:620`<br>• `monthly_report_screen.dart:88` | `15sp` Bold (Dashboard)<br>`16sp` Bold (Allocation)<br>`15sp` Bold (Category Sheet)<br>`16sp` Bold (Monthly Report) | `MINOR_INCONSISTENCY` | Subtle scale variance for identical semantic headings |
| **Stat Label Typography** | Sub-label text sizes vary across summary cards | • `dashboard_screen.dart:415`<br>• `allocation_management_screen.dart:153`<br>• `category_planned_expenses_sheet.dart:451` | `11sp` (Dashboard Stats)<br>`13sp` (Allocation Summary)<br>`11sp` (Sheet Header Stats) | `MINOR_INCONSISTENCY` | Minor text sizing difference for sub-labels |
| **Card Shadow & Background** | Container shadows and card background colors | • `lib/widgets/custom_card.dart:21,25` | `#FFFFFF` background, `Blur 10, Offset(0, 4), Opacity 0.04` | `CONSISTENT` | 100% consistent across all cards |
| **Scaffold Page Background** | Main background color for all screens | • `lib/app.dart:34,36` | `#F8FAFC` across all 9 screens | `CONSISTENT` | 100% consistent across all screens |
| **AppBar Elevation & Style** | Top AppBars elevation, background, and text colors | • All screen files in `lib/screens/` | `elevation: 0`, `backgroundColor: Colors.white`, `foregroundColor: #0F172A` | `CONSISTENT` | 100% consistent across all AppBars |

---

## 📌 Resolution Status in Phase 2

All 5 minor visual inconsistencies identified in Phase 1 have been successfully **harmonized and resolved in Phase 2**:

1. **Button Heights**: Normalized to `48.0dp` (`AppSpacing.buttonHeight`) across all screens.
2. **Modal Sheet Corner Radii**: Normalized to `20.0dp` (`AppRadius.sheet`) across all bottom sheets.
3. **Modal Sheet Horizontal Padding**: Normalized to `20.0dp` (`AppSpacing.xl`) across all modal sheets.
4. **Section Header Typography**: Normalized to `15.0sp` bold `#1E293B` (`AppTypography.sectionTitle`) across all screens.
5. **Stat Label Typography**: Normalized to `11.0sp` medium `#64748B` (`AppTypography.labelSmall`) across all stat containers.
