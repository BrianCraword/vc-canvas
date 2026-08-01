import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { htmlSafe } from "@ember/template";
import { block } from "discourse/blocks";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

// ── Plaza Trivia block ───────────────────────────────────────────────────
//
// Thin entry point into the discourse-bible-trivia plugin, per the
// blueprint: the game lives in the plugin; this block exists to make
// walking past the Plaza without playing feel like missing something.
//
// Data: one fetch of /trivia/plaza-summary.json (contract frozen at
// plugin v0.1.0):
//   { active: false }
//   { active: true, contest: {...}, joined, my_score, my_rank,
//     today: { day_number, answered, total } | null }
//
// Graceful absence: any fetch failure (plugin uninstalled/disabled →
// 404, anonymous viewer → 403) or { active: false } renders NOTHING —
// the quiet empty state the blueprint requires. The block can never
// error onto the homepage.
//
// One CTA, five moods:
//   scheduled        → starts-at + "Claim your spot"
//   active, !joined  → "Day N is live" + join CTA
//   joined, playing  → progress bar + "Continue Day N"
//   joined, day done → rank + next-day anticipation
//   completed        → "Final standings are in"

@block("theme:community-plaza:trivia", {
  description: "Bible Trivia contest entry — live day status, progress, and rank",
  args: {},
})
export default class BlockPlazaTrivia extends Component {
  @tracked summary = null;
  @tracked loaded = false;

  constructor() {
    super(...arguments);
    this.fetchSummary();
  }

  async fetchSummary() {
    try {
      this.summary = await plazaGet("/trivia/plaza-summary.json");
    } catch {
      this.summary = null; // plugin absent / disabled / anon — stay hidden
    } finally {
      this.loaded = true;
    }
  }

  get visible() {
    return this.loaded && this.summary?.active && this.summary?.contest;
  }

  get contest() {
    return this.summary?.contest;
  }

  get today() {
    return this.summary?.today;
  }

  get joined() {
    return this.summary?.joined;
  }

  get todayComplete() {
    return (
      this.today && this.today.total > 0 && this.today.answered >= this.today.total
    );
  }

  // The block's single mood discriminator — template branches read this.
  get mood() {
    const c = this.contest;
    if (!c) {
      return null;
    }
    if (c.status === "completed") {
      return "completed";
    }
    if (c.status === "scheduled") {
      return "scheduled";
    }
    if (!this.joined) {
      return "join";
    }
    return this.todayComplete ? "done" : "play";
  }

  isMood = (m) => this.mood === m;

  get contestHref() {
    return `/trivia/contests/${this.contest.id}`;
  }

  get dayNumber() {
    return this.today?.day_number || this.contest?.current_day_number;
  }

  get progressPct() {
    if (!this.today || !this.today.total) {
      return 0;
    }
    return Math.round((this.today.answered / this.today.total) * 100);
  }

  get progressStyle() {
    return htmlSafe(`width: ${this.progressPct}%`);
  }

  get startsAtDisplay() {
    if (!this.contest?.starts_at) {
      return "";
    }
    return new Date(this.contest.starts_at).toLocaleString("en-US", {
      weekday: "short",
      month: "short",
      day: "numeric",
      hour: "numeric",
      minute: "2-digit",
    });
  }

  get nextDayDisplay() {
    if (!this.contest?.starts_at || !this.dayNumber) {
      return "";
    }
    const next =
      new Date(this.contest.starts_at).getTime() +
      this.dayNumber * 24 * 60 * 60 * 1000;
    return new Date(next).toLocaleString("en-US", {
      weekday: "short",
      hour: "numeric",
      minute: "2-digit",
    });
  }

  get isLastDay() {
    return this.contest && this.dayNumber === this.contest.days_count;
  }

  get ctaLabelKey() {
    switch (this.mood) {
      case "scheduled":
        return "plaza.trivia.cta_claim";
      case "join":
        return "plaza.trivia.cta_join";
      case "play":
        return "plaza.trivia.cta_continue";
      case "done":
        return "plaza.trivia.cta_leaderboard";
      default:
        return "plaza.trivia.cta_results";
    }
  }

