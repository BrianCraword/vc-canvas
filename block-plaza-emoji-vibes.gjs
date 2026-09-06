import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

// Default emoji set if reactions plugin isn't installed.
const DEFAULTS = [
  { emoji: "❤️", count: 0 },
  { emoji: "🤣", count: 0 },
  { emoji: "😜", count: 0 },
];

@block("theme:community-plaza:emoji-vibes", {
  description: "Top community reactions",
  args: {},
})
export default class BlockPlazaEmojiVibes extends Component {
  @bind
  async fetchVibes() {
    // Try the discourse-reactions endpoint; fall back gracefully if not present.
    try {
      const data = await plazaGet("/discourse-reactions/popular.json");
      const items = (data?.reactions || data || [])
        .map((r) => ({
          emoji: r.emoji || r.id || r.name,
          count: r.count || r.total_count || 0,
        }))
        .filter((r) => r.emoji)
        .slice(0, 3);
      if (items.length) return items;
    } catch {
      /* fall through */
    }
    // Fallback — just show default trio with no counts
    return DEFAULTS.map((d) => ({ ...d }));
  }

  <template>
    <AsyncContent @asyncData={{this.fetchVibes}}>
      <:loading>
        <div class="block-plaza-vibes__loading"></div>
      </:loading>
      <:content as |items|>
        <div class="block-plaza-vibes__layout">
          <h2 class="block-plaza-vibes__title">
            {{i18n (themePrefix "plaza.emoji_vibes.title")}}
          </h2>
          <div class="block-plaza-vibes__grid">
            {{#each items as |it|}}
              <div class="block-plaza-vibes__item">
                <div class="block-plaza-vibes__emoji">{{it.emoji}}</div>
                <div class="block-plaza-vibes__count">{{it.count}}</div>
              </div>
            {{/each}}
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
