---
name: Cybernetic Kinetic Athletics
colors:
  surface: '#091614'
  surface-dim: '#091614'
  surface-bright: '#2f3c39'
  surface-container-lowest: '#05100e'
  surface-container-low: '#121e1c'
  surface-container: '#162220'
  surface-container-high: '#202c2a'
  surface-container-highest: '#2b3735'
  on-surface: '#d8e5e2'
  on-surface-variant: '#bbcabf'
  inverse-surface: '#d8e5e2'
  inverse-on-surface: '#273330'
  outline: '#86948a'
  outline-variant: '#3c4a41'
  surface-tint: '#4adfa0'
  primary: '#b2ffd5'
  on-primary: '#003823'
  primary-container: '#59ebab'
  on-primary-container: '#006744'
  inverse-primary: '#006c48'
  secondary: '#83d7b1'
  on-secondary: '#003826'
  secondary-container: '#006749'
  on-secondary-container: '#8ee2bc'
  tertiary: '#eaeeff'
  on-tertiary: '#002d6d'
  tertiary-container: '#c1d2ff'
  on-tertiary-container: '#0055bf'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#6cfcba'
  primary-fixed-dim: '#4adfa0'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005235'
  secondary-fixed: '#9ff4cc'
  secondary-fixed-dim: '#83d7b1'
  on-secondary-fixed: '#002115'
  on-secondary-fixed-variant: '#005139'
  tertiary-fixed: '#d9e2ff'
  tertiary-fixed-dim: '#afc6ff'
  on-tertiary-fixed: '#001944'
  on-tertiary-fixed-variant: '#004299'
  background: '#091614'
  on-background: '#d8e5e2'
  surface-variant: '#2b3735'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.03em
  display-timer:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
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
  body-lg:
    fontFamily: Space Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.04em
  label-md:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Space Grotesk
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.06em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The design system establishes a high-performance, dark-mode athletic sanctuary. The brand aesthetic merges raw physical conditioning with futuristic biometric feedback, evoking precision, relentless focus, and intense kinetic motivation. 

The visual style is rooted in a sleek, high-contrast **Cybernetic Minimalism** with subtle neon luminous halos. Deep, pitch-infused forest blacks ground the canvas, while electric neon mint and emerald accents illuminate primary actions, active telemetry metrics, and achievement signals. Micro-interactions and card surfaces utilize tonal glass layering and controlled ambient glows to replicate high-end gym instrumentation and wearable digital displays.

## Colors

The palette is engineered for low-light gym environments and high-focus workout sessions, delivering optimal contrast without eye fatigue.

* **Primary (`#59ebab`)**: Electric Neon Mint. Used exclusively for high-intent actions, active timer dials, primary buttons, key metric callouts, and glow highlights.
* **Secondary (`#56a986`)**: Muted Emerald Teal. Serves as active tab indicators, progression graphs, segmented controls, and secondary status rings.
* **Tertiary (`#126eef`)**: Electric Cobalt. Leveraged selectively for social hooks, secondary badges, or contrast telemetry data.
* **Neutral Dark Canvas (`#0b1715`)**: Deep Forest Pitch. Serves as the primary canvas and viewport background.
* **Surface Containers (`#1c2624` & `#114830`)**: Elevated card backgrounds, modal backdrops, and active highlight states.
* **Borders & Muted Strokes (`#525a56` & `#3e70af`)**: Subtle division lines, inactive metric tracks, and unfocused form fields.
* **Typography & Contrast Light (`#ffffff` & `#c8c2af`)**: Crisp white for primary numerical displays and titles; muted bone-gray (`#c8c2af`) for secondary unit labels and body copy.

## Typography

Typography relies on the geometric precision and technical demeanor of **Space Grotesk** across headlines, telemetry readouts, body copy, and UI labels. 

