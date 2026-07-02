import { apiInitializer } from "discourse/lib/api";

// Per-block ordering for the Community Plaza homepage.
//
// Reads two integer settings per block (a desktop order and a mobile order) and
// injects a single <style> element that maps each block's data-block-id to CSS
// custom properties. The static stylesheet (layouts/block-ordering.scss)
// consumes those properties:
//   - desktop (>900px): blocks sort WITHIN their column via --desktop-order
//   - mobile (<=900px): columns dissolve (display:contents) and ALL blocks sort
//     globally via --mobile-order
//
// Every block is listed here so each always receives an explicit value. A block
// left unset would fall back to order:0 and jump to the top of its context, so
// the registry below must stay in sync with the block list in
// homepage-blocks.gjs. Defaults reproduce the current visual layout exactly:
// desktop = sequence within each column; mobile = left column, then middle,
// then right (10,20,30… leaving gaps to insert between later).

const BLOCKS = [
  // id                     desktopSetting                 mobileSetting
  ["plaza-profile-status", "order_profile_status_desktop", "order_profile_status_mobile"],
  ["plaza-my-matches", "order_my_matches_desktop", "order_my_matches_mobile"],
  ["plaza-hot-topics", "order_hot_topics_desktop", "order_hot_topics_mobile"],
  ["plaza-new-faces", "order_new_faces_desktop", "order_new_faces_mobile"],
  ["plaza-staff-picks", "order_staff_picks_desktop", "order_staff_picks_mobile"],
  ["plaza-quote", "order_quote_desktop", "order_quote_mobile"],
  ["plaza-leaderboard", "order_leaderboard_desktop", "order_leaderboard_mobile"],
  ["plaza-rankings", "order_rankings_desktop", "order_rankings_mobile"],
  ["plaza-trivia", "order_trivia_desktop", "order_trivia_mobile"],
  ["plaza-campaign", "order_campaign_desktop", "order_campaign_mobile"],
  ["plaza-mood", "order_mood_desktop", "order_mood_mobile"],
  ["plaza-legendary", "order_legendary_desktop", "order_legendary_mobile"],
  ["plaza-ad", "order_ad_desktop", "order_ad_mobile"],
  ["plaza-whos-online", "order_whos_online_desktop", "order_whos_online_mobile"],
  ["plaza-lucky", "order_lucky_desktop", "order_lucky_mobile"],
  ["plaza-poll", "order_poll_desktop", "order_poll_mobile"],
  ["plaza-vibes", "order_vibes_desktop", "order_vibes_mobile"],
  ["plaza-tags", "order_tags_desktop", "order_tags_mobile"],
];

const STYLE_ID = "plaza-block-ordering";

export default apiInitializer(() => {
  // Build the values stylesheet from settings.
  const rules = BLOCKS.map(([id, desktopKey, mobileKey]) => {
    const desktop = settings[desktopKey];
    const mobile = settings[mobileKey];
    return (
      `.homepage-blocks__block[data-block-id="${id}"]{` +
      `--desktop-order:${desktop};` +
      `--mobile-order:${mobile};}`
    );
  }).join("\n");

  // Inject once, idempotently (replace if a previous version exists, e.g. after
  // a settings change triggers a re-init in the same session).
  let style = document.getElementById(STYLE_ID);
  if (!style) {
    style = document.createElement("style");
    style.id = STYLE_ID;
    document.head.appendChild(style);
  }
  style.textContent = rules;
});
