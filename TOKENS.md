# VC token contract — VC Canvas 2.6.0

The base theme publishes these CSS custom properties. Feature components and plugins (Feed, Header Mega Nav, AI Conversations, Trivia, Campaign, Matchmaking, Bible Tagger, Versatile Banner) may **read** them. They must not define their own colours: a component that needs a new value asks for a token here.

Who sets what:

| Layer | File | Driven by |
|---|---|---|
| Colours | `common/color_definitions.scss` | Admin → Appearance → Colour palettes (light and dark palette on the theme) |
| Shape, density, page, header, banner, motion | `stylesheets/brand/system.scss` | Theme settings |
| Type | `stylesheets/brand/fonts.scss` | `font_pairing`, `heading_weight` settings |
| Legacy names and fixed feature hues | `stylesheets/brand/tokens.scss` | Aliases of the above |

## Colour (derived from the palette)

| Token | Meaning | Derivation |
|---|---|---|
| `--vc-surface` | cards, panels | secondary |
| `--vc-surface-sunk` | wells, chips, neutral tiles | secondary + 5% primary |
| `--vc-surface-warm` | warm card variant | secondary + 4% tertiary |
| `--vc-page` | page behind cards | `page_background` → `--vc-page-paper` / `-white` / `-tinted` |
| `--vc-ink` | main text | primary |
| `--vc-ink-body` | long-form body | primary 90% |
| `--vc-ink-2` | secondary text | primary 82% |
| `--vc-muted` | meta, captions (≥4.5:1) | primary 66% |
| `--vc-label` | eyebrows, small labels (≥4.5:1) | primary 60% |
| `--vc-line`, `--vc-line-strong`, `--vc-line-soft` | dividers and borders | primary 11% / 18% / 7% |
| `--vc-accent` | links, primary buttons, active states | tertiary |
| `--vc-accent-deep`, `-tint`, `-wash`, `-line` | accent variants | tertiary mixes |
| `--vc-on-accent` | text on accent fills | secondary |
| `--vc-accent-2`, `--vc-accent-2-tint` | second accent (decorative) | quaternary |
| `--vc-night`, `--vc-on-night` | dark brand surface and its text | primary (light) / header (dark) |
| `--vc-love`, `--vc-success(-tint)`, `--vc-danger`, `--vc-highlight(-tint)` | status | palette |

Frame and trim (2.2.0, `frame_style`, `accent_trim`, `card_edge`):

| Token | Meaning | Derivation (light / dark) |
|---|---|---|
| `--vc-frame-bg` | header, banner, sidebar, phone bar | primary / header_background |
| `--vc-frame-ink`, `-ink-2`, `-muted` | text on the frame | secondary 96% / primary; then 80% and 64% into the frame |
| `--vc-frame-line` | dividers on the frame | frame ink 12% |
| `--vc-frame-accent` | accent on the frame (≥5:1, also on a selected row) | quaternary 65% + white / tertiary |
| `--vc-frame-glow`, `-glow-2` | banner glows | quaternary, love |
| `--vc-trim` | flame stripe | tertiary → quaternary → love |
| `--vc-edge`, `--vc-edge-strong` | card edge, and on hover | quaternary, tertiary |

Categories page (2.3.0, `category_edge`): one internal token, set per card and not for components to read.

| Token | Meaning | Value |
|---|---|---|
| `--vc-cat-edge` | edge on a category card | the category's own `--category-badge-color` (category), `--vc-edge` (flame), or transparent (none) |

Topic page (2.4.0): no new tokens. `topic_reading_width` sets Discourse's own `--topic-body-width`. The post body uses `--vc-ink-body`; quotes and code use `--vc-surface-sunk` and `--vc-accent-line`.

Profiles and user card (2.5.0): no new tokens. The night header and user card use the frame tokens on the frame colour with two glows at 24% / 20% (the welcome banner keeps 42% / 34%). Labels on that surface use `--vc-frame-ink-2`, not `--vc-frame-muted`: muted fell to 3.6:1 over the brightest glow point in dark palettes. Worst-point contrast for every text token is in `checks/profile-night-contrast-output.txt` (all ≥ 4.5:1).

Search, notifications and menus (2.6.0): no new tokens. Discourse's `--d-unread-notification-background` is steered to `--vc-accent-wash` (`menus_layout` cards). Menu tab counts use `--vc-on-accent` on `--vc-accent-deep`.

Core Discourse tokens steered from the palette: `--title-color--read`, `--excerpt-color`, `--metadata-color`, `--content-border-color`, `--d-hover`, `--d-selected`, `--d-selected-hover`, `--d-selected-text-color`, `--d-link-color`, `--highlight-bg`.

