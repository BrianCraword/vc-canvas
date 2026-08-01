import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { htmlSafe } from "@ember/template";
import { block } from "discourse/blocks";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

// ── Plaza Scripture Campaign block ───────────────────────────────────────
//
// Doorway into the discourse-scripture-campaign plugin, now with TWO moods
// (revision two, 2026-07-03):
//
//   RUN MODE — a communal run is active: the communal light meter, the
//     body's standing, and a door into the open scene. Unchanged from
//     revision one, plus a quiet "browse the library" footer link.
//
//   LIBRARY MODE — no run on the clock: the NEWEST approved season from
//     the plugin's library plus the community light the body has gathered
//     walking solo. Before this revision the block rendered NOTHING
//     between runs — the plugin's whole library was invisible from the
//     homepage, and a freshly approved season had no door anywhere.
//
// Data: one fetch of /scripture-campaign/plaza-summary.json (contract
// frozen in the plugin; `library` + `solo` keys are additive as of 0.8.1):
//   { active: false|true, ...run fields when active,
//     solo: { walkers, walks_completed, light_gathered },
//     library: { seasons, newest: { id, title, premise, scene_count } } }
//
// Graceful absence: any fetch failure (plugin absent/disabled → 404,
// anonymous or non-allowed viewer → 403) renders NOTHING — the quiet
// empty state the Plaza requires. The block can never error onto the page.

@block("theme:community-plaza:campaign", {
  description:
    "Scripture Campaign — communal light meter when a run is live; the newest library season otherwise",
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

  get isRun() {
    return this.loaded && this.summary?.active === true;
  }

  get newest() {
    return this.summary?.library?.newest;
  }

  get isLibrary() {
    return this.loaded && !this.isRun && !!this.newest;
  }

  get visible() {
    return this.isRun || this.isLibrary;
  }

  get solo() {
    return this.summary?.solo || {};
  }

  get hasCommunityLight() {
    return (this.solo.walkers || 0) > 0;
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
    {{#if this.isRun}}
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

        <a class="block-plaza-campaign__library-link" href="/scripture-campaign">
          {{i18n (themePrefix "plaza.campaign.browse_library")}}
        </a>
      </div>
    {{else if this.isLibrary}}
      <div class="block-plaza-campaign__layout block-plaza-campaign--library">
        <h2 class="block-plaza-campaign__title">
          {{icon "fire"}}
          {{i18n (themePrefix "plaza.campaign.title")}}
        </h2>

        <div class="block-plaza-campaign__newest-tag">
          {{i18n (themePrefix "plaza.campaign.newest_tag")}}
        </div>
        <div class="block-plaza-campaign__season">{{this.newest.title}}</div>

        {{#if this.newest.premise}}
          <p class="block-plaza-campaign__premise">{{this.newest.premise}}</p>
        {{/if}}

        <p class="block-plaza-campaign__progress">
          {{this.newest.scene_count}}
          {{i18n (themePrefix "plaza.campaign.scenes_word")}}
        </p>

        {{#if this.hasCommunityLight}}
          <p class="block-plaza-campaign__community">
            {{icon "fire"}}
            {{this.solo.light_gathered}}
            {{i18n (themePrefix "plaza.campaign.community_light")}}
            · {{this.solo.walkers}}
            {{i18n (themePrefix "plaza.campaign.walkers_word")}}
          </p>
        {{/if}}

        <p class="block-plaza-campaign__lead">
          {{i18n (themePrefix "plaza.campaign.library_lead")}}
        </p>

        <a class="block-plaza-campaign__cta" href="/scripture-campaign">
          {{i18n (themePrefix "plaza.campaign.cta_library")}}
        </a>
      </div>
    {{/if}}
  </template>
}
