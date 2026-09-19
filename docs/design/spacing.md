# Spacing Analysis

This document inventories the exact spacing tokens and layout paddings implemented across the Aloca Flutter application.

---

## 📏 Spacing Scale Inventory

The application uses an informal spacing scale ranging from `2dp` to `80dp`:

| Spacing Value | Occurrences | Typical Usage | Source Examples |
| :--- | :--- | :--- | :--- |
| **2dp** | High | Vertical micro gaps between title and subtitle text, status badge vertical padding | `lib/widgets/status_badge.dart:32`, `lib/screens/dashboard/dashboard_screen.dart:417` |
| **4dp** | Very High | Small gaps between icon & text, vertical padding in small chips, badge horizontal padding | `lib/screens/dashboard/dashboard_screen.dart:294`, `lib/screens/settings/allocation_management_screen.dart:371` |
| **6dp** | High | Gaps in warning row, padding in status badges | `lib/widgets/status_badge.dart:32`, `lib/screens/dashboard/dashboard_screen.dart:543` |
| **8dp** | Extremely High | Standard vertical list item spacing, element gaps, dialog action gaps | `lib/screens/dashboard/dashboard_screen.dart:133`, `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:491` |
| **10dp** | High | Element gaps in rows, drag handle bottom gap | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:408`, `lib/screens/transaction/transactions_list_screen.dart:177` |
| **12dp** | Extremely High | Standard ListView item separator, card inner component gaps, icon paddings | `lib/screens/dashboard/dashboard_screen.dart:171`, `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:386` |
| **14dp** | Medium | Internal padding in summary banner containers, date picker tile vertical padding | `lib/screens/dashboard/dashboard_screen.dart:284`, `lib/screens/onboarding/initial_setup_screen.dart:84` |
| **16dp** | Extremely High | **Standard Screen Outer Padding**, CustomCard default padding, bottom sheet padding | `lib/widgets/custom_card.dart:12`, `lib/screens/dashboard/dashboard_screen.dart:64` |
| **20dp** | High | Bottom sheet horizontal padding, large icon size, dialog outer padding | `lib/screens/transaction/quick_add_transaction_screen.dart:34`, `lib/screens/settings/allocation_management_screen.dart:589` |
| **24dp** | High | Onboarding screen outer padding, section gaps before main CTA buttons | `lib/screens/onboarding/initial_setup_screen.dart:24,41`, `lib/screens/transaction/quick_add_transaction_screen.dart:183` |
| **32dp** | Medium | Large onboarding header gaps | `lib/screens/onboarding/initial_setup_screen.dart:28,58` |
| **48dp / 50dp / 52dp** | High | Standard CTA Button heights | `lib/screens/settings/allocation_management_screen.dart:414`, `lib/screens/onboarding/initial_setup_screen.dart:152` |
| **80dp** | Low | Bottom scroll margin on Dashboard to prevent FloatingActionButton overlap | `lib/screens/dashboard/dashboard_screen.dart:179` |

---

## 📌 Outer Page & Modal Padding Patterns

```text
Screen Outer Padding: 16.0dp (Dashboard, Allocation, Transactions, Categories, Backup, Report)
Onboarding Outer Padding: 24.0dp (InitialSetupScreen)
Modal Sheet Padding: 16.0dp to 20.0dp (with dynamic MediaQuery.viewInsets.bottom)
Card Internal Padding: 12.0dp or 16.0dp (CustomCard)
ListView Separator Height: 8.0dp, 10.0dp, or 12.0dp
```
