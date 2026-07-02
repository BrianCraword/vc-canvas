import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

@block("theme:community-plaza:community-mood", {
  description: "Three stat boxes: posts today, new threads, hearts given",
  args: {},
})
export default class BlockPlazaCommunityMood extends Component {
  @bind
  async fetchStats() {
    // Use the public /about.json which contains site stats.
    let posts = 0;
    let topics = 0;
    let likes = 0;
    try {
      const data = await plazaGet("/about.json");
      const stats = data?.about?.stats || {};
      posts = stats.posts_last_day ?? stats.posts_7_days ?? 0;
      topics = stats.topics_last_day ?? stats.topics_7_days ?? 0;
      likes = stats.likes_7_days ?? stats.likes_30_days ?? 0;
    } catch {
      /* fall back to zeros */
    }
    return { posts, topics, likes };
  }

  <template>
    <AsyncContent @asyncData={{this.fetchStats}}>
      <:loading>
        <div class="block-plaza-mood__loading"><div class="spinner" /></div>
      </:loading>
      <:content as |s|>
        <div class="block-plaza-mood__layout">
          <h2 class="block-plaza-mood__title">
            {{i18n (themePrefix "plaza.community_mood.title")}}
          </h2>
          <div class="block-plaza-mood__grid">
            <div class="block-plaza-mood__stat --pink">
              <div class="block-plaza-mood__num">{{s.posts}}</div>
              <div class="block-plaza-mood__label">
                {{i18n (themePrefix "plaza.community_mood.posts_today")}}
              </div>
            </div>
            <div class="block-plaza-mood__stat --purple">
              <div class="block-plaza-mood__num">{{s.topics}}</div>
              <div class="block-plaza-mood__label">
                {{i18n (themePrefix "plaza.community_mood.new_threads")}}
              </div>
            </div>
            <div class="block-plaza-mood__stat --mint">
              <div class="block-plaza-mood__num">{{s.likes}}</div>
              <div class="block-plaza-mood__label">
                {{i18n (themePrefix "plaza.community_mood.hearts_given")}}
              </div>
            </div>
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
