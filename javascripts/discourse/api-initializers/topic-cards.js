import { apiInitializer } from "discourse/lib/api";
import { applyVcTopicCards } from "../lib/vc-topic-cards";

// Topic list cards (VC Canvas 2.1.0). Logic and notes in lib/vc-topic-cards.js.
export default apiInitializer((api) => {
  applyVcTopicCards(api, settings);
});
