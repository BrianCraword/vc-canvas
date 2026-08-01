import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import avatar from "discourse/helpers/avatar";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import { plazaGet } from "../lib/plaza-fetch";

// ── Block: Community Leaderboard ───────────────────────────────────────
// Surfaces the discourse-gamification leaderboard on the homepage as a
// lively "winners circle" — a top-3 podium, the viewer's own rank, and a
// short ranked list — with a link to the full /leaderboard page.
//
// Reads the plugin's PUBLIC endpoint:
//   GET /leaderboard/{id}.json?period={period}&user_limit={n}
// (verified live: the bare /leaderboard.json 404s on this site — the
// explicit board id is required.) The endpoint is server-cached ~1 min.
//
// Response shape (verified):
//   leaderboard : { id, name, default_period, period_filter_disabled, ... }
//   users[]     : { id, username, name, avatar_template, total_score, position }
//   personal    : { user: {…same row shape…}, position }   (viewer's own rank)
//
// Each user row carries avatar_template, so the rows pass straight to the
// {{avatar}} helper (same as the Who's Online / New Faces blocks).
//
// Settings:
//   leaderboard_id     — which board to show (default 3, the public
//                        "Community" board; board 1 "Global" is group-gated)
//   leaderboard_period — all | yearly | quarterly | monthly | weekly | daily
//                        (string param names, verified). Default weekly so the
//                        board stays fresh and newcomers can win *this week*.
//   leaderboard_count  — how many ranked rows to list beneath the podium.
//
// Points are labelled "Cheers" to match the plugin's own warm framing.
//
// ── Glimmer strict-mode note ───────────────────────────────────────────
// ALL dynamic state is pre-computed in fetchBoard() and returned as plain
// properties. The podium's three slots are pre-split into named props
// (first/second/third) rather than indexed in the template; the "you" row
// arrives pre-shaped with a boolean discriminator. Templates read simple
// props and branch on booleans only — no method calls with args, no
// dynamic themePrefix keys.
@block("theme:community-plaza:leaderboard", {
  description:
    "Gamification leaderboard winners circle: top-3 podium, your rank, and a short list",
  args: {
    boardId: { type: "number", default: 3 },
    period: { type: "string", default: "weekly" },
    count: { type: "number", default: 5 },
  },
})
export default class BlockPlazaLeaderboard extends Component {
  @service currentUser;

  @bind
  async fetchBoard() {
    const boardId = this.args.boardId || 3;
    const period = this.args.period || "weekly";
    const listCount = this.args.count || 5;

    const url = `/leaderboard/${boardId}.json?period=${encodeURIComponent(
      period
    )}&user_limit=${listCount + 3}`;

    let users = [];
    let boardName = null;
    let personal = null;

    try {
      const data = await plazaGet(url);
      users = data?.users || [];
      boardName = data?.leaderboard?.name || null;
      personal = data?.personal?.user
        ? {
            ...data.personal.user,
            position: data.personal.position ?? data.personal.user.position,
          }
        : null;
    } catch {
      // No board, no access, or not yet computed → render nothing.
      users = [];
    }

    // Pre-split the podium. Each slot is null when the board has fewer
    // than that many ranked users (a brand-new board may have 0–2).
    const podium = users.slice(0, 3).map((u, i) => ({
      ...u,
      rank: u.position ?? i + 1,
      score: u.total_score ?? 0,
      displayName: u.name || u.username,
      href: `/u/${u.username}/summary`,
    }));

    // The ranked list beneath the podium: ranks 4..(3+listCount), i.e. the
    // rows below the podium so we don't repeat the top 3.
    const rows = users.slice(3, 3 + listCount).map((u) => ({
      ...u,
      rank: u.position,
      score: u.total_score ?? 0,
      displayName: u.name || u.username,
      href: `/u/${u.username}/summary`,
    }));

    // The viewer's own row. Show it only when the viewer is ranked AND not
    // already visible in the podium (positions 1–3 are already on the
    // podium, so a top-3 viewer doesn't need the extra "you" strip).
    let you = null;
    if (personal && personal.position) {
      you = {
        rank: personal.position,
        score: personal.total_score ?? 0,
        username: personal.username,
        inPodium: personal.position <= 3,
      };
    }

    return {
      hasBoard: podium.length > 0,
      boardName,
      boardHref: `/leaderboard/${boardId}`,
      first: podium[0] || null,
      second: podium[1] || null,
      third: podium[2] || null,
      hasSecond: !!podium[1],
      hasThird: !!podium[2],
      rows,
      hasRows: rows.length > 0,
      you,
      showYou: !!(you && !you.inPodium),
    };
  }

