import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

// ── Block: Hero ─────────────────────────────────────────────────────────
// The above-columns banner. Renders instantly with a personalized greeting
// and today's date; the "Active today" count fills in a beat later once
// /about.json resolves.
//
// Title:
//   * logged in  → "Welcome, {name}"  (prefers display name, falls back to
//                   username — many users never set a display name). The
//                   "Welcome," text is a translated literal in the template;
//                   only the name is dynamic, computed in JS. This avoids
//                   i18n interpolation and a JS-side themePrefix call, neither
//                   of which is an established pattern in this theme.
//   * anonymous  → settings.plaza_title || "Community Plaza"  (the homepage
//                   is also a public landing page)
//
// Active today:
//   active_users_last_day from /about.json. This is a daily-activity figure,
//   NOT a real-time presence count — Discourse doesn't expose live presence
//   here without subscribing to the MessageBus, which is overkill for a hero
//   stat. "Active today" is the honest label. Renders "—" until resolved.
@block("theme:community-plaza:hero", {
  description: "Community Plaza pastel hero with sky/clouds, personalized greeting, and live stats",
  args: {
    title: { type: "string" },
  },
})
export default class BlockPlazaHero extends Component {
  @service site;
  @service siteSettings;
  @service currentUser;

  @tracked activeToday = "—";

  constructor() {
    super(...arguments);
    this.#loadActiveToday();
  }

  async #loadActiveToday() {
    try {
      const about = await plazaGet("/about.json");
      const n = about?.about?.stats?.active_users_last_day;
      // Show the number when it's a real value (including 0); else keep "—".
      if (typeof n === "number") {
        this.activeToday = n;
      }
    } catch {
      // Leave the placeholder — never block or error the hero on a stat.
    }
  }

  get todayLabel() {
    const d = new Date();
    return d.toLocaleDateString(undefined, {
      weekday: "long",
      month: "long",
      day: "numeric",
    });
  }

  // True when we should show the personalized greeting branch.
  get isLoggedIn() {
    return !!this.currentUser;
  }

  // The dynamic name only — no translated text here.
  get displayName() {
    return this.currentUser?.name || this.currentUser?.username || "";
  }

  // Neutral title for anonymous visitors.
  get anonymousTitle() {
    return settings.plaza_title || "Community Plaza";
  }

  <template>
    <div class="block-plaza-hero__layout">
      <div class="block-plaza-hero__sky">
        <svg
          class="block-plaza-hero__cloud block-plaza-hero__cloud--1"
          viewBox="0 0 200 80"
          xmlns="http://www.w3.org/2000/svg"
          aria-hidden="true"
        >
          <path
            d="M40,60 Q20,60 20,45 Q20,30 38,30 Q40,15 60,15 Q80,15 84,32 Q105,28 110,48 Q120,60 100,60 Z"
            fill="var(--plaza-cloud)"
            opacity="0.85"
          />
        </svg>
        <svg
          class="block-plaza-hero__cloud block-plaza-hero__cloud--2"
          viewBox="0 0 200 80"
          xmlns="http://www.w3.org/2000/svg"
          aria-hidden="true"
        >
          <path
            d="M30,55 Q15,55 15,40 Q15,28 32,28 Q38,15 58,18 Q78,18 80,35 Q100,38 95,55 Z"
            fill="var(--plaza-cloud)"
            opacity="0.95"
          />
        </svg>
        <svg
          class="block-plaza-hero__cloud block-plaza-hero__cloud--3"
          viewBox="0 0 200 80"
          xmlns="http://www.w3.org/2000/svg"
          aria-hidden="true"
        >
          <path
            d="M50,55 Q30,55 30,40 Q30,25 50,25 Q60,12 80,18 Q100,18 100,40 Q120,42 110,58 Z"
            fill="var(--plaza-cloud)"
            opacity="0.7"
          />
        </svg>
      </div>

      <div class="block-plaza-hero__content">
        <h1 class="block-plaza-hero__title">
          {{#if this.isLoggedIn}}
            {{i18n (themePrefix "plaza.hero.welcome_prefix")}}{{this.displayName}}
          {{else}}
            {{this.anonymousTitle}}
          {{/if}}
        </h1>
        <div class="block-plaza-hero__stats">
          <span class="block-plaza-hero__stat">
            {{i18n (themePrefix "plaza.hero.today")}}:
            <strong>{{this.todayLabel}}</strong>
          </span>
          <span class="block-plaza-hero__stat">
            {{i18n (themePrefix "plaza.hero.active_today")}}:
            <strong>{{this.activeToday}}</strong>
          </span>
        </div>
      </div>
    </div>
  </template>
}
