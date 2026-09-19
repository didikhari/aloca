# Component-to-Figma Mapping

This document provides a component-to-component mapping table from Flutter widgets to proposed Figma component architecture.

---

## 🗺️ Component Mapping Table

| Flutter Component | Proposed Figma Component Name | Existing Variants | Notes |
| :--- | :--- | :--- | :--- |
| `CustomCard` | `Card/Base` | • `Default` (White, Radius 16)<br>• `SubSurface` (F8FAFC, Radius 16)<br>• `Tappable` (InkWell interaction) | Foundational container card with `#0000000A` shadow, 16dp radius. |
| `CustomProgressBar` | `Financial/ProgressBar` | • `Normal` (Category Color Track/Fill)<br>• `Over Budget` (Red Track/Fill) | Height 6dp/8dp pill shape (`Radius.circular(height/2)`). |
| `StatusBadge` | `Badge/Status` | • `Under Budget` (Green `#E6F4EA` / `#137333`)<br>• `On Budget` (Blue `#E8F0FE` / `#1A73E8`)<br>• `Over Budget` (Red `#FCE8E6` / `#C5221F`) | Compact category status badge, radius 6dp. |
| `ElevatedButton` | `Button/Primary` | • `Teal` (`#00A884`)<br>• `Red` (`#EF4444`)<br>• `Disabled` | Main CTA button, height 48-52dp, radius 12dp. |
| `OutlinedButton` | `Button/Secondary` | • `Blue` (`#3B82F6`)<br>• `Teal` (`#00A884`) | Outlined secondary button, radius 12dp. |
| `ChoiceChip` | `Chip/Segmented` | • `Selected` (Filled background + Bold text)<br>• `Unselected` (Light background + Muted text) | Used in tabs, type toggles (Expense/Income), and method chips. |
| `TextField` | `Input/TextField` | • `Default` (Filled F8FAFC, Radius 12)<br>• `Focused` (Border #00A884 2dp)<br>• `Currency` ("Rp " prefix) | Input field for currency numbers and title case text. |
| `DropdownButtonFormField` | `Input/Dropdown` | • `Default`<br>• `Selected` | Category picker dropdown in Quick Add sheet. |
| `Financial Summary Banner` | `Financial/PositionBanner` | • `Normal` (Teal Gradient `#00A884` -> `#008B74`)<br>• `Masked` ("Rp ••••••••") | Main financial position banner with mask toggle button. |
| `Warning Banner` | `Banner/Warning` | • `Unallocated` (Blue `#EFF6FF` / `#1E40AF`)<br>• `Overallocated` (Red `#FEF2F2` / `#991B1B`) | Alert banners on Dashboard and Allocation Management. |
| `Category Card` | `Card/CategoryProgress` | • `Under Budget`<br>• `Over Budget`<br>• `With Planned Badge` | Category budget card with indicator dot, progress bar, and status badge. |
| `Planned Expense Item Tile` | `Item/PlannedExpense` | • `Unpaid` (White BG, Gray Checkbox)<br>• `Paid Normal` (Green BG `#F0FDF4`, Teal Icon)<br>• `Paid Overrun` (Green BG, Amber Overrun Badge) | Interactive checklist item tile in Category Sheet. |
| `Transaction Item Card` | `Item/Transaction` | • `Income` (Green Down Arrow, +Rp Amount)<br>• `Expense` (Red Up Arrow, -Rp Amount) | Transaction item row in Transactions List. |
