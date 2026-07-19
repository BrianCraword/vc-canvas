import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

// ── Block: My Matches ──────────────────────────────────────────────────
// Phase 1, Block 1 of the matchmaking lane.
//
// Surfaces the searcher's own active matches on the homepage. Reads the
// live plugin endpoint GET /matchmaking/matches.json, which returns the
// full active set (everything except dismissed, plus presented within the
// 14-day window) already shaped by match_summary_hash in the plugin's
// MatchesController. We render a count headline + the top N candidate
// cards and link out to the full /matchmaking/matches list. Each card
// links to the candidate's Discourse profile summary (/u/{username}/summary).
//
// The endpoint is gated server-side (group + ai_matching consent +
// searcher profile). When the viewer is not a participating searcher the
// endpoint returns a non-200; we treat every non-success as "no matches
// to show" and fall through to the conversion empty-state, which reads
// the profile endpoint to decide WHICH nudge to show:
//
//   * no profile            → "Create your profile" CTA
//   * profile, unverified   → "Verify your account" CTA
//   * verified, no matches   → "Talk to Logos" CTA (genuine empty set)
//
// Empty states are conversion surfaces, not dead ends — every branch
// gives the user a next action.
//
// ── Glimmer strict-mode note ───────────────────────────────────────────
// ALL dynamic state is pre-computed in fetchMatches() and returned as
// plain properties on the payload. The template reads only simple
// properties and booleans — it never calls a class method with
// arguments. Detached method invocation from {{...}} expressions loses
// `this` in strict mode; the established pattern across every other
// plaza block is to annotate rows in JS and keep templates declarative.
// We follow it: cards arrive pre-shaped, empty-state mode arrives as a
// single string discriminator.
@block("theme:community-plaza:my-matches", {
  description: "The searcher's active matchmaking candidates with a link to the full list",
  args: {
    count: { type: "number", default: 3 },
  },
})
export default class BlockPlazaMyMatches extends Component {
  @service currentUser;

  @bind
  async fetchMatches() {
    const cardCount = this.args.count || 3;

    // Defaults describe "viewer is not a participant / has nothing yet".
    let hasProfile = false;
    let verificationStatus = null;
    let rawMatches = [];

    // Profile first — source of truth for the empty-state CTA. A 403/404
    // here means the viewer isn't a matchmaking participant yet.
    try {
      const profileData = await plazaGet("/matchmaking/profile.json");
      const profile = profileData?.matchmaking_profile;
      hasProfile = !!profile;
      verificationStatus = profile?.verification_status || null;
    } catch {
      hasProfile = false;
    }

    // Matches — non-success simply yields an empty array. The endpoint's
    // own gating is authoritative; we don't duplicate it client-side.
    try {
      const data = await plazaGet("/matchmaking/matches.json");
      rawMatches = data?.matches || [];
    } catch {
      rawMatches = [];
    }

    // Pre-shape each card so the template reads plain props only.
    const cards = rawMatches.slice(0, cardCount).map((m) => ({
      username: m.candidate_username,
      displayName: m.candidate_first_name || m.candidate_username,
      avatarUrl: m.candidate_avatar_url,
      essence: m.candidate_card_essence,
      scorePercent:
        m.compatibility_score == null
          ? null
          : Math.round(m.compatibility_score * 100),
      metaLine: this.#metaLine(m),
      href: `/u/${m.candidate_username}/summary`,
    }));

    // Empty-state discriminator computed here, not in the template.
    //   "none"        → has cards, no empty state
    //   "no_profile"  → not a participant / never created a profile
    //   "unverified"  → profile exists but not verified
    //   "no_matches"  → verified, genuinely no active candidates yet
    let emptyMode = "none";
    if (cards.length === 0) {
      if (!hasProfile) {
        emptyMode = "no_profile";
      } else if (verificationStatus !== "verified") {
        emptyMode = "unverified";
      } else {
        emptyMode = "no_matches";
      }
    }

    return {
      cards,
      hasCards: cards.length > 0,
      emptyMode,
      isNoProfile: emptyMode === "no_profile",
      isUnverified: emptyMode === "unverified",
      isNoMatches: emptyMode === "no_matches",
    };
  }

