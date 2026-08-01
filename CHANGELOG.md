# Changelog

## [Unreleased]

## [1.3.2] — 2026-07-19 — Journey re-anchor (Phase 4 theme sweep)

Prior state: the Plaza's matchmaking lane still carried dead Steering
wiring — `block-plaza-profile-status` fetched `/steering/profile.json`
(payload key `steering_profile`) and `/steering/identity/status.json`,
and its CTA pointed at `/steering/profile`. The Steering plugin is
uninstalled and those endpoints 404; the block's graceful-absence
design meant it silently rendered the permanent "get started" state
for everyone.

- `block-plaza-profile-status.gjs`: endpoints repointed to
  `/matchmaking/profile.json` (key `matchmaking_profile`) and
  `/matchmaking/identity/status.json`. CTA follows journey semantics —
  pre-confirmation states route to `/matchmaking` (the one front door;
  labeled "Continue your Journey" via new `ctaJourney` flag + locale
  key `plaza.profile_status.cta_journey`), confirmed members route to
  `/matchmaking/profile` (the hub).
- `block-plaza-my-matches.gjs`: both pre-participant empty-state CTAs
  (`no_profile`, `unverified`) door to `/matchmaking` instead of the
  hub; verified-but-empty keeps its Logos door.
- Locale copy reframed to the Journey: "Begin the Journey — the guided
  path into matchmaking." / "Begin the Journey" / "Finish your Journey
  to unlock matching." / "Continue your Journey".
- Requires discourse-matchmaking ≥0.14 (journey front door live at
  bare /matchmaking as of 0.15.0).

## 2026-07-08 — changelog initialized
- Added CHANGELOG.md as part of command-center validation system. (commit: <hash>)

## [2.0.1] — Covenant rebrand install fix

The 2.0.0 rebrand renamed the two bundled color schemes (Community Plaza
Light/Dark → Covenant Light/Dark). Discourse matches bundled schemes by
NAME in `RemoteTheme#update_theme_color_schemes`: a scheme whose name is
no longer present in about.json is destroyed, and `theme.color_scheme` is
reassigned only when the theme is a new record. On update the old schemes
were destroyed and the theme's color_scheme was never repointed, so core
served base Discourse colors while every `--vc-*` token served Covenant.

- `about.json`: scheme names reverted to "Community Plaza Light" /
  "Community Plaza Dark" so they match in place and receive the Covenant
  hex values. Palette is unchanged from 2.0.0 — only the keys.
- `about.json`: `minimum_discourse_version` set to "3.5.0". The theme
  consumes core's `--space-*` tokens, which land in 3.5.
- `common/common.scss`: dropped `@use "lib/viewport"` — the namespace was
  never used (only a prose mention in mobile-hardening.scss) and it ties
  the entrypoint to a core path.
- Deleted `brand/colors.scss` and `brand/fonts.scss` — orphaned since
  brand/_index.scss switched to covenant + plaza-bridge.

Compiled CSS is byte-identical to 2.0.0 (55,786 bytes).
