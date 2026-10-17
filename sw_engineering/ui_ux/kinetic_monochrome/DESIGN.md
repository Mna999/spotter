---
name: Kinetic Monochrome
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c4c7c8'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8e9192'
  outline-variant: '#444748'
  surface-tint: '#c6c6c7'
  primary: '#ffffff'
  on-primary: '#2f3131'
  primary-container: '#e2e2e2'
  on-primary-container: '#636565'
  inverse-primary: '#5d5f5f'
  secondary: '#c8c6c5'
  on-secondary: '#303030'
  secondary-container: '#474746'
  on-secondary-container: '#b7b5b4'
  tertiary: '#ffffff'
  on-tertiary: '#303032'
  tertiary-container: '#e4e2e4'
  on-tertiary-container: '#656466'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e2e2e2'
  primary-fixed-dim: '#c6c6c7'
  on-primary-fixed: '#1a1c1c'
  on-primary-fixed-variant: '#454747'
  secondary-fixed: '#e4e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1b1c1c'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#e4e2e4'
  tertiary-fixed-dim: '#c8c6c8'
  on-tertiary-fixed: '#1b1b1d'
  on-tertiary-fixed-variant: '#474649'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display-metric:
    fontFamily: Space Grotesk
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 60px
    letterSpacing: -0.04em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0em
  body-lg:
    fontFamily: IBM Plex Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: IBM Plex Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: IBM Plex Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.04em
  label-md:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Space Grotesk
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.08em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system embodies functional minimalism engineered for intense, high-focus training environments. It strips away aesthetic distractions to prioritize rapid legibility at arm's length, instant semantic recognition, and frictionless interaction under physical exertion. Designed specifically for the bilingual Egyptian fitness landscape, the identity merges high-contrast industrial utility with cutting-edge athletic engineering.

### Visual Style
- **High-Contrast Dark Monochrome:** Built upon deep, light-absorbing carbon tones that reduce glare under harsh gym lighting and maximize battery preservation on OLED screens.
- **Form Follows Telemetry:** Pure functional layout devoid of decorative fills, illustrations, or ambient gradient glows. Visual weight is dictated entirely by data urgency and biomechanical metrics.
- **Bilingual Parity:** Seamless mirrored layout rhythm supporting English and Egyptian Arabic without visual degradation or typographic mismatch.

## Colors

The palette operates under absolute chromatic restraint: a pure grayscale architecture where chromatic color is strictly reserved for actionable biomechanical and operational feedback.

### Core Architecture
- **Base Canvas (`#0A0A0A`):** Ultra-deep black base minimizing distraction and ambient light bleed.
- **Elevated Canvas (`#121212`):** Structural grouping layer for secondary full-bleed views and sheets.
- **Card Surfaces (`#1C1C1E` default, `#262626` hover/active):** Distinct tonal tiers creating physical containment without drop shadows.
- **Primary Accent (`#FFFFFF`):** High-luminance white used for solid CTA fills, core metrics, and primary headlines.
- **Secondary Neutral (`#A1A1A1`):** Calibrated mid-grey ensuring 4.5:1+ contrast against dark surfaces for labels, auxiliary metrics, and timestamps.
- **Hairline Borders (`#2E2E2E`):** 1px structural separators providing crisp definition between overlapping or adjacent dark surfaces.

### Semantic Status Colors (Zero Decorative Usage)
- **Optimal / Validated (`#22C55E`):** Perfect movement form, completed sets, active target heart rate, stable connection.
- **Warning / Form Correction (`#F59E0B`):** Biomechanical deviation, imminent failure warning, pacing adjustment required.
- **Critical / Fault (`#EF4444`):** Joint stress threshold exceeded, safety stop triggered, network failure, critical error.

## Typography

Typography prioritizes rapid glanceability during physical training. Space Grotesk provides a technical, geometric sharpness ideal for large digital metric readouts and commanding headers, while IBM Plex Sans delivers unmatched structural clarity for instructional text, form feedback, and bilingual consistency.

### Bilingual Handling (Arabic / English)
- **Arabic Script Pairing:** IBM Plex Sans Arabic is the primary pairing, matching the x-height, cap-height, and stroke weight of the Latin metrics precisely.
- **Proportional Numerals:** Metrics and numerical telemetry (weights, reps, rest timers) remain strictly tabular and geometric across both language modes to prevent layout jumping during live exercise tracking.
- **Optical Balance:** Arabic body copy runs at standard weights (400/500), while Latin headlines receive slight tracking contraction (-0.02em) to maintain a dense, solid visual block.

