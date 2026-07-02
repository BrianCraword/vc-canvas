import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaTopicList } from "../lib/plaza-fetch";

@block("theme:community-plaza:legendary-thread", {
  description: "The most-replied topic from the recent period",
  args: {},
})
export default class BlockPlazaLegendaryThread extends Component {
  @service store;

  @bind
  async fetchThread() {
    let topicList = await plazaTopicList(this.store, "top");
    if (!topicList?.topics?.length) {
      topicList = await plazaTopicList(this.store, "latest");
    }
    const topics = topicList?.topics || [];
    if (!topics.length) return null;
    const sorted = [...topics].sort(
      (a, b) => (b.posts_count || 0) - (a.posts_count || 0)
    );
    return sorted[0];
  }

  <template>
    <AsyncContent @asyncData={{this.fetchThread}}>
      <:loading>
        <div class="block-plaza-legendary__loading"><div class="spinner" /></div>
      </:loading>
      <:empty>
        <div class="block-plaza-legendary__empty">No legendary thread yet.</div>
      </:empty>
      <:content as |t|>
        <div class="block-plaza-legendary__layout">
          <h2 class="block-plaza-legendary__title">
            {{i18n (themePrefix "plaza.legendary_thread.title")}}
          </h2>
          <p class="block-plaza-legendary__subtitle">
            {{i18n (themePrefix "plaza.legendary_thread.subtitle")}}
          </p>
          <a
            class="block-plaza-legendary__card"
            href="/t/{{t.slug}}/{{t.id}}"
          >
            <span class="block-plaza-legendary__trophy">🏆</span>
            <span class="block-plaza-legendary__body">
              <span class="block-plaza-legendary__topic-title">{{t.fancy_title}}</span>
              <span class="block-plaza-legendary__stats">
                <span>{{t.posts_count}}&nbsp;{{i18n (themePrefix "plaza.legendary_thread.replies")}}</span>
                <span>{{t.like_count}}&nbsp;{{i18n (themePrefix "plaza.legendary_thread.likes")}}</span>
                <span>{{t.views}}&nbsp;{{i18n (themePrefix "plaza.legendary_thread.views")}}</span>
              </span>
            </span>
          </a>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
