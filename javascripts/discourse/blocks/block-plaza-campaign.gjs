import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { htmlSafe } from "@ember/template";
import { block } from "discourse/blocks";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

// ── Plaza Scripture Campaign block ───────────────────────────────────────
//
// Thin doorway into the discourse-scripture-campaign plugin: when a run is
// active, this block carries the communal light meter onto the Plaza so the
// body's standing is visible from the homepage and a scene that's open to
// answer feels like something you'd want to walk into.
//
// Data: one fetch of /scripture-campaign/plaza-summary.json (contract
// frozen in the plugin):
//   { active: false }
//   { active: true, run_id, run_name, season_title, light_level, standing,
//     scenes_walked, scene_count, scene_open }
//
// Graceful absence: any fetch failure (plugin absent/disabled → 404,
// anonymous viewer → 403) or { active: false } renders NOTHING — the quiet
// empty state the Plaza requires. The block can never error onto the page.
//
// Two moods, one CTA:
//   scene_open  → a scene is live to answer → "Stand and answer"
//   walking     → between scenes / walking   → "Enter the campaign"

@block("theme:community-plaza:campaign", {
  description:
    "Scripture Campaign — the communal light meter and a door into the open scene",
  args: {},
})
export default class BlockPlazaCampaign extends Component {
  @tracked summary = null;
  @tracked loaded = false;

  constructor() {
    super(...arguments);
    this.fetchSummary();
  }

  async fetchSummary() {
    try {
      this.summary = await plazaGet("/scripture-campaign/plaza-summary.json");
    } catch {
      this.summary = null; // plugin absent / disabled / anon — stay hidden
    } finally {
      this.loaded = true;
    }
  }

  get visible() {
    return this.loaded && this.summary?.active;
  }

  get level() {
    const n = Number(this.summary?.light_level ?? 0);
    if (Number.isNaN(n)) {
      return 0;
    }
    return Math.max(0, Math.min(100, n));
  }

  // Bands mirror CampaignRun#standing / the player meter exactly.
  get band() {
    const l = this.level;
    if (l <= 15) {
      return "dark";
    }
    if (l <= 39) {
      return "guttering";
    }
    if (l <= 64) {
      return "holds";
    }
    if (l <= 84) {
      return "gaining";
    }
    return "strong";
  }

  get fillStyle() {
    return htmlSafe(`width: ${this.level}%`);
  }

  get sceneOpen() {
    return this.summary?.scene_open === true;
  }

  get runHref() {
    return `/scripture-campaign/runs/${this.summary.run_id}`;
  }

  get ctaKey() {
    return this.sceneOpen
      ? "plaza.campaign.cta_answer"
      : "plaza.campaign.cta_enter";
  }

  get leadKey() {
    return this.sceneOpen
      ? "plaza.campaign.scene_open_lead"
      : "plaza.campaign.walk_lead";
  }

  <template>
    {{#if this.visible}}
      <div class="block-plaza-campaign__layout block-plaza-campaign--{{this.band}}">
        <h2 class="block-plaza-campaign__title">
          {{icon "fire"}}
          {{i18n (themePrefix "plaza.campaign.title")}}
        </h2>

        <div class="block-plaza-campaign__season">{{this.summary.season_title}}</div>

        <div class="block-plaza-campaign__meter">
          <div class="block-plaza-campaign__meter-fill" style={{this.fillStyle}}></div>
        </div>
        <div class="block-plaza-campaign__standing">{{this.summary.standing}}</div>

        <p class="block-plaza-campaign__progress">
          {{i18n (themePrefix "plaza.campaign.scene_word")}}
          {{this.summary.scenes_walked}}
          {{i18n (themePrefix "plaza.campaign.of_word")}}
          {{this.summary.scene_count}}
        </p>

        <p class="block-plaza-campaign__lead">
          {{#if this.sceneOpen}}
            <span class="block-plaza-campaign__pulse"></span>
          {{/if}}
          {{i18n (themePrefix this.leadKey)}}
        </p>

        <a class="block-plaza-campaign__cta" href={{this.runHref}}>
          {{i18n (themePrefix this.ctaKey)}}
        </a>
      </div>
    {{/if}}
  </template>
}