  <template>
    <AsyncContent @asyncData={{this.fetchBoard}}>
      <:loading>
        <div class="block-plaza-leaderboard__loading"><div class="spinner" /></div>
      </:loading>
      <:content as |data|>
        {{#if data.hasBoard}}
          <div class="block-plaza-leaderboard__layout">
            <h2 class="block-plaza-leaderboard__title">
              {{i18n (themePrefix "plaza.leaderboard.title")}}
            </h2>

            <div class="block-plaza-leaderboard__podium">
              {{! Second place — left }}
              {{#if data.hasSecond}}
                <a
                  class="block-plaza-leaderboard__slot block-plaza-leaderboard__slot--second"
                  href={{data.second.href}}
                >
                  <span class="block-plaza-leaderboard__avatar-wrap">
                    {{avatar data.second imageSize="large"}}
                    <span class="block-plaza-leaderboard__medal">2</span>
                  </span>
                  <span class="block-plaza-leaderboard__name">{{data.second.displayName}}</span>
                  <span class="block-plaza-leaderboard__score">{{data.second.score}}</span>
                </a>
              {{/if}}

              {{! First place — center, crowned }}
              <a
                class="block-plaza-leaderboard__slot block-plaza-leaderboard__slot--first"
                href={{data.first.href}}
              >
                <span class="block-plaza-leaderboard__crown">👑</span>
                <span class="block-plaza-leaderboard__avatar-wrap">
                  {{avatar data.first imageSize="huge"}}
                  <span class="block-plaza-leaderboard__medal">1</span>
                </span>
                <span class="block-plaza-leaderboard__name">{{data.first.displayName}}</span>
                <span class="block-plaza-leaderboard__score">{{data.first.score}}</span>
              </a>

              {{! Third place — right }}
              {{#if data.hasThird}}
                <a
                  class="block-plaza-leaderboard__slot block-plaza-leaderboard__slot--third"
                  href={{data.third.href}}
                >
                  <span class="block-plaza-leaderboard__avatar-wrap">
                    {{avatar data.third imageSize="large"}}
                    <span class="block-plaza-leaderboard__medal">3</span>
                  </span>
                  <span class="block-plaza-leaderboard__name">{{data.third.displayName}}</span>
                  <span class="block-plaza-leaderboard__score">{{data.third.score}}</span>
                </a>
              {{/if}}
            </div>

            {{! The viewer's own rank, when they're not already on the podium }}
            {{#if data.showYou}}
              <div class="block-plaza-leaderboard__you">
                <span class="block-plaza-leaderboard__you-rank">{{data.you.rank}}</span>
                <span class="block-plaza-leaderboard__you-label">
                  {{i18n (themePrefix "plaza.leaderboard.you")}}
                </span>
                <span class="block-plaza-leaderboard__you-score">
                  {{data.you.score}}
                  {{i18n (themePrefix "plaza.leaderboard.cheers")}}
                </span>
              </div>
            {{/if}}

            {{! Ranked rows beneath the podium }}
            {{#if data.hasRows}}
              <div class="block-plaza-leaderboard__rows">
                {{#each data.rows as |r|}}
                  <a class="block-plaza-leaderboard__row" href={{r.href}}>
                    <span class="block-plaza-leaderboard__row-rank">{{r.rank}}</span>
                    <span class="block-plaza-leaderboard__row-avatar">
                      {{avatar r imageSize="small"}}
                    </span>
                    <span class="block-plaza-leaderboard__row-name">{{r.displayName}}</span>
                    <span class="block-plaza-leaderboard__row-score">{{r.score}}</span>
                  </a>
                {{/each}}
              </div>
            {{/if}}

            <a class="block-plaza-leaderboard__all" href={{data.boardHref}}>
              {{i18n (themePrefix "plaza.leaderboard.view_all")}}
            </a>
          </div>
        {{/if}}
      </:content>
    </AsyncContent>
  </template>
}
