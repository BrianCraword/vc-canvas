import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import avatar from "discourse/helpers/avatar";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

@block("theme:community-plaza:weekly-rankings", {
  description: "Two-column user rankings (Most Generous + Most Active)",
  args: {
    count: { type: "number", default: 10 },
  },
})
export default class BlockPlazaWeeklyRankings extends Component {
  @bind
  async fetchRankings() {
    const count = this.args.count || 10;

    const fetchPeriod = async (order, period) => {
      try {
        const data = await plazaGet("/directory_items.json", { period, order });
        return (data?.directory_items || [])
          .map((d) => ({
            user: d.user,
            score: d[order] ?? 0,
          }))
          .filter((r) => r.user);
      } catch {
        return [];
      }
    };

    const annotate = (rows) =>
      rows.slice(0, count).map((r, i) => ({ ...r, rank: i + 1 }));

    let generous = await fetchPeriod("likes_given", "weekly");
    let active = await fetchPeriod("days_visited", "weekly");
    if (!generous.length) {
      generous = await fetchPeriod("likes_given", "all");
    }
    if (!active.length) {
      active = await fetchPeriod("days_visited", "all");
    }
    return {
      generous: annotate(generous),
      active: annotate(active),
    };
  }

  <template>
    <AsyncContent @asyncData={{this.fetchRankings}}>
      <:loading>
        <div class="block-plaza-rankings__loading"><div class="spinner" /></div>
      </:loading>
      <:empty>
        <div class="block-plaza-rankings__empty">No rankings yet.</div>
      </:empty>
      <:content as |data|>
        <div class="block-plaza-rankings__layout">
          <h2 class="block-plaza-rankings__title">
            {{i18n (themePrefix "plaza.weekly_rankings.title")}}
          </h2>
          <div class="block-plaza-rankings__columns">
            <div class="block-plaza-rankings__col">
              <div class="block-plaza-rankings__col-title --pink">
                {{i18n (themePrefix "plaza.weekly_rankings.most_generous")}}
              </div>
              <ol class="block-plaza-rankings__list">
                {{#each data.generous as |row|}}
                  <li class="block-plaza-rankings__row">
                    <span class="block-plaza-rankings__rank">{{row.rank}}.</span>
                    <a
                      class="block-plaza-rankings__user"
                      href="/u/{{row.user.username}}"
                      data-user-card={{row.user.username}}
                    >
                      {{avatar row.user imageSize="tiny"}}
                      <span class="block-plaza-rankings__name">{{row.user.username}}</span>
                    </a>
                    <span class="block-plaza-rankings__score">{{row.score}}</span>
                  </li>
                {{/each}}
              </ol>
            </div>
            <div class="block-plaza-rankings__col">
              <div class="block-plaza-rankings__col-title --purple">
                {{i18n (themePrefix "plaza.weekly_rankings.most_active")}}
              </div>
              <ol class="block-plaza-rankings__list">
                {{#each data.active as |row|}}
                  <li class="block-plaza-rankings__row">
                    <span class="block-plaza-rankings__rank">{{row.rank}}.</span>
                    <a
                      class="block-plaza-rankings__user"
                      href="/u/{{row.user.username}}"
                      data-user-card={{row.user.username}}
                    >
                      {{avatar row.user imageSize="tiny"}}
                      <span class="block-plaza-rankings__name">{{row.user.username}}</span>
                    </a>
                    <span class="block-plaza-rankings__score">{{row.score}}</span>
                  </li>
                {{/each}}
              </ol>
            </div>
          </div>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
