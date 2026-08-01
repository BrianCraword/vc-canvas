import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

// ── Block: Profile Status ──────────────────────────────────────────────
// Phase 1, Block 2 of the matchmaking lane.
//
// A glanceable "where do I stand" panel for the searcher's own profile.
//
// Journey re-anchor (theme 1.3.2 — plugin discourse-matchmaking ≥0.14):
//   • Endpoints are the matchmaking plugin's (/matchmaking/profile.json,
//     payload key matchmaking_profile; /matchmaking/identity/status.json).
//     The Steering plugin is dead and its endpoints 404 — this block's
//     graceful-absence design is why the dead wiring failed silently.
//   • The CTA follows journey semantics (one front door): anything
//     pre-confirmation routes to /matchmaking (the resumable Journey,
//     which owns consent, profile readiness, identity, and the Veritas
//     conversation); a confirmed member routes to /matchmaking/profile
//     (the hub — the post-confirmation management surface).
//   • TWO verification statuses surfaced, reflecting the corrected model
//     where faith confirmation (Veritas) and identity verification
//     (Didit) are INDEPENDENT — and neither is trust-level-based:
//       - Faith pill: from verification_status. "Profile Confirmed" =
//         faith; never conflate with identity.
//       - Identity pill: from identity/status.json. Only shown when the
//         identity feature is enabled. Reads identity_verified +
//         identity_verification_status. When the circuit breaker has
//         lifted the requirement (required:false) and identity isn't
//         done, it's shown as optional, not as a blocker.
//
// Reads two endpoints; each degrades independently. A non-200 on the
// profile endpoint resolves to the "get started" state; a failure on the
// identity endpoint simply hides the identity pill.
//
// ── Glimmer strict-mode note ───────────────────────────────────────────
// Every dynamic value is pre-computed in fetchStatus() and returned as
// plain props. The template reads simple properties and branches with
// {{#if}} on plain booleans; every (themePrefix "...") argument is a
// string LITERAL — no dynamic translation keys, no method-with-args.
@block("theme:community-plaza:profile-status", {
  description: "The searcher's own profile completion and verification status with a next-step CTA",
  args: {},
})
export default class BlockPlazaProfileStatus extends Component {
  @service currentUser;

  @bind
  async fetchStatus() {
    let profile = null;
    let consent = null;

    try {
      const data = await plazaGet("/matchmaking/profile.json");
      profile = data?.matchmaking_profile || null;
      consent = data?.consent_status || null;
    } catch {
      profile = null;
    }

    // Identity status — independent endpoint, independent failure mode.
    let identity = null;
    try {
      identity = await plazaGet("/matchmaking/identity/status.json");
    } catch {
      identity = null;
    }
    const identityView = this.#identityView(identity);

    // No profile → the "begin the Journey" state. CTA routes to the
    // Journey front door (it owns consent + every pre-profile state).
    if (!profile) {
      return {
        showBar: false,
        completion: 0,
        barWidth: "0%",
        barFillClass: "--below",
        toneClass: "--neutral",
        statusNone: true,
        statusUnverified: false,
        statusPending: false,
        statusVerified: false,
        statusFlagged: false,
        statusRejected: false,
        needsConsent: false,
        ...identityView,
        ctaHref: "/matchmaking",
        ctaJourney: true,
      };
    }

    const completion = Number(profile.completion_percentage) || 0;
    const meetsMinimum = !!profile.meets_minimum_completion;
    const vstatus = profile.verification_status || "unverified";

    const TONE = {
      unverified: "--neutral",
      pending_interview: "--pending",
      verified: "--verified",
      flagged: "--flagged",
      rejected: "--flagged",
    };

    return {
      showBar: true,
      completion,
      barWidth: `${Math.max(0, Math.min(100, completion))}%`,
      barFillClass: meetsMinimum ? "--ok" : "--below",
      toneClass: TONE[vstatus] || "--neutral",
      statusNone: false,
      statusUnverified: vstatus === "unverified",
      statusPending: vstatus === "pending_interview",
      statusVerified: vstatus === "verified",
      statusFlagged: vstatus === "flagged",
      statusRejected: vstatus === "rejected",
      needsConsent: !!consent?.needs_reconsent,
      ...identityView,
      // Journey semantics: confirmed members manage in the hub; everyone
      // else continues the Journey (one front door — /matchmaking).
      ctaHref: vstatus === "verified" ? "/matchmaking/profile" : "/matchmaking",
      ctaJourney: vstatus !== "verified",
    };
  }

