import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaGet, plazaTopicList } from "../lib/plaza-fetch";

@block("theme:community-plaza:staff-picks", {
  description: "A staff-curated topic to highlight",
  args: {
    topicId: { type: "number" },
  },
})
export default class BlockPlazaStaffPicks extends Component {
  @service store;

  @bind
  async fetchPick() {
    // Try the explicit topic id first
    if (this.args.topicId && this.args.topicId > 0) {
      try {
        const t = await plazaGet(`/t/${this.args.topicId}.json`);
        if (!t) {
          throw new Error("unavailable");
        }
        return {
          id: t.id,
          slug: t.slug,
          title: t.fancy_title || t.title,
          excerpt: t.posts_count
            ? (t.post_stream?.posts?.[0]?.cooked || "").replace(/<[^>]+>/g, "").slice(0, 200)
            : "",
        };
      } catch {
        /* fall through */
      }
    }
    // Otherwise: first staff-authored topic in latest
    const latest = await plazaTopicList(this.store, "latest");
    const topics = latest?.topics || [];
    const staffPick =
      topics.find((t) => t.last_poster_username === "system") ||
      topics.find((t) => t.posters?.some((p) => p.user?.admin || p.user?.moderator)) ||
      topics[0];
    if (!staffPick) {
      return null;
    }
    return {
      id: staffPick.id,
      slug: staffPick.slug,
      title: staffPick.fancy_title || staffPick.title,
      excerpt: staffPick.excerpt || "",
    };
  }

  <template>
    <AsyncContent @asyncData={{this.fetchPick}}>
      <:loading>
        <div class="block-plaza-staff-picks__loading"><div class="spinner" /></div>
      </:loading>
      <:empty>
        <div class="block-plaza-staff-picks__empty">No staff picks yet.</div>
      </:empty>
      <:content as |pick|>
        <div class="block-plaza-staff-picks__layout">
          <h2 class="block-plaza-staff-picks__title">
            {{i18n (themePrefix "plaza.staff_picks.title")}}
          </h2>
          <a
            href="/t/{{pick.slug}}/{{pick.id}}"
            class="block-plaza-staff-picks__card"
          >
            <span class="block-plaza-staff-picks__thumb"></span>
            <span class="block-plaza-staff-picks__body">
              <span class="block-plaza-staff-picks__badge">
                {{i18n (themePrefix "plaza.staff_picks.badge")}}
              </span>
              <span class="block-plaza-staff-picks__pick-title">
                {{pick.title}}
              </span>
            </span>
          </a>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
