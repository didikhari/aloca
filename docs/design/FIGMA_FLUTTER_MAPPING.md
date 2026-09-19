# Figma → Flutter Implementation Mapping

This document maps every refined Figma token and component back to its exact Flutter class, token file, and properties.

---

## 🎨 Design Token Mapping

| Figma Token | Flutter Code Token | Class / Value | Source Token File |
| :--- | :--- | :--- | :--- |
| `color.brand.primary` | `AppColors.brandPrimary` | `Color(0xFF00A884)` | `lib/theme/app_colors.dart` |
| `color.brand.dark` | `AppColors.brandDark` | `Color(0xFF008B74)` | `lib/theme/app_colors.dart` |
| `color.background.page` | `AppColors.pageBackground` | `Color(0xFFF8FAFC)` | `lib/theme/app_colors.dart` |
| `color.surface.white` | `AppColors.surfaceWhite` | `Colors.white` | `lib/theme/app_colors.dart` |
| `color.text.primary` | `AppColors.textPrimary` | `Color(0xFF0F172A)` | `lib/theme/app_colors.dart` |
| `color.text.secondary` | `AppColors.textSecondary` | `Color(0xFF64748B)` | `lib/theme/app_colors.dart` |
| `color.status.expense` | `AppColors.expenseRed` | `Color(0xFFEF4444)` | `lib/theme/app_colors.dart` |
| `color.status.income` | `AppColors.incomeGreen` | `Color(0xFF10B981)` | `lib/theme/app_colors.dart` |
| `color.status.warning` | `AppColors.warningAmber` | `Color(0xFFF59E0B)` | `lib/theme/app_colors.dart` |
| `color.status.info` | `AppColors.infoBlue` | `Color(0xFF3B82F6)` | `lib/theme/app_colors.dart` |
| `font.family` | `AppTypography.fontFamily` | `'Roboto'` | `lib/theme/app_typography.dart` |
| `typography.heading.large` | `AppTypography.headingLarge` | `20sp Bold #0F172A` | `lib/theme/app_typography.dart` |
| `typography.section.title` | `AppTypography.sectionTitle` | `15sp Bold #1E293B` | `lib/theme/app_typography.dart` |
| `typography.label.small` | `AppTypography.labelSmall` | `11sp Medium #64748B` | `lib/theme/app_typography.dart` |
| `space.screen` | `AppSpacing.screenPadding` | `EdgeInsets.all(16.0)` | `lib/theme/app_spacing.dart` |
| `space.card` | `AppSpacing.cardPadding` | `EdgeInsets.all(16.0)` | `lib/theme/app_spacing.dart` |
| `space.button.height` | `AppSpacing.buttonHeight` | `48.0dp` | `lib/theme/app_spacing.dart` |
| `radius.card` | `AppRadius.radiusCard` | `BorderRadius.circular(16.0)` | `lib/theme/app_radius.dart` |
| `radius.sheet` | `AppRadius.radiusSheet` | `BorderRadius.vertical(top: 20)` | `lib/theme/app_radius.dart` |

---

## 🧩 Component Mapping Table

| Figma Component | Flutter Widget Class | Source File | Properties / Variants |
| :--- | :--- | :--- | :--- |
| `Card/Base` | `CustomCard` | `lib/widgets/custom_card.dart` | `child`, `padding`, `backgroundColor`, `onTap` |
| `Financial/ProgressBar` | `CustomProgressBar` | `lib/widgets/progress_bar.dart` | `ratio`, `color`, `height` |
| `Badge/Status` | `StatusBadge` | `lib/widgets/status_badge.dart` | `status` ('Under Budget', 'On Budget', 'Over Budget') |
| `Button/Primary` | `ElevatedButton` | Global Theme (`AppTheme`) | `backgroundColor`, `foregroundColor`, `height: 48dp`, `radius: 12dp` |
| `Button/Secondary` | `OutlinedButton` | Global Theme (`AppTheme`) | `foregroundColor`, `borderSide`, `height: 48dp`, `radius: 12dp` |
| `Input/TextField` | `TextField` | Material standard | `decoration`, `ThousandsSeparatorInputFormatter` |