  // Private — runs in JS during fetch, never from the template.
  // "76 · Tennessee · Non Denominational" — omit absent pieces cleanly.
  #metaLine(m) {
    const parts = [];
    if (m.candidate_age) {
      parts.push(m.candidate_age);
    }
    if (m.candidate_state) {
      parts.push(m.candidate_state);
    }
    if (m.candidate_denomination) {
      parts.push(
        m.candidate_denomination
          .replace(/_/g, " ")
          .replace(/\b\w/g, (c) => c.toUpperCase())
      );
    }
    return parts.join(" · ");
  }

  <template>
    <AsyncContent @asyncData={{this.fetchMatches}}>
      <:loading>
        <div class="block-plaza-my-matches__loading"><div class="spinner" /></div>
      </:loading>
      <:content as |data|>
        <div class="block-plaza-my-matches__layout">
          <h2 class="block-plaza-my-matches__title">
            {{i18n (themePrefix "plaza.my_matches.title")}}
          </h2>

          {{#if data.hasCards}}
            <div class="block-plaza-my-matches__list">
              {{#each data.cards as |c|}}
                <a class="block-plaza-my-matches__card" href={{c.href}}>
                  <img
                    class="block-plaza-my-matches__avatar"
                    src={{c.avatarUrl}}
                    alt={{c.username}}
                    width="56"
                    height="56"
                    loading="lazy"
                  />
                  <div class="block-plaza-my-matches__body">
                    <div class="block-plaza-my-matches__head">
                      <span class="block-plaza-my-matches__name">{{c.displayName}}</span>
                      {{#if c.scorePercent}}
                        <span class="block-plaza-my-matches__score">{{c.scorePercent}}%</span>
                      {{/if}}
                    </div>
                    {{#if c.metaLine}}
                      <div class="block-plaza-my-matches__meta">{{c.metaLine}}</div>
                    {{/if}}
                    {{#if c.essence}}
                      <p class="block-plaza-my-matches__essence">{{c.essence}}</p>
                    {{/if}}
                  </div>
                </a>
              {{/each}}
            </div>

            <a class="block-plaza-my-matches__all" href="/matchmaking/matches">
              {{i18n (themePrefix "plaza.my_matches.view_all")}}
            </a>

          {{else if data.isNoProfile}}
            <div class="block-plaza-my-matches__empty">
              <p class="block-plaza-my-matches__empty-text">
                {{i18n (themePrefix "plaza.my_matches.empty_no_profile")}}
              </p>
              <a class="block-plaza-my-matches__cta" href="/my/preferences/profile">
                {{i18n (themePrefix "plaza.my_matches.cta_create")}}
              </a>
            </div>

          {{else if data.isUnverified}}
            <div class="block-plaza-my-matches__empty">
              <p class="block-plaza-my-matches__empty-text">
                {{i18n (themePrefix "plaza.my_matches.empty_unverified")}}
              </p>
              <a class="block-plaza-my-matches__cta" href="/my/preferences/profile">
                {{i18n (themePrefix "plaza.my_matches.cta_verify")}}
              </a>
            </div>

          {{else}}
            <div class="block-plaza-my-matches__empty">
              <p class="block-plaza-my-matches__empty-text">
                {{i18n (themePrefix "plaza.my_matches.empty_no_matches")}}
              </p>
              <a class="block-plaza-my-matches__cta" href="/discourse-ai/ai-bot/conversations">
                {{i18n (themePrefix "plaza.my_matches.cta_logos")}}
              </a>
            </div>
          {{/if}}
        </div>
      </:content>
    </AsyncContent>
  </template>
}
