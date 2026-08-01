import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import { i18n } from "discourse-i18n";
import { plazaTopicList } from "../lib/plaza-fetch";

@block("theme:community-plaza:lucky-draw", {
  description: "Click to draw a random topic title",
  args: {},
})
export default class BlockPlazaLuckyDraw extends Component {
  @service store;
  @tracked currentTopic = null;
  @tracked topics = [];

  constructor() {
    super(...arguments);
    this.loadTopics();
  }

  async loadTopics() {
    try {
      const list = await plazaTopicList(this.store, "latest");
      this.topics = list?.topics || [];
      this.draw();
    } catch {
      this.topics = [];
    }
  }

  @action
  draw() {
    if (!this.topics.length) return;
    const i = Math.floor(Math.random() * this.topics.length);
    this.currentTopic = this.topics[i];
  }

  <template>
    <div class="block-plaza-lucky__layout">
      <h2 class="block-plaza-lucky__title">
        {{i18n (themePrefix "plaza.lucky_draw.title")}}
      </h2>
      <p class="block-plaza-lucky__subtitle">
        {{i18n (themePrefix "plaza.lucky_draw.subtitle")}}
      </p>
      {{#if this.currentTopic}}
        <a
          href="/t/{{this.currentTopic.slug}}/{{this.currentTopic.id}}"
          class="block-plaza-lucky__pick"
        >
          {{this.currentTopic.fancy_title}}
        </a>
      {{else}}
        <div class="block-plaza-lucky__pick block-plaza-lucky__pick--empty">…</div>
      {{/if}}
      <button
        type="button"
        class="block-plaza-lucky__button"
        {{on "click" this.draw}}
      >
        🎲
        {{i18n (themePrefix "plaza.lucky_draw.button")}}
      </button>
    </div>
  </template>
}
