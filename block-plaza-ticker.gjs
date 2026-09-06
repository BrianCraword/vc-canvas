import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaTopicList } from "../lib/plaza-fetch";

@block("theme:community-plaza:ticker", {
  description: "Animated NEW topics ticker bar",
  args: {
    count: { type: "number", default: 5 },
  },
})
export default class BlockPlazaTicker extends Component {
  @service store;

  @bind
  async fetchTopics() {
    const count = this.args.count || 5;
    const topicList = await plazaTopicList(this.store, "new");
    if (!topicList?.topics?.length) {
      // Fall back to latest if there are no "new" topics
      const latest = await plazaTopicList(this.store, "latest");
      return (latest?.topics || []).slice(0, count);
    }
    return topicList.topics.slice(0, count);
  }

  <template>
    <AsyncContent @asyncData={{this.fetchTopics}}>
      <:loading>
        <div class="block-plaza-ticker__loading"></div>
      </:loading>
      <:empty>
        <div class="block-plaza-ticker__empty"></div>
      </:empty>
      <:content as |topics|>
        <div class="block-plaza-ticker__layout">
          <span class="block-plaza-ticker__label">
            {{i18n (themePrefix "plaza.ticker.label")}}
          </span>
          <div class="block-plaza-ticker__track">
            <div class="block-plaza-ticker__inner">
              {{#each topics as |t|}}
                <a
                  href="/t/{{t.slug}}/{{t.id}}"
                  class="block-plaza-ticker__item"
                >
                  {{t.fancy_title}}
                </a>
                <span class="block-plaza-ticker__sep">✦</span>
              {{/each}}
              {{! duplicate for seamless loop }}
              {{#each topics as |t|}}
                <a
                  href="/t/{{t.slug}}/{{t.id}}"
                  class="block-plaza-ticker__item"
                >
                  {{t.fancy_title}}
                </a>
                <span class="block-plaza-ticker__sep">✦</span>
              {{/each}}
            </div>
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
