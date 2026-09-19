# Design Tokens

This document details all visual tokens extracted directly from the Aloca Flutter codebase.

---

## 🎨 Color Palette

### 1. Primary & Brand Colors

| Token Name | Flutter Value | Hex | Usage | Source File |
| :--- | :--- | :--- | :--- | :--- |
| **Brand Primary / Seed** | `Color(0xFF00A884)` | `#00A884` | Primary brand color, primary buttons, active tabs, header icons, success highlights | `lib/app.dart:31-32` |
| **Brand Primary Dark** | `Color(0xFF008B74)` | `#008B74` | Gradient end color in Total Available card | `lib/app.dart:33`, `lib/screens/dashboard/dashboard_screen.dart:287` |
| **Brand Primary Container Tint** | `Color(0x1A00A884)` / `withOpacity(0.1)` | `#00A8841A` | Category icon container background, onboarding icon background | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:399`, `lib/screens/onboarding/initial_setup_screen.dart:32` |

### 2. Neutral & Background Colors

| Token Name | Flutter Value | Hex | Usage | Source File |
| :--- | :--- | :--- | :--- | :--- |
| **Page Background** | `Color(0xFFF8FAFC)` | `#F8FAFC` | Scaffold background color for all main screens | `lib/app.dart:34,36` |
| **Surface White** | `Colors.white` | `#FFFFFF` | Card background, bottom sheet background, app bar background, dialog background | `lib/widgets/custom_card.dart:13`, `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:358` |
| **Card Sub-surface Gray** | `Color(0xFFF8FAFC)` | `#F8FAFC` | Inner header cards in sheets and dialogs | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:390` |
| **Input Fill Gray** | `Color(0xFFF8FAFC)` / `Color(0xFFF1F5F9)` | `#F8FAFC` / `#F1F5F9` | TextField fill color, info containers, unselected tab background | `lib/screens/transaction/quick_add_transaction_screen.dart:121`, `lib/screens/settings/allocation_management_screen.dart:374` |
| **Divider & Border Gray** | `Colors.grey.shade300` / `Color(0xFFCBD5E1)` | `#E2E8F0` / `#D1D5DB` | TextField borders, drag handle indicator, horizontal dividers | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:381`, `lib/screens/onboarding/initial_setup_screen.dart:88` |

### 3. Typography Text Colors

| Token Name | Flutter Value | Hex | Usage | Source File |
| :--- | :--- | :--- | :--- | :--- |
| **Text Primary Dark** | `Color(0xFF0F172A)` | `#0F172A` | Screen titles, primary card titles, section headings | `lib/screens/dashboard/dashboard_screen.dart:35` |
| **Text Primary Slate** | `Color(0xFF1E293B)` | `#1E293B` | Section titles in bottom sheets | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:624` |
| **Text Secondary Muted** | `Color(0xFF64748B)` | `#64748B` | Subtitles, field labels, metadata text | `lib/screens/dashboard/dashboard_screen.dart:415` |
| **Text Tertiary Hint** | `Color(0xFF94A3B8)` / `Colors.grey` | `#94A3B8` | Sub-hints, inactive icons, trailing arrows | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:251` |
| **Text Inverse White** | `Colors.white` | `#FFFFFF` | Text on primary cards, button labels | `lib/screens/dashboard/dashboard_screen.dart:328` |

### 4. Semantic & Feedback Colors

