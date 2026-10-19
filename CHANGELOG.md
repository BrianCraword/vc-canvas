# Changelog

## 2.2.0 — 2026-10-19 (claude-two; candidate, not installed)

Light mode gets its own style: a night frame around a white page, with flame trim. Brian chose this after live previews (option B). Board C18.

Night frame (`frame_style`: night, the default; none = 2.1.0 look)
- Header, welcome banner, sidebar and phone tab bar sit on the dark brand surface, around a light reading area.
- The welcome banner gets a flame glow (second accent) and a wine glow (love colour).
- In dark mode the frame equals the dark header colour, so dark mode looks as before.
- New tokens, derived from the palette: `--vc-frame-bg`, `-ink`, `-ink-2`, `-muted`, `-line`, `-accent`, `-glow`, `-glow-2`. Frame accent = second accent 65% + white (light), or the dark accent (dark).
- The sidebar re-points the VC and core tokens at the frame. With `sidebar_style` tiles, the per-destination hues are darkened into the frame.
- Header Mega Nav's phone tab bar is styled from outside (`nav.je-mnav`).
- With a night frame, `header_style` no longer applies.

White page
- `page_background` default is now **white** (was paper).
- On white, cards get a hairline (ink 9%) and a soft lift so they don't wash out, unless `card_style` is flat.

Flame trim (`accent_trim`, default on)
- A 3px flame-to-wine stripe (`--vc-trim`) under the header and above the phone tab bar.
- A 3px flame underline on the active list tab.
- Reply counts and title hover in the deep accent.
- Primary buttons get a flame-to-wine gradient with a soft glow.

Card edge (`card_edge`: all (default), new_activity, hover, none)
- A 4px flame edge on the left of topic cards (`--vc-edge`). Hover deepens it (`--vc-edge-strong`) with a warm glow.
- new_activity puts the edge only on topics with new or unread posts.

Type
- Topic card titles are one step heavier than headings (`--vc-card-title-weight`; medium headings → 600).

Not changed
- Topic card JS, the Plaza blocks, homepage layout and palettes.
- Logos are Brian's (Admin → Branding): the logo's dark strokes don't show on the night header.

## 2.1.0 — 2026-10-18 (claude-two; candidate, not installed)

Phase 2, first page family: Latest and the other topic lists. Board C18.

Topic lists as cards
- Latest, New, Unread, Top, Hot, category and tag lists show each topic as a card: title in the heading font, a short excerpt, posters, category and tags, replies and date. The whole card opens the topic.
- Excerpts that would only repeat the title are left out. Feed and quick posts take their title from the start of the post, so their excerpt starts with the same words.
- Phones get the same cards (one avatar, no tags, no views) instead of Discourse's separate phone row.
- The column headings are hidden on cards: they don't line up with a card. Staff keep the bulk-select control. Sort by replies or views from the classic layout, or use Top and Hot.
- Uses only Discourse's own transformers (`topic-list-class`, `topic-list-item-class`, `topic-list-item-mobile-layout`, `topic-list-item-expand-pinned`, `topic-list-item-click`). Every cell is still Discourse's, so plugin outlets and bulk select keep working. Suggested topics and messages keep the table.
- Layout approach adapted from Discourse's Horizon theme (MIT).
- New files: `javascripts/discourse/api-initializers/topic-cards.js`, `javascripts/discourse/lib/vc-topic-cards.js`, `stylesheets/pages/` (`_index`, `topic-list`, `topic`).

Admin settings (new)
- `topic_list_layout`: cards (default) or classic. Classic is 2.0.0's table, unchanged.
- `topic_card_excerpt_lines`: 0–4, default 2. With 0, only pinned topics show an excerpt, as in Discourse.
- `topic_card_views`: show view counts on cards (default off).

Tokens
- `--vc-card-pad` and `--vc-card-gap`, set by `density` (comfortable / compact).

Contrast
- The nested-replies "OP" badge was 4.45:1 in VC Flame Light. It now uses the deep accent on the accent wash: 7.12 / 7.68 / 8.08 / 7.68 in the four shipped palettes.
- Core's like-heat colours on reply and view counts (~2.6:1) are replaced by the deep accent on cards.

Unchanged
- Colour derivation, palettes, all other settings, the Plaza blocks, homepage layout and mobile hardening are byte-identical to 2.0.0.

## 2.0.0 — 2026-10-17 (claude-two; candidate, not installed)

Phase 1 of the design overhaul (`Second Brain/projects/victorious-christians/design-overhaul-2026-10-17/PLAN.md`). Installs as a separate theme named "VC Canvas 2" next to VC-Canvas 1.5.0.

Colour
- New palettes shipped with the theme: VC Flame Light and VC Flame Dark (default: logo orange with deep navy), plus VC Wine Light and VC Wine Dark (1.5.0's crimson) for comparison.
- New `common/color_definitions.scss` derives every VC colour from the palette, in light and dark, using the same mechanism as Discourse's Horizon theme. Editing the palette in Admin recolours the site.
- Visited topic titles, excerpts, metadata, hover, selection, links and highlight now follow the palette. Visited titles were 3.15:1; they are now at least 6.7:1.
- Dark mode: attach VC Flame Dark as the theme's Dark Colour Palette.
- Core's muted-text greys (`--primary-400`…`900`) are pulled toward the ink, so dates, user titles, labels, search blurbs and mobile tab labels pass 4.5:1 on surface and page. Stock `--primary-medium` is about 3:1.

Admin settings (new)
- `font_pairing`, `heading_weight`, `corner_style`, `button_shape`, `card_style`, `density`, `page_background`, `header_style`, `sidebar_style`, `welcome_banner_style`, `content_width`, `motion`. The 75 Plaza settings are unchanged.

Type
- Outfit removed. Inter is the body and UI face; Newsreader stays for headings. `admin_fonts` hands fonts back to Admin → Appearance → Fonts.
- `--vc-font-mono` now points at the body face (AI history labels were monospace at 9.8px).
- Eyebrow and sidebar header text raised to a 12px minimum.

Feed and other features
- Defines the 21 tokens the Feed read but nobody defined (`--vc-paper`, `--vc-rose*`, `--vc-surface-warm/sunk`, `--vc-shadow`, `--vc-radius-*`, …) plus AI's `--vc-font-mono`. The Feed page is no longer white-on-white and its accents no longer fall back to Discourse blue. No Feed release is needed for this.

Sidebar
- `sidebar_style` quiet (default): one neutral tile colour, accent only on the current page; tiles keeps 1.5.0's colour-per-destination map; text removes tiles.

Unchanged
- All JavaScript, the 21 Plaza blocks and their CSS, homepage layout and mobile hardening are byte-identical to 1.5.0.