  <template>
    {{#if this.visible}}
      <div class="block-plaza-trivia__layout">
        <h2 class="block-plaza-trivia__title">
          {{icon "trophy"}}
          {{i18n (themePrefix "plaza.trivia.title")}}
        </h2>

        <div class="block-plaza-trivia__contest-name">{{this.contest.name}}</div>

        {{#if (this.isMood "scheduled")}}
          <p class="block-plaza-trivia__line">
            {{i18n (themePrefix "plaza.trivia.scheduled_lead")}}
            <strong>{{this.startsAtDisplay}}</strong>
          </p>
          <p class="block-plaza-trivia__sub">
            {{this.contest.days_count}}
            {{i18n (themePrefix "plaza.trivia.scheduled_shape_days")}}
            ·
            {{this.contest.players_count}}
            {{i18n (themePrefix "plaza.trivia.players_in")}}
          </p>
        {{/if}}

        {{#if (this.isMood "join")}}
          <div class="block-plaza-trivia__day-chip">
            {{i18n (themePrefix "plaza.trivia.day_label")}}
            {{this.dayNumber}}
            {{i18n (themePrefix "plaza.trivia.day_live")}}
          </div>
          <p class="block-plaza-trivia__line">
            {{this.contest.questions_per_day}}
            {{i18n (themePrefix "plaza.trivia.join_pitch")}}
          </p>
          <p class="block-plaza-trivia__sub">
            {{this.contest.players_count}}
            {{i18n (themePrefix "plaza.trivia.players_racing")}}
          </p>
        {{/if}}

        {{#if (this.isMood "play")}}
          <div class="block-plaza-trivia__day-chip">
            {{i18n (themePrefix "plaza.trivia.day_label")}}
            {{this.dayNumber}}
          </div>
          <div class="block-plaza-trivia__progress">
            <div class="block-plaza-trivia__progress-fill" style={{this.progressStyle}}></div>
          </div>
          <p class="block-plaza-trivia__line">
            {{this.today.answered}}/{{this.today.total}}
            {{i18n (themePrefix "plaza.trivia.answered_today")}}
          </p>
          {{#if this.summary.my_rank}}
            <p class="block-plaza-trivia__sub">
              {{i18n (themePrefix "plaza.trivia.rank_prefix")}}
              #{{this.summary.my_rank}}
            </p>
          {{/if}}
        {{/if}}

        {{#if (this.isMood "done")}}
          <p class="block-plaza-trivia__line">
            ✓
            {{i18n (themePrefix "plaza.trivia.day_done_lead")}}
            {{#if this.summary.my_rank}}
              {{i18n (themePrefix "plaza.trivia.rank_prefix")}}
              <strong>#{{this.summary.my_rank}}</strong>
            {{/if}}
          </p>
          {{#if this.isLastDay}}
            <p class="block-plaza-trivia__sub">
              {{i18n (themePrefix "plaza.trivia.final_day_note")}}
            </p>
          {{else}}
            <p class="block-plaza-trivia__sub">
              {{i18n (themePrefix "plaza.trivia.next_day_lead")}}
              <strong>{{this.nextDayDisplay}}</strong>
              {{i18n (themePrefix "plaza.trivia.next_day_tease")}}
            </p>
          {{/if}}
        {{/if}}

        {{#if (this.isMood "completed")}}
          <p class="block-plaza-trivia__line">
            {{i18n (themePrefix "plaza.trivia.completed_lead")}}
            {{#if this.summary.my_rank}}
              {{i18n (themePrefix "plaza.trivia.completed_rank_prefix")}}
              <strong>#{{this.summary.my_rank}}</strong>
            {{/if}}
          </p>
        {{/if}}

        <a class="block-plaza-trivia__cta" href={{this.contestHref}}>
          {{i18n (themePrefix this.ctaLabelKey)}}
        </a>
      </div>
    {{/if}}
  </template>
}
