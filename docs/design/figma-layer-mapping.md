# Figma Layer Mapping

This document maps the implementation hierarchy of Flutter widgets to proposed Figma frame and layer structures.

---

## 1. Dashboard Screen Hierarchy Mapping

```text
Flutter Widget Tree                        Proposed Figma Layer Hierarchy
-------------------                        ------------------------------
Scaffold                                   Frame: Dashboard Screen (390 x 844)
├── AppBar                                 ├── App Bar
│   ├── Title ("Aloca")                    │   ├── Text: "Aloca"
│   └── Actions ([Analytics, Settings])     │   └── Row: Action Icons [Report, Settings]
├── Drawer                                 ├── Navigation Drawer (Hidden Frame)
└── SafeArea                               └── Content Scroll (Frame)
    └── SingleChildScrollView                  ├── Period Selector Bar (Frame)
        └── Column                             │   ├── Button: Prev Month Chevron
            ├── _buildPeriodSelectorBar        │   ├── Row: Date Picker Text & Icon
            ├── _buildSummaryCard              │   └── Button: Next Month Chevron
            │   ├── Total Available Banner     ├── Summary Card (Frame)
            │   └── Stats Grid                 │   ├── Banner: Total Available (Teal Gradient)
            ├── Warning Banner (Conditional)   │   │   ├── Text: "Total Dana Tersedia"
            ├── Section Header ("Alokasi...")  │   │   ├── Text: Hero Balance ("Rp ••••••••")
            ├── ListView.separated             │   │   └── Row: Opening vs Income
            │   └── _buildCategoryCard         │   └── Stats Grid (2x2 Frame)
            └── FloatingActionButton           │       ├── Total Dialokasi Stat
                                               │       ├── Pengeluaran Aktual Stat
                                               │       ├── Sisa Anggaran Stat
                                               │       └── Closing Balance Stat
                                               ├── Warning Banner (Frame - Conditional)
                                               ├── Section Header (Row)
                                               │   ├── Text: "Alokasi & Progress Kategori"
                                               │   └── Button: "Kelola" Link
                                               ├── Category Cards Stack (Frame)
                                               │   ├── Card: Category Item 1
                                               │   │   ├── Row: Indicator, Name, StatusBadge
                                               │   │   ├── Progress Bar Container
                                               │   │   ├── Row: Terpakai / Sisa
                                               │   │   └── Badge: Planned Expenses Status
                                               │   └── Card: Category Item N
                                               └── Floating Action Button ("+ Tambah Transaksi")
```

---

## 2. Category Planned Expenses Sheet Mapping

```text
Flutter Widget Tree                        Proposed Figma Layer Hierarchy
-------------------                        ------------------------------
ModalBottomSheet                           Frame: Category Sheet (390 x 717 - 85% Height)
└── Container (Top Radius 20dp)            ├── Drag Handle (Rectangle 40x4, Radius 2)
    └── Column                             ├── Category Header Card (Frame)
        ├── Drag Handle Indicator          │   ├── Row: Icon, Category Name, Paid Badge
        ├── CustomCard (Category Header)   │   ├── Row: Alokasi vs Total Rencana
        ├── Tab Switcher Row               │   └── Row: Non-Rencana vs Sisa Anggaran
        │   ├── ChoiceChip (Rencana)       ├── Segmented Tab Switcher (Frame)
        │   └── ChoiceChip (Diluar Rencana)│   ├── Tab: Rencana (Active)
        └── Tab Content (Expanded)         │   └── Tab: Diluar Rencana (Inactive)
            ├── Row: Title & "+ Tambah"    ├── Section Header Row
            └── ListView.separated         │   ├── Text: "Daftar Rencana Pengeluaran"
                └── Item Tile              │   └── Button: "+ Tambah Item"
                                           └── Planned Items List (Frame)
                                               ├── Item Tile: Planned Expense 1
                                               │   ├── Button: Checkbox / Pay CTA
                                               │   ├── Column: Title, Sub-info
                                               │   └── Text: Nominal Amount
                                               └── Item Tile: Planned Expense N
```

---

## 3. Allocation Management Screen Mapping

```text
Flutter Widget Tree                        Proposed Figma Layer Hierarchy
-------------------                        ------------------------------
Scaffold                                   Frame: Allocation Management Screen (390 x 844)
├── AppBar                                 ├── App Bar
│   ├── Title ("Alokasi: [Period]")        │   ├── Text: "Alokasi: Sept 2026"
│   └── Action (Template Picker)           │   └── Icon Button: Template Picker
└── SafeArea                               └── Content Scroll (Frame)
    └── SingleChildScrollView                  ├── Available Funds Summary Card (Frame)
        └── Column                             │   ├── Row: Title & Eye Mask Toggle
            ├── CustomCard (Funds Summary)     │   ├── Text: Hero Available Amount
            ├── Section Header Title           │   ├── Row: Total Alokasi vs Sisa/Defisit
            ├── ListView.separated             │   └── Warning Box (Conditional Defisit)
            │   └── CustomCard (Allocation)    ├── Section Title: "Atur Persentase..."
            └── ElevatedButton CTA             ├── Allocation Cards List (Frame)
                                               │   ├── Card: Allocation Item 1
                                               │   │   ├── Column: Name, Method Label
                                               │   │   ├── Column: Live Nominal, "Ubah >"
                                               │   │   └── Button: "+ Tambah Rencana Tagihan"
                                               │   └── Card: Allocation Item N
                                               └── Button: "Simpan Alokasi" (Primary CTA)
```
