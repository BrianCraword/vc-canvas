import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { gte } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import { plazaTopicList } from "../lib/plaza-fetch";

@block("theme:community-plaza:hot-topics", {
  description: "Top topics this period with HOT badges",
  args: {
    count: { type: "number", default: 5 },
    threshold: { type: "number", default: 10 },
  },
})
export default class BlockPlazaHotTopics extends Component {
  @service store;

  @bind
  async fetchTopics() {
    const count = this.args.count || 5;
    let topicList = await plazaTopicList(this.store, "hot");
    if (!topicList?.topics?.length) {
      topicList = await plazaTopicList(this.store, "top");
    }
    if (!topicList?.topics?.length) {
      topicList = await plazaTopicList(this.store, "latest");
    }
    return (topicList?.topics || []).slice(0, count);
  }

  <template>
    <AsyncContent @asyncData={{this.fetchTopics}}>
      <:loading>
        <div class="block-plaza-hot-topics__loading"><div class="spinner" /></div>
      </:loading>
      <:empty>
        <div class="block-plaza-hot-topics__empty">No topics yet.</div>
      </:empty>
      <:content as |topics|>
        <div class="block-plaza-hot-topics__layout">
          <h2 class="block-plaza-hot-topics__title">
            {{i18n (themePrefix "plaza.hot_topics.title")}}
          </h2>
          <ul class="block-plaza-hot-topics__list">
            {{#each topics as |t|}}
              <li class="block-plaza-hot-topics__item">
                {{#if (gte t.posts_count @threshold)}}
                  <span class="block-plaza-hot-topics__badge">
                    {{i18n (themePrefix "plaza.hot_topics.hot_badge")}}
                  </span>
                {{/if}}
                <a
                  class="block-plaza-hot-topics__link"
                  href="/t/{{t.slug}}/{{t.id}}"
                >{{t.fancy_title}}</a>
                <span class="block-plaza-hot-topics__count">
                  ({{t.posts_count}})
                </span>
              </li>
            {{/each}}
          </ul>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
