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
