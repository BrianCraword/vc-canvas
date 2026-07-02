import { apiInitializer } from "discourse/lib/api";
import BlockPlazaHero from "../blocks/block-plaza-hero";
import BlockPlazaTicker from "../blocks/block-plaza-ticker";

export default apiInitializer((api) => {
  api.renderBlocks("main-outlet-blocks", [
    {
      block: BlockPlazaTicker,
      id: "plaza-ticker",
      args: { count: settings.ticker_topic_count },
      conditions: { type: "route", pages: ["HOMEPAGE"] },
    },
    {
      block: BlockPlazaHero,
      id: "plaza-hero",
      conditions: { type: "route", pages: ["HOMEPAGE"] },
    },
  ]);
});
