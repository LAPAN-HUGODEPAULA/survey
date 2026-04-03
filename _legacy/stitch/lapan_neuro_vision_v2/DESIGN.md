# Design System Strategy: The Amber Lens

## 1. Overview & Creative North Star
**Creative North Star: "The Clinical Nocturne"**

This design system moves away from the sterile, cold blues of traditional medical interfaces, opting instead for a "Clinical Nocturne" aesthetic. It is designed to feel like a high-end diagnostic suite: hushed, authoritative, and deeply focused. By utilizing a warm, amber-driven palette against a deep charcoal base, we create a high-tech environment that prioritizes ocular comfort—specifically addressing the light sensitivity associated with Irlen Syndrome. 

We break the "standard dashboard" template by utilizing **intentional asymmetry** and **tonal depth**. Instead of rigid grids, we use sprawling typography and overlapping "glass" containers to guide the eye through complex neurological data. The interface doesn't just display information; it curates an experience of professional clarity.

---

## 2. Colors: Tonal Depth & Ocular Comfort
Our palette is anchored by a sophisticated Amber/Orange (`#E67E22`), chosen for its high visibility and reduced blue-light strain.

### Surface Hierarchy & The "No-Line" Rule
To achieve a premium, editorial feel, **1px solid borders are strictly prohibited for sectioning.** Boundaries must be defined through background color shifts or subtle transitions.
- **Surface Nesting:** Use `surface_container_lowest` (#0C0E10) for the deepest background layers. Place `surface_container_low` (#1A1C1E) sections on top to create subtle, organic separation.
- **The Glass & Gradient Rule:** Floating elements (modals, popovers) must use Glassmorphism. Apply `surface` (#121416) at 80% opacity with a `20px` backdrop-blur. 
- **Signature CTA Texture:** Main actions should not be flat. Use a subtle linear gradient from `primary` (#FFB783) to `primary_container` (#E67E22) at a 135-degree angle to provide a "machined" metallic sheen.

| Token | Value | Role |
| :--- | :--- | :--- |
| `primary` | #FFB783 | Highlights and active states. |
| `primary_container` | #E67E22 | Main brand anchor / Clinical warmth. |
| `surface` | #121416 | The primary canvas. |
| `on_surface_variant` | #DCC1B1 | Subdued, high-end editorial captions. |
| `secondary` | #B5C8DF | Analytical data / Neutral tech accents. |

---

## 3. Typography: The Manrope Scale
Manrope is utilized for its geometric purity and exceptional legibility in technical contexts.

- **Display (Large/Medium):** Used for "Hero" metrics or section headers. These should be set with a tight letter-spacing (-0.02em) to feel like a high-end medical journal.
- **Headline (Small/Medium):** The workhorse for dashboard titles. Use `headline-sm` (1.5rem) to introduce data sets with authority.
- **Body & Labels:** All body text utilizes `body-md` (0.875rem). For technical data and metadata, use `label-md` in uppercase with +0.05em tracking to evoke a "serialized" high-tech feel.

**Typography as Brand:** Use large-scale `display-lg` numbers in `primary` to make critical data points feel like the centerpiece of the layout rather than an afterthought.

---

## 4. Elevation & Depth: Tonal Layering
We abandon traditional drop shadows in favor of **Tonal Layering**.

- **The Layering Principle:** Depth is achieved by stacking. A card is not a box with a shadow; it is a `surface_container_high` (#282A2C) shape sitting on a `surface` (#121416) floor.
- **Ambient Shadows:** For high-priority floating elements (e.g., diagnostic overlays), use a "Tinted Shadow": `blur: 40px`, `y: 20px`, `color: #000000` at 25% opacity, mixed with a hint of `primary` to simulate light bouncing off the amber elements.
- **The Ghost Border:** If a border is required for accessibility, use `outline_variant` (#564337) at **15% opacity**. It should be felt, not seen.

---

## 5. Components: Precision Primitives

### Buttons & Interaction
- **Primary:** Gradient-filled (`primary` to `primary_container`) with `on_primary` (#4F2500) text. Corner radius: `md` (0.375rem).
- **Secondary:** Transparent background with a "Ghost Border." On hover, the background fills to 10% `primary`.
- **Tertiary:** Text-only, using `primary_fixed` (#FFDCC5) for high contrast against the dark background.

### Input Fields & Controls
- **Medical Inputs:** No bottom lines or full boxes. Inputs should use `surface_container_highest` with a 2px bottom accent in `primary` only when focused.
- **Checkboxes/Radios:** When selected, these must glow slightly using a 4px blur of `primary` to indicate the "active" state of a diagnostic tool.

### Cards & Data Visualization
- **Prohibited:** Divider lines between list items.
- **Alternative:** Use 24px of vertical white space (spacing-6) or a subtle shift from `surface_container_low` to `surface_container` to demarcate data rows. 
- **The "Focus Frame":** For neuro-imaging data, use a `surface_container_highest` (#333537) container with an `xl` (0.75rem) corner radius to create a protective "cradle" for the content.

---

## 6. Do's and Don'ts

### Do
- **DO** use asymmetry. Place a large `display-md` metric on the left and a dense `body-sm` technical description on the right to create a professional, editorial layout.
- **DO** prioritize Irlen Syndrome accessibility by keeping contrast high but avoiding pure #FFFFFF text on #000000 backgrounds (our `on_surface` is a soft #E2E2E5).
- **DO** use `tertiary` (#86CFFF) for secondary data points like "Average Range" or "Normal" to contrast against the amber "Active" states.

### Don't
- **DON'T** use standard Material Design "elevated" cards with heavy shadows. This breaks the "Clinical Nocturne" immersion.
- **DON'T** use 100% opaque borders. They create visual noise that can be distracting for neuro-divergent users.
- **DON'T** use vibrant, saturated greens for "Success." Stick to the palette's sophisticated amber and blue tones to maintain the high-tech medical aesthetic.