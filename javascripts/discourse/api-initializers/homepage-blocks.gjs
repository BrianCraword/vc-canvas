import BlockGroup from "discourse/blocks/builtin/block-group";
import { apiInitializer } from "discourse/lib/api";
import BlockPlazaAiGuides from "../blocks/block-plaza-ai-guides";
import BlockPlazaCampaign from "../blocks/block-plaza-campaign";
import BlockPlazaCommunityMood from "../blocks/block-plaza-community-mood";
import BlockPlazaEmojiVibes from "../blocks/block-plaza-emoji-vibes";
import BlockPlazaHotTopics from "../blocks/block-plaza-hot-topics";
import BlockPlazaLeaderboard from "../blocks/block-plaza-leaderboard";
import BlockPlazaLegendaryThread from "../blocks/block-plaza-legendary-thread";
import BlockPlazaLuckyDraw from "../blocks/block-plaza-lucky-draw";
import BlockPlazaMyMatches from "../blocks/block-plaza-my-matches";
import BlockPlazaNewFaces from "../blocks/block-plaza-new-faces";
import BlockPlazaProfileStatus from "../blocks/block-plaza-profile-status";
import BlockPlazaQuickPoll from "../blocks/block-plaza-quick-poll";
import BlockPlazaQuoteOfDay from "../blocks/block-plaza-quote-of-day";
import BlockPlazaStaffPicks from "../blocks/block-plaza-staff-picks";
import BlockPlazaTrendingTags from "../blocks/block-plaza-trending-tags";
import BlockPlazaTrivia from "../blocks/block-plaza-trivia";
import BlockPlazaWeeklyRankings from "../blocks/block-plaza-weekly-rankings";
import BlockPlazaWhosOnline from "../blocks/block-plaza-whos-online";

// ── Homepage block registration ────────────────────────────────────────
// Each block is declared ONCE below with its component, its child id, its
// args, and the SETTING that decides which desktop column it lives in. The
// three BlockGroup columns are then built by filtering this list on the
// column setting — so a block can be reassigned to a different desktop
// column from the admin panel (e.g. move New Faces to the right column)
// without editing this file.
//
// How the three positioning systems compose:
//   • {block}_column  → which desktop column (left | middle | right)
//   • {block}_*_order → position WITHIN that column on desktop, and the
//                       global position in the single mobile stack
//                       (handled by block-ordering.gjs + block-ordering.scss)
// On MOBILE the columns dissolve (display:contents) into one global stack,
// so column assignment is a desktop-only concern — exactly as intended.
//
// NOTE: column defaults reproduce the current layout, so nothing moves until
// a *_column setting is changed. When you move a block to a new column, also
// set its desktop order to fit its new neighbors (orders were numbered
// per-column, so a moved block may otherwise tie with an existing one; ties
// fall back to source order, which is harmless but can surprise).

export default apiInitializer((api) => {
  // The full block catalog. `column` reads the per-block setting; each falls
  // back to its original column so a missing/blank setting can't strand a
  // block. `def` is the block's renderBlocks descriptor.
  const CATALOG = [
    {
      column: settings.column_profile_status,
      def: { block: BlockPlazaProfileStatus, id: "plaza-profile-status" },
      home: "left",
    },
    {
      column: settings.column_my_matches,
      def: {
        block: BlockPlazaMyMatches,
        id: "plaza-my-matches",
        args: { count: settings.my_matches_count },
      },
      home: "left",
    },
    {
      column: settings.column_hot_topics,
      def: {
        block: BlockPlazaHotTopics,
        id: "plaza-hot-topics",
        args: {
          count: settings.hot_topics_count,
          threshold: settings.hot_topics_threshold,
        },
      },
      home: "left",
    },
    {
      column: settings.column_new_faces,
      def: {
        block: BlockPlazaNewFaces,
        id: "plaza-new-faces",
        args: { count: settings.new_faces_count },
      },
      home: "left",
    },
    {
      column: settings.column_staff_picks,
      def: {
        block: BlockPlazaStaffPicks,
        id: "plaza-staff-picks",
        args: { topicId: settings.staff_pick_topic_id },
      },
      home: "left",
    },
    {
      column: settings.column_quote,
      def: { block: BlockPlazaQuoteOfDay, id: "plaza-quote" },
      home: "left",
    },
    {
      column: settings.column_leaderboard,
      def: {
        block: BlockPlazaLeaderboard,
        id: "plaza-leaderboard",
        args: {
          boardId: settings.gamification_id,
          period: settings.gamification_period,
          count: settings.gamification_count,
        },
      },
      home: "middle",
    },
    {
      column: settings.column_trivia,
      def: { block: BlockPlazaTrivia, id: "plaza-trivia" },
      home: "middle",
    },
    {
      column: settings.column_campaign,
      def: { block: BlockPlazaCampaign, id: "plaza-campaign" },
      home: "middle",
    },
    {
      column: settings.column_rankings,
      def: {
        block: BlockPlazaWeeklyRankings,
        id: "plaza-rankings",
        args: { count: settings.leaderboard_count },
      },
      home: "middle",
    },
    {
      column: settings.column_mood,
      def: { block: BlockPlazaCommunityMood, id: "plaza-mood" },
      home: "middle",
    },
    {
      column: settings.column_legendary,
      def: { block: BlockPlazaLegendaryThread, id: "plaza-legendary" },
      home: "middle",
    },
    {
      column: settings.column_ad,
      def: {
        block: BlockPlazaAiGuides,
        id: "plaza-ad",
        args: {
          logosAgentId: settings.ai_guides_logos_agent_id,
          omegaAgentId: settings.ai_guides_omega_agent_id,
        },
      },
      home: "middle",
    },
    {
      column: settings.column_whos_online,
      def: {
        block: BlockPlazaWhosOnline,
        id: "plaza-whos-online",
        args: { count: settings.whos_online_count },
      },
      home: "right",
    },
    {
      column: settings.column_lucky,
      def: { block: BlockPlazaLuckyDraw, id: "plaza-lucky" },
      home: "right",
    },
    {
      column: settings.column_poll,
      def: { block: BlockPlazaQuickPoll, id: "plaza-poll" },
      home: "right",
    },
    {
      column: settings.column_vibes,
      def: { block: BlockPlazaEmojiVibes, id: "plaza-vibes" },
      home: "right",
    },
    {
      column: settings.column_tags,
      def: {
        block: BlockPlazaTrendingTags,
        id: "plaza-tags",
        args: { count: settings.trending_tags_count },
      },
      home: "right",
    },
  ];

  // Resolve a block's column: use its setting when it's a valid column,
  // otherwise fall back to its home column. This makes a blank or typo'd
  // setting safe — a block can never be dropped off the page.
  const resolveColumn = (entry) => {
    const v = entry.column;
    if (v === "left" || v === "middle" || v === "right") {
      return v;
    }
    return entry.home;
  };

  const childrenIn = (name) =>
    CATALOG.filter((b) => resolveColumn(b) === name).map((b) => b.def);

  api.renderBlocks("homepage-blocks", [
    {
      block: BlockGroup,
      id: "plaza-left",
      children: childrenIn("left"),
    },
    {
      block: BlockGroup,
      id: "plaza-middle",
      children: childrenIn("middle"),
    },
    {
      block: BlockGroup,
      id: "plaza-right",
      children: childrenIn("right"),
    },
  ]);
});
