# Aloca Design System Governance & Rules

**Version**: 2.0.0  
**Status**: Active Specification  
**Target Engine**: Antigravity AI & Human Engineers

---

## 📜 Core Design System Rules

1. **Figma is the Visual Source of Truth**:
   - Component dimensions, colors, typography, elevations, and corner radii specified in Figma must be respected in Flutter implementations.
   - Do not invent arbitrary hex colors, font sizes, or raw margins in screen-level widgets.

2. **Always Use Centralized Design Tokens**:
   - Use `AppColors` for all color references (`AppColors.brandPrimary`, `AppColors.textPrimary`, `AppColors.pageBackground`, etc.).
   - Use `AppTypography` for all text styles (`AppTypography.headingLarge`, `AppTypography.sectionTitle`, `AppTypography.labelSmall`, etc.).
   - Use `AppSpacing` for paddings and margins (`AppSpacing.screenPadding`, `AppSpacing.cardPadding`, `AppSpacing.md`, `AppSpacing.lg`, etc.).
   - Use `AppRadius` for corner curvature (`AppRadius.card`, `AppRadius.sheet`, `AppRadius.lg`, `AppRadius.sm`).

3. **Component Reuse First**:
   - Before building custom containers or cards, inspect `CustomCard`, `CustomProgressBar`, `StatusBadge`, and standard button themes.
   - Do not recreate custom card containers with hardcoded shadows or radii.

4. **Normalized CTA Button Heights**:
   - All primary and secondary CTA buttons must use the normalized height of `48.0dp` (`AppSpacing.buttonHeight`).

5. **Normalized Modal Bottom Sheets**:
   - Top corner radius must be `20.0dp` (`AppRadius.sheet`).
   - Outer horizontal padding must be `20.0dp` (`AppSpacing.xl`).
   - Bottom inset must dynamically handle software keyboard insets (`MediaQuery.of(context).viewInsets.bottom`).

6. **Preserve Business & Financial Logic**:
   - UI refinement must NEVER modify data models, Hive persistence, 2-pass allocation calculation, continuous carry-over, or Excel export/import logic.