Numerical figures—specifically timers, rep counts, and calories—are rendered with tighter negative tracking to mimic digital performance HUDs. Subtitles and telemetry labels feature wide letter spacing in uppercase or semi-bold weights for high scannability during motion.

## Layout & Spacing

The layout is built for fluid mobile-first thumb interaction and glanceable metrics. 

* **Grid & Structure**: Uses a responsive fluid grid bounded by a default 20px (`1.25rem`) outer canvas margin on mobile devices.
* **Component Rhythm**: Content blocks utilize an 8px modular baseline. Dense metric rows pair tightly with `space-sm` (8px) gaps, while full-bleed workout cards maintain `space-md` (16px) internal padding.
* **Hierarchy**: Major sections (e.g., Progress charts, Weekly splits, Meal logs) separate using `space-xl` (32px), creating distinct visual modules that prevent information collision.

## Elevation & Depth

Visual hierarchy does not rely on traditional dropped shadows; instead, it utilizes **tonal luminous layering** and **glowing radiant containment**:

* **Base Tier**: `#0b1715` canvas background.
* **Surface Container Tier 1 (Cards & Rows)**: Semi-translucent `#1c2624` with a 1px border of `#525a56` at 30% opacity.
* **Surface Container Tier 2 (Floating Modals & Active Cards)**: `#114830` with subtle internal gradient mapping.
* **Glow Elevation**: Active elements (e.g., the rest timer, primary FABs, and selected metric bars) emit an emerald neon radial glow (`box-shadow: 0 0 24px -4px rgba(89, 235, 171, 0.45)`).
* **Glass Overlays**: Sheet transitions and bottom navigation bars leverage background blur (`backdrop-filter: blur(16px)`) over 85% opacity dark surfaces.

## Shapes

The design system employs **Level 2 (Rounded)** shape geometry, striking a balance between modern athletic hardware and organic ergonomics.

* Standard inputs, cards, and list rows use a base border radius of `0.75rem` to `1rem` (`rounded-lg`).
* Action buttons, pill selectors, filter chips, and circular telemetry dials feature full continuous curves (`rounded-full`).
* Large visual feature modules and exercise preview frames use softened corner radii of `1.25rem` to `1.5rem` (`rounded-xl`) to frame media comfortably.

## Components

### Buttons & CTAs
* **Primary Button**: Full pill geometry (`rounded-full`), solid `#59ebab` fill with dark `#0b1715` bold typography. Features an optional directional arrow and emits a soft neon mint blur on active/hover states.
* **Secondary / Ghost Button**: Semi-transparent surface (`rgba(28, 38, 36, 0.8)`) with a 1px `#525a56` border and white text.
* **Icon Action Buttons**: Circular pill buttons with subtle translucent backplates for navigational controls and play/pause audio interactions.

### Chips & Filters
* **Workout Category Chips**: Fully rounded pills (`padding: 6px 16px`). Inactive state is transparent with a muted `#525a56` stroke and `#c8c2af` text. Selected state switches to a solid `#59ebab` fill with pitch black text.

### Cards & Telemetry Containers
* **Workout Module Cards**: Contained within `#1c2624` surfaces featuring rich photographic backdrops with gradient scrims fading into the container. A small floating circular action button is pinned to the trailing edge.
* **Metric Stat Widgets**: Dark structured tiles containing a primary icon, highlighted value in pure `#ffffff`, and sub-metric trend lines or bars in `#59ebab`.

### Form Fields & Inputs
* **Search & Text Inputs**: Recessed `#1c2624` background with a pill or 12px rounded profile. Left-aligned functional icons in `#56a986` and placeholder text in `#525a56`. Focusing an input transitions the border to `#59ebab` with a subtle outer cyan tint.

### Circular Metric Dials & Timers
* Dual-ring progress dials. The track background is rendered in dark `#114830` or faded `#1c2624`, while the active arc sweeps in vibrant `#59ebab` with a radiant drop glow. Inner counters feature high-scale display numbers centered over muted label text.