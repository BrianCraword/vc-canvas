import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import avatar from "discourse/helpers/avatar";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaTopicList } from "../lib/plaza-fetch";

@block("theme:community-plaza:quote-of-day", {
  description: "Featured quote pulled from a recent post",
  args: {},
})
export default class BlockPlazaQuoteOfDay extends Component {
  @service store;

  @bind
  async fetchQuote() {
    // Pull a recent topic with replies, get its excerpt or last poster info.
    const topicList = await plazaTopicList(this.store, "top");
    const topics = (topicList?.topics || []).filter(
      (t) => (t.excerpt || "").length > 60 && t.posts_count > 1
    );
    if (!topics.length) {
      return null;
    }
    // Deterministic-ish pick by day-of-year
    const day = Math.floor(Date.now() / (1000 * 60 * 60 * 24));
    const pick = topics[day % topics.length];
    return {
      excerpt: (pick.excerpt || "").replace(/<[^>]+>/g, "").trim(),
      poster:
        pick.last_poster_username ||
        pick.posters?.[0]?.user?.username ||
        "anon",
      posterAvatar:
        pick.posters?.[pick.posters.length - 1]?.user ||
        pick.posters?.[0]?.user,
      likeCount: pick.like_count || 0,
      slug: pick.slug,
      id: pick.id,
    };
  }

  <template>
    <AsyncContent @asyncData={{this.fetchQuote}}>
      <:loading>
        <div class="block-plaza-quote__loading"><div class="spinner" /></div>
      </:loading>
      <:empty>
        <div class="block-plaza-quote__empty">No quotes yet.</div>
      </:empty>
      <:content as |q|>
        <div class="block-plaza-quote__layout">
          <h2 class="block-plaza-quote__title">
            {{i18n (themePrefix "plaza.quote_of_day.title")}}
          </h2>
          <a
            href="/t/{{q.slug}}/{{q.id}}"
            class="block-plaza-quote__body"
          >
            <p class="block-plaza-quote__text">
              {{q.excerpt}}
            </p>
            <div class="block-plaza-quote__footer">
              <span class="block-plaza-quote__author">
                {{#if q.posterAvatar}}
                  {{avatar q.posterAvatar imageSize="small"}}
                {{/if}}
                <span>{{q.poster}}</span>
              </span>
              <span class="block-plaza-quote__likes">
                {{q.likeCount}}&nbsp;♥
              </span>
            </div>
          </a>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