  // Pre-compute the identity pill view. Exactly one identity* flag is true
  // when showIdentity is true; all false when the feature is off.
  #identityView(identity) {
    const base = {
      showIdentity: false,
      identityToneClass: "--neutral",
      identityVerified: false,
      identityOptional: false,
      identityReview: false,
      identityDeclined: false,
      identityNotStarted: false,
    };
    if (!identity || identity.enabled !== true) {
      return base; // feature off → no identity pill at all
    }
    base.showIdentity = true;

    if (identity.identity_verified === true) {
      base.identityVerified = true;
      base.identityToneClass = "--verified";
      return base;
    }
    // Circuit breaker lifted the requirement and it's not done → optional.
    if (identity.required !== true) {
      base.identityOptional = true;
      base.identityToneClass = "--neutral";
      return base;
    }
    switch (identity.identity_verification_status) {
      case "In Review":
        base.identityReview = true;
        base.identityToneClass = "--pending";
        break;
      case "Declined":
        base.identityDeclined = true;
        base.identityToneClass = "--flagged";
        break;
      default:
        base.identityNotStarted = true;
        base.identityToneClass = "--pending";
    }
    return base;
  }

  <template>
    <AsyncContent @asyncData={{this.fetchStatus}}>
      <:loading>
        <div class="block-plaza-profile-status__loading"><div class="spinner" /></div>
      </:loading>
      <:content as |s|>
        <div class="block-plaza-profile-status__layout">
          <h2 class="block-plaza-profile-status__title">
            {{i18n (themePrefix "plaza.profile_status.title")}}
          </h2>

          {{#if s.showBar}}
            <div class="block-plaza-profile-status__completion">
              <div class="block-plaza-profile-status__completion-head">
                <span class="block-plaza-profile-status__completion-label">
                  {{i18n (themePrefix "plaza.profile_status.completion_label")}}
                </span>
                <span class="block-plaza-profile-status__completion-pct">
                  {{s.completion}}%
                </span>
              </div>
              <div class="block-plaza-profile-status__bar">
                <div
                  class="block-plaza-profile-status__bar-fill {{s.barFillClass}}"
                  style="width: {{s.barWidth}}"
                ></div>
              </div>
            </div>
          {{/if}}

          {{! ── Faith verification pill ── }}
          <div class="block-plaza-profile-status__verification {{s.toneClass}}">
            <span class="block-plaza-profile-status__verification-dot"></span>
            <span class="block-plaza-profile-status__verification-text">
              {{#if s.statusVerified}}
                {{i18n (themePrefix "plaza.profile_status.status.verified")}}
              {{else if s.statusPending}}
                {{i18n (themePrefix "plaza.profile_status.status.pending")}}
              {{else if s.statusFlagged}}
                {{i18n (themePrefix "plaza.profile_status.status.flagged")}}
              {{else if s.statusRejected}}
                {{i18n (themePrefix "plaza.profile_status.status.rejected")}}
              {{else if s.statusNone}}
                {{i18n (themePrefix "plaza.profile_status.status.none")}}
              {{else}}
                {{i18n (themePrefix "plaza.profile_status.status.unverified")}}
              {{/if}}
            </span>
          </div>

          {{! ── Identity verification pill (only when feature enabled) ── }}
          {{#if s.showIdentity}}
            <div class="block-plaza-profile-status__verification {{s.identityToneClass}}">
              <span class="block-plaza-profile-status__verification-dot"></span>
              <span class="block-plaza-profile-status__verification-text">
                {{#if s.identityVerified}}
                  {{i18n (themePrefix "plaza.profile_status.identity.verified")}}
                {{else if s.identityReview}}
                  {{i18n (themePrefix "plaza.profile_status.identity.review")}}
                {{else if s.identityDeclined}}
                  {{i18n (themePrefix "plaza.profile_status.identity.declined")}}
                {{else if s.identityOptional}}
                  {{i18n (themePrefix "plaza.profile_status.identity.optional")}}
                {{else}}
                  {{i18n (themePrefix "plaza.profile_status.identity.not_started")}}
                {{/if}}
              </span>
            </div>
          {{/if}}

          {{#if s.needsConsent}}
            <p class="block-plaza-profile-status__reconsent">
              {{i18n (themePrefix "plaza.profile_status.needs_reconsent")}}
            </p>
          {{/if}}

          <a class="block-plaza-profile-status__cta" href={{s.ctaHref}}>
            {{#if s.ctaJourney}}
              {{i18n (themePrefix "plaza.profile_status.cta_journey")}}
            {{else}}
              {{i18n (themePrefix "plaza.profile_status.cta_update")}}
            {{/if}}
          </a>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
