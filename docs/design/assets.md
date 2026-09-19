# Visual Asset Inventory

This document details all visual icons, typography fonts, and graphics referenced in the Aloca codebase.

---

## 🎨 Asset Summary Table

| Asset | Location / Source | Type | Usage | Figma Recommendation |
| :--- | :--- | :--- | :--- | :--- |
| **Roboto Font Family** | `lib/app.dart:29` | TTF / System Font | Primary application typography | Import Google Font "Roboto" in Figma |
| **Material Icons Set** | `flutter/material.dart` | Vector Icon Font | All standard UI icons (wallet, calendar, analytics, eye mask, add, edit, delete, etc.) | Use Material Symbols / Material Icons Figma Plugin |
| **Cupertino Icons Set** | `cupertino_icons: ^1.0.6` | Vector Icon Font | iOS compatibility icons fallback | Available in standard Figma icon libraries |
| **Dashboard Mockup Image** | Artifacts Directory | JPG (`aloca_dashboard_ui...jpg`) | UI Reference visual mockup | Attached in Walkthrough carousel |
| **Allocation Mockup Image** | Artifacts Directory | JPG (`aloca_allocation_ui...jpg`) | UI Reference visual mockup | Attached in Walkthrough carousel |
| **History Mockup Image** | Artifacts Directory | JPG (`aloca_history_ui...jpg`) | UI Reference visual mockup | Attached in Walkthrough carousel |

---

## 🔣 Complete Material Icons Catalog in Code

```text
Icon Symbol                         Usage Screen / Component
------------------                  ------------------------
account_balance_wallet_outlined     InitialSetupScreen header icon
analytics_outlined                  DashboardScreen AppBar action, Drawer item
settings_outlined                   DashboardScreen AppBar action
chevron_left                        DashboardScreen period bar
chevron_right                       DashboardScreen period bar, Drawer, Category tiles
calendar_today / calendar_month     DashboardScreen period selector, InitialSetup date tile
visibility_outlined                 DashboardScreen summary card (Unmasked balance)
visibility_off_outlined             DashboardScreen summary card (Masked balance)
info_outline                        DashboardScreen unallocated banner, Allocation sheet info
warning_amber_rounded               DashboardScreen overallocated banner, Backup status card
category_outlined                   DashboardScreen empty state, Category Sheet header icon, Drawer item
tune / tune_outlined                DashboardScreen "Kelola" button, Edit Allocation Sheet header icon
add                                 DashboardScreen FAB, Category Sheet add CTA, Categories FAB
check_circle_outline                DashboardScreen category planned badge (All Paid)
pending_actions_outlined            DashboardScreen category planned badge (Partial Paid)
playlist_add_check                  Allocation Management category planned badge button
auto_awesome                        Allocation Management template picker action
payment                             Category Sheet 1-Tap Pay dialog header
receipt_long_outlined               Category Sheet empty unplanned state, Drawer item
edit_outlined                       CategoriesScreen edit button
delete_outline                      CategoriesScreen delete button, TransactionsList delete button
file_upload_outlined                BackupRestoreScreen Export Card icon
file_download_outlined              BackupRestoreScreen Import Card icon
folder_open                         BackupRestoreScreen File picker button icon
verified_user_outlined              BackupRestoreScreen Backup status OK icon
arrow_downward                      TransactionsListScreen Income item icon
arrow_upward                        TransactionsListScreen Expense item icon
filter_list                         TransactionsListScreen Active filter bar icon
close                               QuickAddTransactionScreen close button, Filter dismiss icon
checklist_rtl_outlined              Category Sheet empty planned expenses state icon
```
