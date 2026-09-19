# Interaction States Specification

This document inventories all interaction states currently implemented across interactive components in the Aloca codebase.

---

## 👆 Component Interaction State Inventory

### 1. `CustomCard` / Tappable Cards
* **Default**: White background `#FFFFFF`, shadow `Offset(0, 4), blurRadius: 10`, radius `16dp`.
* **Pressed**: `InkWell` ripple splash effect over transparent Material widget with `BorderRadius.circular(16.0)`.
* **Disabled**: Non-tappable when `onTap == null`.

### 2. Primary CTA Buttons (`ElevatedButton`)
* **Default**: Teal background `#00A884`, white bold text, radius `12dp`, height `48dp-52dp`.
* **Pressed**: Standard Material 3 press elevation and ripple overlay.
* **Disabled**: Greyed out background (`_isLoading == true`), non-interactive (`onPressed == null`).

### 3. ChoiceChips / Segmented Tabs
* **Unselected**:
  - Tab Switcher: Background `#F1F5F9`, Text `#64748B` Semi-bold.
  - Type Toggle: ChoiceChip default light background, Grey text.
* **Selected**:
  - Tab Switcher: Background `#00A884`, Text `#FFFFFF` Bold.
  - Expense Type Toggle: Background `#EF4444.withOpacity(0.15)`, Text `#EF4444` Bold.
  - Income Type Toggle: Background `#00A884.withOpacity(0.15)`, Text `#00A884` Bold.

### 4. Text Input Fields (`TextField` / `DropdownButtonFormField`)
* **Default / Enabled**: Background `#F8FAFC`, Radius `12dp`, Border `OutlineInputBorder(borderSide: BorderSide.none)` or `BorderSide(color: Colors.grey.shade300)`.
* **Focused**: Border `OutlineInputBorder(borderRadius: circular(12), borderSide: BorderSide(color: Color(0xFF00A884), width: 2))`.
* **Active Input**: `ThousandsSeparatorInputFormatter` formats numeric input dynamically into IDR format (e.g. `500.000`).

### 5. Masked vs Unmasked Balance Toggle
* **Masked State (Default)**: Icon `Icons.visibility_off_outlined`, Text `"Rp ••••••••"`.
* **Unmasked State**: Icon `Icons.visibility_outlined`, Text `CurrencyFormatter.format(amount)`.

### 6. Planned Expense Item Tiles
* **Unpaid State**: White background `#FFFFFF`, empty circle border `#94A3B8`, text `#0F172A`, action button "Bayar".
* **Paid Normal State**: Light green background `#F0FDF4`, filled circle `#00A884` with checkmark, strikethrough/green text.
* **Paid Overrun State**: Light green background `#F0FDF4`, filled amber circle `#F59E0B`, warning badge `"Dibayar di atas rencana (+Rp X)"`.
