# Aloca Design Specification & Code-to-Canvas Documentation

Welcome to the **Aloca Phase 1 — Existing Flutter UI → Figma-Ready Design Specification** documentation repository.

This directory contains a complete, code-level analysis of the actual user interface of the Aloca Flutter mobile application. The documentation is engineered to establish a precise bridge between the Flutter codebase and Figma design assets (Code-to-Canvas).

---

## 📚 Documentation Structure

| File | Description |
| :--- | :--- |
| [FIGMA_SPEC.md](./FIGMA_SPEC.md) | **Master Figma Specification** — Consolidated design specification for designers and Code-to-Canvas tools. |
| [screen-inventory.md](./screen-inventory.md) | Inventory of all 9 user-facing screens, modals, and bottom sheets. |
| [design-tokens.md](./design-tokens.md) | Exact color palette, background tokens, radii, and elevations extracted from source code. |
| [typography.md](./typography.md) | Text styles, font sizes, weights, line heights, and semantic typography hierarchy. |
| [spacing.md](./spacing.md) | Layout spacing inventory (paddings, gaps, standard margins). |
| [components.md](./components.md) | Component inventory of shared widgets and recurring UI components. |
| [financial-ui.md](./financial-ui.md) | Hierarchical representation of financial concepts (*Plan → Allocate → Track*). |
| [figma-layer-mapping.md](./figma-layer-mapping.md) | Structural mapping from Flutter widget trees to Figma frame/layer hierarchies. |
| [figma-component-mapping.md](./figma-component-mapping.md) | Component-to-Figma variant mapping table. |
| [assets.md](./assets.md) | Visual asset inventory (Material icons, Cupertino icons, fonts, design files). |
| [responsive.md](./responsive.md) | Viewport boundaries, constraints, safe areas, and dynamic layout math. |
| [interaction-states.md](./interaction-states.md) | Interactive component state inventory (*Default, Pressed, Selected, Disabled, etc.*). |
| [visual-inconsistency-audit.md](./visual-inconsistency-audit.md) | Empirical audit of visual inconsistencies across screens. |

---

## 🔒 Principles of Phase 1

1. **Zero Redesign**: Phase 1 accurately documents the UI as implemented.
2. **Zero Business Logic Mutation**: Financial rules, carry-over, 2-pass allocations, and data models remain unchanged.
3. **Source Evidence Required**: All values reference exact files and line numbers in `lib/`.
