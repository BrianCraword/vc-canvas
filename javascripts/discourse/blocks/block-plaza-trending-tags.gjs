import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { htmlSafe } from "@ember/template";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

@block("theme:community-plaza:trending-tags", {
  description: "Tag cloud sized by usage count",
  args: {
    count: { type: "number", default: 12 },
  },
})
export default class BlockPlazaTrendingTags extends Component {
  @bind
  async fetchTags() {
    const count = this.args.count || 12;
    try {
      const data = await plazaGet("/tags.json");
      const tags = (data?.tags || []).slice(0, count);
      const max = Math.max(...tags.map((t) => t.count || 0), 1);
      return tags.map((t) => {
        const weight = (t.count || 0) / max; // 0..1
        const size = (0.85 + weight * 0.9).toFixed(2);
        const opacity = (0.55 + weight * 0.45).toFixed(2);
        return {
          name: t.name,
          count: t.count || 0,
          style: htmlSafe(`font-size: ${size}rem; opacity: ${opacity};`),
        };
      });
    } catch {
      return [];
    }
  }

  <template>
    <AsyncContent @asyncData={{this.fetchTags}}>
      <:loading>
        <div class="block-plaza-tags__loading"><div class="spinner" /></div>
      </:loading>
      <:empty>
        {{! render nothing when there are no tags — an empty card reads as broken }}
      </:empty>
      <:content as |tags|>
        <div class="block-plaza-tags__layout">
          <h2 class="block-plaza-tags__title">
            {{i18n (themePrefix "plaza.trending_tags.title")}}
          </h2>
          <div class="block-plaza-tags__cloud">
            {{#each tags as |tag|}}
              <a
                href="/tag/{{tag.name}}"
                class="block-plaza-tags__tag"
                style={{tag.style}}
              >
                {{tag.name}}
              </a>
            {{/each}}
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
