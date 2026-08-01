import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { block } from "discourse/blocks";
import { i18n } from "discourse-i18n";

const STORAGE_KEY = "plaza_quick_poll_vote";

@block("theme:community-plaza:quick-poll", {
  description: "Lightweight client-side poll for mood",
  args: {},
})
export default class BlockPlazaQuickPoll extends Component {
  @tracked voted = null;

  constructor() {
    super(...arguments);
    try {
      this.voted = window.localStorage?.getItem(STORAGE_KEY) || null;
    } catch {
      /* storage may be disabled */
    }
  }

  @action
  vote(option) {
    this.voted = option;
    try {
      window.localStorage?.setItem(STORAGE_KEY, option);
    } catch {
      /* ignore */
    }
  }

  <template>
    <div class="block-plaza-poll__layout">
      <h2 class="block-plaza-poll__title">
        {{i18n (themePrefix "plaza.quick_poll.title")}}
      </h2>
      <p class="block-plaza-poll__question">
        {{i18n (themePrefix "plaza.quick_poll.question")}}
      </p>
      {{#if this.voted}}
        <div class="block-plaza-poll__thanks">
          {{i18n (themePrefix "plaza.quick_poll.thanks")}}
        </div>
      {{else}}
        <div class="block-plaza-poll__options">
          <button
            type="button"
            class="block-plaza-poll__option"
            {{on "click" (fn this.vote "great")}}
          >
            {{i18n (themePrefix "plaza.quick_poll.option_great")}}
          </button>
          <button
            type="button"
            class="block-plaza-poll__option"
            {{on "click" (fn this.vote "okay")}}
          >
            {{i18n (themePrefix "plaza.quick_poll.option_okay")}}
          </button>
          <button
            type="button"
            class="block-plaza-poll__option"
            {{on "click" (fn this.vote "sleepy")}}
          >
            {{i18n (themePrefix "plaza.quick_poll.option_sleepy")}}
          </button>
        </div>
      {{/if}}
    </div>
  </template>
}