| Token Name | Flutter Value | Hex | Usage | Source File |
| :--- | :--- | :--- | :--- | :--- |
| **Expense / Error Red** | `Color(0xFFEF4444)` / `Color(0xFFDC2626)` / `Colors.red` | `#EF4444` / `#DC2626` | Non-planned amounts, expense indicators, delete buttons, overallocated banners | `lib/screens/dashboard/dashboard_screen.dart:379`, `lib/screens/transaction/quick_add_transaction_screen.dart:71` |
| **Expense Tint Light** | `Color(0xFFFEF2F2)` / `Color(0xFFFCE8E6)` | `#FEF2F2` / `#FCE8E6` | Over Budget badge background, overallocated banner background | `lib/widgets/status_badge.dart:24`, `lib/screens/dashboard/dashboard_screen.dart:458` |
| **Income / Success Green** | `Color(0xFF10B981)` / `Color(0xFF00A884)` | `#10B981` | Income indicators, positive remaining budgets, lunas status | `lib/screens/transaction/transactions_list_screen.dart:223` |
| **Success Tint Light** | `Color(0xFFDCFCE7)` / `Color(0xFFF0FDF4)` | `#DCFCE7` / `#F0FDF4` | Lunas badge background, paid item tile background | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:425` |
| **Warning / Overrun Amber** | `Color(0xFFF59E0B)` / `Color(0xFFD97706)` | `#F59E0B` / `#D97706` | Overrun payment indicators, 14-day backup warning icon | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:792`, `lib/screens/settings/backup_restore_screen.dart:57` |
| **Warning Tint Light** | `Color(0xFFFEF3C7)` / `Color(0xFFFFFBEB)` | `#FEF3C7` / `#FFFBEB` | Partial lunas badge background, 14-day backup warning card | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:426`, `lib/screens/settings/backup_restore_screen.dart:48` |
| **Info / Allocation Blue** | `Color(0xFF3B82F6)` / `Color(0xFF2563EB)` | `#3B82F6` / `#2563EB` | Total Allocated stat text, unallocated banner background, category filter chip | `lib/screens/dashboard/dashboard_screen.dart:369`, `lib/screens/transaction/transactions_list_screen.dart:114` |
| **Info Tint Light** | `Color(0xFFEFF6FF)` / `Color(0xFFE8F0FE)` | `#EFF6FF` / `#E8F0FE` | Unallocated banner background, On Budget badge background | `lib/screens/dashboard/dashboard_screen.dart:436`, `lib/widgets/status_badge.dart:21` |

---

## 📐 Shape, Corner Radii & Surfaces

| Component | Radius Value | Corner Style | Source File |
| :--- | :--- | :--- | :--- |
| **CustomCard** | `16.0dp` | `BorderRadius.circular(16.0)` | `lib/widgets/custom_card.dart:22` |
| **Modal Bottom Sheet (Top)** | `20.0dp` / `24.0dp` | `BorderRadius.vertical(top: Radius.circular(...))` | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:360` |
| **Banner Container** | `12.0dp` | `BorderRadius.circular(12)` | `lib/screens/dashboard/dashboard_screen.dart:291` |
| **Elevated / Outlined Button**| `12.0dp` | `RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))` | `lib/screens/onboarding/initial_setup_screen.dart:158` |
| **TextField Border** | `12.0dp` | `OutlineInputBorder(borderRadius: BorderRadius.circular(12))` | `lib/screens/onboarding/initial_setup_screen.dart:134` |
| **Tab / Choice Chip** | `10.0dp` / `12.0dp` | `BorderRadius.circular(10)` | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:561` |
| **Status Badge** | `6.0dp` / `12.0dp` | `BorderRadius.circular(6)` / `BorderRadius.circular(12)` | `lib/widgets/status_badge.dart:35` |
| **Drag Handle Indicator** | `2.0dp` (height 4dp, width 40dp) | `BorderRadius.circular(2)` | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:382` |

---

## ☀️ Elevation & Shadows

| Surface | Elevation / Shadow Value | Blur / Offset | Source File |
| :--- | :--- | :--- | :--- |
| **AppBar** | `0` (Flat) | N/A | `lib/screens/dashboard/dashboard_screen.dart:31` |
| **CustomCard Shadow** | `Color(0x0A000000)` (`Colors.black.withOpacity(0.04)`) | `blurRadius: 10, offset: Offset(0, 4)` | `lib/widgets/custom_card.dart:24-28` |
| **FAB Elevation** | Standard Material 3 Default | Standard M3 FAB Shadow | `lib/screens/dashboard/dashboard_screen.dart:184` |
