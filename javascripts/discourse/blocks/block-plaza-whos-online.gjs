import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import avatar from "discourse/helpers/avatar";
import { i18n } from "discourse-i18n";

@block("theme:community-plaza:whos-online", {
  description: "Live avatar row of members currently active on the site",
  args: {
    count: { type: "number", default: 12 },
  },
})
export default class BlockPlazaWhosOnline extends Component {
  @service whosOnline;

  // The whos-online plugin's own gate: respects login_required for anon,
  // and whos_online_display_public / min-trust-level for everyone else.
  get enabled() {
    return this.whosOnline?.enabled ?? false;
  }

  get count() {
    return this.whosOnline?.count ?? 0;
  }

  // Visible avatars, capped by this block's own count arg.
  get users() {
    const max = this.args.count || 12;
    return (this.whosOnline?.users ?? []).slice(0, max);
  }

  get hasUsers() {
    return this.users.length > 0;
  }

  // How many more are online beyond the avatars we render.
  get overflow() {
    const extra = this.count - this.users.length;
    return extra > 0 ? extra : 0;
  }

  get hasOverflow() {
    return this.overflow > 0;
  }

  // Count-only mode (plugin setting whos_online_count_only) yields a count
  // with no user list. Show the count even when we have no avatars.
  get hasCount() {
    return this.count > 0;
  }

  <template>
    {{#if this.enabled}}
      <div class="block-plaza-whos-online__layout">
        <h2 class="block-plaza-whos-online__title">
          {{i18n (themePrefix "plaza.whos_online.title")}}
        </h2>

        {{#if this.hasUsers}}
          <div class="block-plaza-whos-online__grid">
            {{#each this.users as |u|}}
              <a
                class="block-plaza-whos-online__face"
                href="/u/{{u.username}}/summary"
                data-user-card={{u.username}}
                title={{u.username}}
              >
                {{avatar u imageSize="large"}}
              </a>
            {{/each}}
            {{#if this.hasOverflow}}
              <span class="block-plaza-whos-online__overflow">
                +{{this.overflow}}
              </span>
            {{/if}}
          </div>
          <p class="block-plaza-whos-online__footer">
            {{this.count}}
            {{i18n (themePrefix "plaza.whos_online.active_now")}}
          </p>
        {{else if this.hasCount}}
          <p class="block-plaza-whos-online__count-only">
            {{this.count}}
            {{i18n (themePrefix "plaza.whos_online.active_now")}}
          </p>
        {{else}}
          <p class="block-plaza-whos-online__empty">
            {{i18n (themePrefix "plaza.whos_online.nobody")}}
          </p>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
