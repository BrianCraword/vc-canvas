# Changelog

## 2.7.0 — 2026-10-19 (claude-two; candidate, not installed)

Phase 2, step 7 (first half): badges, groups, tags and the about page. Board C18. The composer and empty states follow in 2.8.0.

Community pages (`community_pages_layout`: cards, the default; classic = Discourse's, byte-identical to 2.6.0)
- Badges (/badges, a member's badges, one badge's page): each badge a card with the flame edge on hover; badge group titles as small labels.
- Groups (/g): each group a card, the name in the heading font one size smaller, so names like "pending_verification" no longer break mid-word.
- Tags (/tags): the tag list on one card; tags as chips like the category chips, counts at the meta size.
- About (/about): the site name on the night surface (a white card with `profile_header_style` card), the four counts as tiles, the site's text on a card, and contact and site activity on one card beside it.
- Group card (click a group mention): the user card's look.

Not changed
- Topic lists, categories, topic page, profiles, search, notifications and menus (as 2.6.0), frame, palettes and colour definitions. No JavaScript changes. No new tokens.

## 2.6.0 — 2026-10-19 (claude-two; candidate, not installed)

Phase 2, step 6: search, notifications and the header menus. Board C18. Includes the 2.5.1 fix (the messages-page name).

Search page (`menus_layout`: cards, the default; classic = Discourse's, byte-identical to 2.5.1)
- Each result is a card with the flame edge (following `card_edge`), the title in the heading font, the excerpt and date in the card colours, and the matched words in ink on the accent wash.
- Read results are one step lighter. Phones drop the avatar to give the text room.

Notifications page
- The list sits on one card. Unread rows keep the accent wash and get a flame edge. Dates go from 12.1px to the meta size (13.9px).

User menu and search menu
- Card corners, hairline and shadow, the same unread rows.
- The counts on the user menu's tabs were 10.6px white on a light accent (2.19:1). They are now 12px on the deep accent (7.8:1 or better in all four palettes), tucked into the corner so the icon shows.
- Descriptions in the user menu one step smaller than the names.

Messages
- Left to the VC Message Center component. Its white-on-white Message and Chat buttons are its own rule (board B25).

Not changed
- Topic lists, categories, topic page, profiles (as 2.5.1), frame, palettes and colour definitions. No JavaScript changes. No new tokens: Discourse's own `--d-unread-notification-background` is set to `--vc-accent-wash`.

## 2.5.1 — 2026-10-19 (claude-two; candidate, not installed)

Fix only. Board C18.

- **Messages pages: your username was invisible in the profile header.** On the messages pages the VC Message Center component paints its own light header, but 2.5.0 still coloured the name for the night surface (light on light, 1.09:1). The night surface and its light text now stay off on the messages pages, so the header there keeps the card colours whichever background shows. Found on the live check of 2.5.0.
- Nothing else changed: every other profile page and the user card compile to the same rules, now scoped to skip the messages pages.

## 2.5.0 — 2026-10-19 (claude-two; candidate, not installed)

Phase 2, fourth page family: profiles and the user card. Board C18. Includes the 2.4.1 fix.

Profile pages (`profile_layout`: cards, the default; classic = Discourse's pages, byte-identical to 2.4.1)
- Header: avatar, names, bio and buttons on a card. Night (default) puts it on the brand's dark surface with soft flame and wine glows; the joined / seen / groups row sits under a hairline. On sub-pages (activity, messages and the rest) the collapsed header keeps the same surface.
- Summary: the stats become tiles (value in the heading font, label muted). Top replies, top topics, links, categories, most liked and the rest each sit on their own card, two across on desktop, one on phones.
- Activity and the other post streams: each item is a card.
- Staff counters (staff only) sit on the same surface. Their coloured count pills keep Discourse's own colours.
- CSS only (`stylesheets/pages/profile.scss`).

User card (click an avatar)
- Night: the same surface as the profile header. Card: Discourse's card with the VC ring and shadow.
- Names in the heading font; read time, dates and counts in frame ink; "+10 More" stays a white chip like the badges.

Header style (`profile_header_style`: night (default), card)

Phones
- No sideways scroll on the summary (the top-categories table is fixed-layout; card padding is smaller). The user card uses a shadow ring instead of a border, which had pushed the page 6px wide.

Not changed
- Topic lists, categories, topic page, frame, palettes and colour definitions (identical to 2.4.1). No JavaScript changes.
- Staff counter pills: Discourse's colours fail contrast (deleted posts and warnings 3.8:1 light, 3.75:1 dark; flags 2.39:1 light). Same as without VC; staff only.
- Bible Tagger scripture links in activity still fail contrast on white (2.28:1). That is the component's link colour (B15).

## 2.4.1 — 2026-10-19 (claude-two; candidate, not installed)

Fix only. Board C18.

- **Scrolled topic title in the header, light mode.** 2.4.0 fixed the heading but not its link, so the title stayed dark on the night frame. Core colours that link with `--title-color--header`, which the palette resolves to the ink at `:root`. The night frame now sets it to the frame ink on the header, and `header_style` night (with frame none) sets it to the night ink. Measured live: the title went from 31,27,46 on 31,27,46 (1:1) to the frame ink, 15.36:1.
- Nothing else changed.

## 2.4.0 — 2026-10-19 (claude-two; candidate, not installed)

Phase 2, third page family: the topic page. Board C18.

Reading page (`topic_layout`: cards, the default; classic = Discourse's topic page)
- Nested replies (this site's default view): the first post sits on a card with the flame edge (following `card_edge`). Each top-level reply and its whole thread sits on its own card, so threads read as units on the white page. Depth lines, sticky avatars, collapse and the menus are Discourse's own.
- Post body: VC ink, line height 1.65, headings in the heading font, quotes and blockquotes with an accent bar on a soft fill, code on the sunk surface, rounded images.
- Author line: the name in ink, semibold; title or group muted; dates at the meta size (13.9px). Phones had post dates at 10.6px.
- The sticky sort bar sits on the page colour.
- Phones: inset cards, like the topic lists, instead of full-bleed sheets.
- Flat view (messages, and topics read flat): the same author line and post typography, no cards.
- CSS only (`stylesheets/pages/topic.scss`).

Reading width (`topic_reading_width`, default 690 = Discourse's)
- Sets Discourse's own `--topic-body-width` (560–820px) for nested and flat topics.

Author line (`post_author_style`: name_title (default), name_only)

Fixed (all layouts)
- Night frame, since 2.2.0: once you scroll a topic, the header shows the topic title, and it was dark on the dark header (invisible). It now takes the header's colour. The category beside it uses the frame ink. Cause: VC's `h1` colour rule reached the header's title.

Not changed
- Topic lists, categories, frame, palettes and colour definitions (identical to 2.3.0). No JavaScript changes.
- Bible Tagger scripture links still fail contrast on white (2.28:1) and on quote fills (2.04:1). That is the Bible Tagger component's link colour (B15).

## 2.3.0 — 2026-10-19 (claude-two; candidate, not installed)

Phase 2, second page family: the Categories page. Board C18.

Categories as cards (`categories_layout`: cards, the default; classic = Discourse's table, byte-identical to 2.2.0)
- Each category is a card: name in the heading font, a two-line description, subcategories as chips, and the topic count as a pill. New and unread counts show under it in the deep accent.
- The whole card opens the category. Subcategory chips, counts and featured-topic links stay their own links.
- The Latest column beside the categories becomes compact cards: avatar, title, category, replies and date. The whole card opens the topic; it follows `card_edge` like the topic cards.
- Phones: Discourse's category cards get the same surface, a two-line description, chips, and featured topics that truncate instead of widening the page.
- Category boxes, if an admin picks a box style, get the card surface only.
- CSS only (`stylesheets/pages/categories.scss`). Works with every category page style in Admin → Settings; built and checked against the site's current ones (desktop: categories and latest topics; phones: categories with featured topics).

Category edge (`category_edge`: category (default), flame, none)
- A 4px edge on the left of each category card, in the category's own colour (each category's settings), the brand flame, or nothing.

Category logos (`category_logo`: small (default), hidden, full)
- Uploaded logos show as a 40px thumbnail beside the name instead of at full size (Blog's was 407 × 150px).

Not changed
- Topic lists, topic page, frame, palettes and colour definitions (identical to 2.2.0 for all four palettes). No JavaScript changes.
- Category colours are category settings (Brian's): seven top-level categories still use Discourse's stock blue `#0088CC`.

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