## Layout & Spacing

The layout is built around mobile ergonomics under movement fatigue. Screen margins remain fixed at `1rem` (16px) on mobile viewports to maximize usable visual surface area, expanding to `1.5rem` (24px) on compact tablets mounted on gym equipment.

### Structural Grid & Touch Targets
- **Gym-Grade Hit Zones:** Every interactive node adheres to a strict minimum bounding box of 44x44px. Critical exercise actions (Start, Pause, Next Set) utilize full-width touch bars with a height of 56px.
- **RTL Adaptive Flow:** Spacing tokens symmetrically mirror across the horizontal axis for Arabic interfaces, preserving precise padding around numeric telemetry regardless of text direction.
- **Vertical Rhythm:** A base 4px spatial sub-grid organizes internal component spacing, ensuring compact data groups without visual overcrowding.

## Elevation & Depth

Visual hierarchy is constructed exclusively using **tonal layering and low-contrast hairline outlines**. Traditional drop shadows and blurs are entirely omitted to maintain raw digital clarity and optimal frame rates during real-time computer vision processing.

### Elevation Hierarchy
- **Level 0 (Canvas):** `#0A0A0A` — The primary app surface.
- **Level 1 (Structural Containers):** `#121212` — Sub-regions, background drawers, and inactive workout segments.
- **Level 2 (Cards & Active Data Modules):** `#1C1C1E` enclosed by a continuous 1px `#2E2E2E` hairline border.
- **Level 3 (Interactive Overlays & Floating Bars):** `#262626` enclosed by a 1px `#3E3E3E` border for elevated modals and bottom floating action sheets.

## Shapes

The geometric form language balances modern architectural precision with comfortable hand-held ergonomics.

### Radii Hierarchy
- **Cards & Data Modules:** Fixed 16px corner radius (`rounded-lg`). Creates a self-contained, protective capsule feel for telemetry blocks.
- **Primary & Secondary Buttons:** Fixed 12px corner radius (`rounded`). Provides structural solidity distinct from rounded-pill consumer patterns.
- **Chips & Quick-Filter Badges:** 8px corner radius (`rounded-sm`) for compact tag labeling.
- **Status Indicators:** Pure geometric circles (`rounded-full`) or 2px micro-radii on telemetry bars.

## Components

### Buttons
- **Primary CTA:** Solid pure white background (`#FFFFFF`) with deep black text (`#0A0A0A`), 12px border radius, 52px height (exceeding standard 44px for gym gloves/sweat accessibility). Bold uppercase or medium weight Arabic text.
- **Secondary Action:** Transparent fill with a 1px `#2E2E2E` border, `#FFFFFF` text, hovering to `#1C1C1E` background.
- **Destructive / Alert Action:** Dark background (`#1C1C1E`) with high-contrast `#EF4444` border and text. Never filled with solid red unless confirming irreversible emergency stoppage.

### Metric Cards
- Background `#1C1C1E` with a 1px `#2E2E2E` perimeter.
- Internal padding: `1.25rem` (20px).
- Upper metadata: `label-sm` in `#A1A1A1` uppercase.
- Center value: `display-metric` in `#FFFFFF`.
- Sub-data / target: `body-sm` in `#A1A1A1`, shifting to `#22C55E` or `#F59E0B` only when real-time AI computer vision flags form corrections.

### Form Inputs & Selectors
- Background `#121212`, 1px border `#2E2E2E`. Active/Focus state switches border to `#FFFFFF` (no glow rings).
- Height: 48px minimum with 16px horizontal internal padding.

### Status Indicators & Form Chips
- Micro tags featuring a 6px solid indicator dot in `#22C55E`, `#F59E0B`, or `#EF4444`, followed by a high-contrast label in `#FFFFFF`. Background fill remains neutral dark (`#1C1C1E`) to avoid distracting colored patches.

### Bilingual Mirroring
- All directional icons (chevrons, forward arrows, back buttons) dynamically flip under RTL locales.
- Metric values (e.g., `120 KG`, `45 SEC`) retain left-to-right tabular alignment for international gym convention consistency.