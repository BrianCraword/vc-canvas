import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

// ── Block: Meet Your Guides ────────────────────────────────────────────
// Two equal-weight "doors" to the site's two user-facing AI agents:
//   • Logos — the matchmaker (for people who want to seek matches)
//   • Omega — the expositional Scripture teacher (for people who want to learn)
//
// Each door drops the user into the native AI Conversations interface with the
// chosen agent preselected in the composer's agent dropdown.
//
// HOW (verified live): the agent selector's source of truth is a localStorage
// key, `discourse_ai_agent_selector_id`. The composer reads it as its default
// agent on load. We WRITE that key to the desired agent id, then navigate to
// the conversations page — so it opens already set to the right guide, with no
// dropdown interaction and no query-param race (the stored value actually wins
// over the `?agent=` param, which is why we set it directly rather than pass a
// param). Confirmed both ways: key "1" → Matchmaker (Logos), "4" → Omega.
//
// Agent IDs are settings (Logos = 1, Omega = 4 on this site) so they can be
// corrected from the admin panel without code changes if the agents are ever
// recreated with different IDs.
const AGENT_LS_KEY = "discourse_ai_agent_selector_id";
const CONVERSATIONS_PATH = "/discourse-ai/ai-bot/conversations";

@block("theme:community-plaza:ai-guides", {
  description:
    "Two equal-weight doors to the AI guides: Logos (matchmaking) and Omega (Scripture)",
  args: {
    logosAgentId: { type: "number", default: 1 },
    omegaAgentId: { type: "number", default: 4 },
  },
})
export default class BlockPlazaAiGuides extends Component {
  @service router;

  openAgent(agentId) {
    // Write the selector's source-of-truth so the composer opens on this agent.
    try {
      window.localStorage.setItem(AGENT_LS_KEY, String(agentId));
    } catch {
      // localStorage may be unavailable (private mode etc.). Fall back to the
      // query param, which the page also reads (only loses to a *stored* value,
      // which we couldn't write here anyway).
      this.router.transitionTo(CONVERSATIONS_PATH, {
        queryParams: { agent: agentId },
      });
      return;
    }
    this.router.transitionTo(CONVERSATIONS_PATH);
  }

  @action
  openLogos() {
    this.openAgent(this.args.logosAgentId || 1);
  }

  @action
  openOmega() {
    this.openAgent(this.args.omegaAgentId || 4);
  }

  <template>
    <div class="block-plaza-ai-guides__layout">
      <h2 class="block-plaza-ai-guides__title">
        {{i18n (themePrefix "plaza.ai_guides.title")}}
      </h2>
      <p class="block-plaza-ai-guides__lead">
        {{i18n (themePrefix "plaza.ai_guides.lead")}}
      </p>

      <div class="block-plaza-ai-guides__doors">
        {{! Logos — matchmaking }}
        <button
          type="button"
          class="block-plaza-ai-guides__door block-plaza-ai-guides__door--logos"
          {{on "click" this.openLogos}}
        >
          <span class="block-plaza-ai-guides__icon">
            {{icon "heart"}}
          </span>
          <span class="block-plaza-ai-guides__name">
            {{i18n (themePrefix "plaza.ai_guides.logos.name")}}
          </span>
          <span class="block-plaza-ai-guides__tagline">
            {{i18n (themePrefix "plaza.ai_guides.logos.tagline")}}
          </span>
          <span class="block-plaza-ai-guides__cta">
            {{i18n (themePrefix "plaza.ai_guides.logos.cta")}}
          </span>
        </button>

        {{! Omega — Scripture teacher }}
        <button
          type="button"
          class="block-plaza-ai-guides__door block-plaza-ai-guides__door--omega"
          {{on "click" this.openOmega}}
        >
          <span class="block-plaza-ai-guides__icon">
            {{icon "book-open"}}
          </span>
          <span class="block-plaza-ai-guides__name">
            {{i18n (themePrefix "plaza.ai_guides.omega.name")}}
          </span>
          <span class="block-plaza-ai-guides__tagline">
            {{i18n (themePrefix "plaza.ai_guides.omega.tagline")}}
          </span>
          <span class="block-plaza-ai-guides__cta">
            {{i18n (themePrefix "plaza.ai_guides.omega.cta")}}
          </span>
        </button>
      </div>
    </div>
  </template>
}
