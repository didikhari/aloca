# Typography Analysis

This document details the typography styles and hierarchy used throughout the Aloca Flutter codebase.

---

## 🔤 Font Family
* **Primary Family**: `Roboto` (Defined globally in `lib/app.dart:29`)
* **Fallback**: Standard Flutter Material 3 system font stack

---

## 📊 Semantic Typography Hierarchy

### 1. Display & Screen Titles

| Semantic Style | Size | Weight | Color | Usage | Source File |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Display Large** | `24sp` | `FontWeight.bold` | `#0F172A` / `#FFFFFF` | Welcome onboarding title, Drawer header title | `lib/screens/onboarding/initial_setup_screen.dart:45`, `lib/screens/dashboard/dashboard_screen.dart:633` |
| **Display Medium** | `22sp` | `FontWeight.bold` | `#FFFFFF` | Total Available hero amount (Allocation Screen) | `lib/screens/settings/allocation_management_screen.dart:182` |
| **Display Small** | `20sp` | `FontWeight.w600` / `bold` | `#FFFFFF` / `#0F172A` | Total Available hero amount (Dashboard), Quick Add Amount Input | `lib/screens/dashboard/dashboard_screen.dart:329`, `lib/screens/transaction/quick_add_transaction_screen.dart:112` |

### 2. Headings & Section Titles

| Semantic Style | Size | Weight | Color | Usage | Source File |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Heading Large** | `20sp` | `FontWeight.bold` | `#0F172A` | AppBar Title ("Aloca") | `lib/screens/dashboard/dashboard_screen.dart:37` |
| **Heading Medium** | `18sp` | `FontWeight.bold` | `#0F172A` | Category Sheet title, Edit Modal titles, Template sheet title | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:413`, `lib/screens/settings/allocation_management_screen.dart:627` |
| **Heading Small** | `16sp` | `FontWeight.bold` / `w600` | `#0F172A` | Period selector text, Section headers, Card title headers | `lib/screens/dashboard/dashboard_screen.dart:245`, `lib/screens/settings/allocation_management_screen.dart:250` |

### 3. Body Text & Subtitles

| Semantic Style | Size | Weight | Color | Usage | Source File |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Section Title** | `15sp` | `FontWeight.bold` | `#1E293B` / `#0F172A` | Section title ("Daftar Rencana Pengeluaran"), Item list primary title | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:620`, `lib/screens/transaction/transactions_list_screen.dart:238` |
| **Body Primary** | `14sp` | `FontWeight.bold` / `normal` | `#0F172A` / `#64748B` | Category item names, field input text, subtitle explanations | `lib/screens/settings/allocation_management_screen.dart:291`, `lib/screens/onboarding/initial_setup_screen.dart:54` |
| **Body Secondary** | `13sp` | `FontWeight.bold` / `w600` / `normal` | `#64748B` / `#00A884` | Helper hints, tab labels, stat values, dialog descriptions | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:232`, `lib/screens/dashboard/dashboard_screen.dart:423` |

### 4. Labels, Badges & Captions

| Semantic Style | Size | Weight | Color | Usage | Source File |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Label Standard** | `12sp` | `FontWeight.bold` / `w600` / `normal` | `#64748B` / `#FFFFFF` | Card stat values, sub-labels, paid badge text | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:432`, `lib/screens/dashboard/dashboard_screen.dart:342` |
| **Label Small** | `11sp` | `FontWeight.w600` / `w500` / `normal` | `#64748B` / `#00A884` / `#EF4444` | Stat card headers ("Alokasi Anggaran", "Sisa Anggaran"), badge sub-info | `lib/screens/dashboard/widgets/category_planned_expenses_sheet.dart:450`, `lib/screens/dashboard/dashboard_screen.dart:414` |
| **Caption / Badge** | `10sp` | `FontWeight.w500` | `#137333` / `#1A73E8` / `#C5221F` | Category status badge text ("Under Budget", "On Budget", "Over Budget") | `lib/widgets/status_badge.dart:41` |

---

## 🔍 Identified Typography Variances

1. **Section Header Sizes**:
   - `dashboard_screen.dart` uses `15sp` bold for section titles.
   - `allocation_management_screen.dart` uses `16sp` bold for section titles.
   - `category_planned_expenses_sheet.dart` uses `15sp` bold for section titles.
2. **Stat Label Sizes**:
   - Summary stat labels use `11sp` (`Color(0xFF64748B)`) in `dashboard_screen.dart`.
   - Summary stat labels use `12sp` (`Color(0xFF64748B)`) in `allocation_management_screen.dart`.
