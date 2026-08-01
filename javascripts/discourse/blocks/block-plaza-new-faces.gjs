import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import avatar from "discourse/helpers/avatar";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

@block("theme:community-plaza:new-faces", {
  description: "Grid of newest community members",
  args: {
    count: { type: "number", default: 8 },
  },
})
export default class BlockPlazaNewFaces extends Component {
  @bind
  async fetchUsers() {
    const count = this.args.count || 8;
    try {
      const data = await plazaGet("/directory_items.json", {
        period: "all",
        order: "days_visited",
      });
      if (!data) {
        return [];
      }
      // Sort by signup date desc — newest first
      const items = (data.directory_items || [])
        .map((d) => d.user)
        .filter(Boolean)
        .sort((a, b) => {
          const ad = new Date(a.created_at || 0).getTime();
          const bd = new Date(b.created_at || 0).getTime();
          return bd - ad;
        });
      return items.slice(0, count);
    } catch {
      return [];
    }
  }

  <template>
    <AsyncContent @asyncData={{this.fetchUsers}}>
      <:loading>
        <div class="block-plaza-new-faces__loading"><div class="spinner" /></div>
      </:loading>
      <:empty>
        {{! render nothing when there is no data — an empty card reads as broken }}
      </:empty>
      <:content as |users|>
        <div class="block-plaza-new-faces__layout">
          <h2 class="block-plaza-new-faces__title">
            {{i18n (themePrefix "plaza.new_faces.title")}}
          </h2>
          <div class="block-plaza-new-faces__grid">
            {{#each users as |u|}}
              <a
                class="block-plaza-new-faces__face"
                href="/u/{{u.username}}"
                data-user-card={{u.username}}
              >
                {{avatar u imageSize="large"}}
                <span class="block-plaza-new-faces__name">{{u.username}}</span>
              </a>
            {{/each}}
          </div>
          <p class="block-plaza-new-faces__footer">
            {{i18n (themePrefix "plaza.new_faces.welcome")}}
          </p>
        </div>
      </:content>
    </AsyncContent>
  </template>
}