Core's text-bearing grey steps are pulled toward the ink so they pass contrast. Discourse's default `--primary-medium` is about 3:1 on white, and dates, user titles, labels, mobile tab labels and search blurbs use it. The overrides:

- `--primary-400` (`--primary-low-mid`) = ink 60% — ≥4.5:1, because core uses it for dates as well as icons
- `--primary-500` = 64%
- `--primary-600` (`--primary-medium`) = 68% — ≥5.9:1 on page
- `--primary-700` = 75%
- `--primary-800` (`--primary-high`) = 82%
- `--primary-900` (`--primary-very-high`) = 90%
- the `--primary-*-or-secondary-*` pairs follow the same steps

Steps 50–300 (backgrounds and borders) are left to core.

Contrast of the shipped palettes (WCAG AA needs 4.5 for text; values are on surface / on page):

| Pair | Flame light | Flame dark | Wine light | Wine dark |
|---|---|---|---|---|
| ink | 16.74 / 15.09 | 13.98 / 15.56 | 18.08 / 16.27 | 14.98 / 15.92 |
| muted (66%) | 6.14 / 5.53 | 6.24 / 6.94 | 6.74 / 6.07 | 6.40 / 6.80 |
| label (60%) | 5.06 / 4.56 | 5.30 / 5.90 | 5.51 / 4.96 | 5.40 / 5.74 |
| read title (72%) | 7.46 / 6.73 | 7.27 / 8.09 | 8.32 / 7.49 | 7.55 / 8.02 |
| core primary-400 / low-mid (60%) | 5.06 / 4.56 | 5.30 / 5.90 | 5.51 / 4.96 | 5.40 / 5.74 |
| core primary-600 / medium (68%) | 6.59 / 5.94 | 6.56 / 7.31 | 7.25 / 6.53 | 6.78 / 7.21 |
| accent | 5.18 / 4.67 | 7.14 / 7.95 | 6.11 / 5.50 | 6.79 / 7.22 |
| OP badge: accent-deep on accent-wash (2.1.0) | 7.12 | 7.68 | 8.08 | 7.68 |
| button text on accent | 5.18 | 7.14 | 6.11 | 6.79 |

## Shape and density (from settings)

`--vc-radius-sm`, `--vc-radius`, `--vc-radius-lg`, `--vc-radius-card`, `--vc-radius-inner`, `--vc-radius-media`, `--vc-radius-pill`, `--vc-card-border`, `--vc-shadow`, `--vc-shadow-lift`, `--vc-gap`, `--vc-sb-row`, `--vc-tile`, `--card-padding`, `--vc-card-pad` and `--vc-card-gap` (topic cards, 2.1.0).

Core tokens set from them: `--d-border-radius`, `--d-border-radius-large`, `--d-input-border-radius`, `--d-button-border-radius`, `--d-post-accordion-radius`, `--d-topic-list-data-padding-y`, `--d-sidebar-row-height` (compact), `--d-max-width`.

## Type

`--font-family` and `--heading-font-family` (unless `font_pairing` = `admin_fonts`), `--vc-ui` (= body face), `--vc-display`, `--vc-display-weight`, `--vc-display-tracking`, `--vc-eyebrow`, `--vc-font-mono` (= body face; AI history labels).

## Legacy names (kept so existing features work unchanged)

`--vc-crimson*` → accent; `--vc-ember*` → second accent darkened for text; `--vc-tint` / `--vc-paper` → page; `--vc-tint-2` → hover; `--vc-header` → header background; `--vc-hero-ink` → night; `--vc-on-dark*` → on-night; `--vc-rose*` → accent family; `--vc-green*` → success; `--vc-ink-soft` → ink-2; `--vc-ink-faint` → muted; `--vc-grad`, `--vc-grad-wide` → accent gradients.

## Fixed feature hues (not in the palette yet)

`--vc-gold*` (Scripture), `--vc-plum*` (messages), `--vc-violet*` (AI), plus the Plaza pastels in `brand/colors.scss`. They are the only hex colours left in the theme, all in these two files. Phase 3 decides whether they become palette-driven.

## Not tokens

`--vc-completion` is a per-element runtime value set by the Feed, not a design token.

## Rules

1. Components read tokens; they don't define colour values. Every `var(--vc-…)` a component uses must exist in this file.
2. New colours go into the palette derivation, never as hex in a component.
3. Text tokens must keep ≥4.5:1 on `--vc-surface` and `--vc-page` in every shipped palette.
4. The check script (`checks/check_tokens.py` in the release folder) fails a release on undefined `--vc-*` references.
