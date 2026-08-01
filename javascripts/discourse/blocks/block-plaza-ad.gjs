import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import { i18n } from "discourse-i18n";

@block("theme:community-plaza:ad", {
  description: "Promotional placeholder block",
  args: {
    title: { type: "string" },
    description: { type: "string" },
    buttonLabel: { type: "string" },
    buttonLink: { type: "string" },
  },
})
export default class BlockPlazaAd extends Component {
  get title() {
    return this.args.title || settings.ad_title;
  }
  get description() {
    return this.args.description || settings.ad_description;
  }
  get buttonLabel() {
    return this.args.buttonLabel || settings.ad_button_label;
  }
  get buttonLink() {
    return this.args.buttonLink || settings.ad_button_link;
  }

  <template>
    <div class="block-plaza-ad__layout">
      <span class="block-plaza-ad__tag">
        {{i18n (themePrefix "plaza.ad.label")}}
      </span>
      <h2 class="block-plaza-ad__title">{{this.title}}</h2>
      <p class="block-plaza-ad__desc">{{this.description}}</p>
      <a class="block-plaza-ad__btn" href={{this.buttonLink}}>
        {{this.buttonLabel}}
      </a>
    </div>
  </template>
}
