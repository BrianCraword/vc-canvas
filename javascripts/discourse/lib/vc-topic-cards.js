// ═══════════════════════════════════════════════════════════════════════
// Topic list cards (VC Canvas 2.1.0)
//
// Driven by the theme settings `topic_list_layout` and
// `topic_card_excerpt_lines`. Uses only core value/behaviour transformers,
// so Discourse still renders every cell itself; the card look is CSS
// (stylesheets/pages/topic-list.scss).
//
// Pattern adapted from Discourse's Horizon theme (MIT, Discourse Design
// Team): themes/horizon/javascripts/discourse/initializers/topic-list-columns.gjs
// ═══════════════════════════════════════════════════════════════════════

// Lists that become cards: Latest, New, Unread, Top, Hot, category and tag
// lists, and (with `messages_layout` cards, 2.10.0) the private message
// folders, whose list context is "messages". Suggested/related topics keep
// the table.
const CARD_CONTEXTS = ["discovery"];

export function cardContexts(themeSettings) {
  return themeSettings?.messages_layout === "cards"
    ? [...CARD_CONTEXTS, "messages"]
    : CARD_CONTEXTS;
}

export function isCardContext(context, contexts = CARD_CONTEXTS) {
  return (
    contexts.includes(context?.listContext) &&
    !context?.category?.doc_index_topic_id
  );
}

const ENTITIES = { "&amp;": "&", "&lt;": "<", "&gt;": ">", "&quot;": '"', "&#39;": "'" };

function normalize(text) {
  return String(text || "")
    .replace(/&(amp|lt|gt|quot|#39);/g, (m) => ENTITIES[m])
    .replace(/\s+/g, " ")
    .trim()
    .toLowerCase();
}

// True when the excerpt would only repeat the title. Feed posts and quick
// posts get a title cut from the start of the post ("He knew Lazarus would
// live again. He knew the…"), so their excerpt starts with the same words.
export function excerptRepeatsTitle(topic) {
  const excerpt = normalize(topic?.excerpt);
  const title = normalize(topic?.title);
  if (!excerpt || !title) {
    return false;
  }
  const cut = /…/.test(title.slice(-6));
  const stem = title.replace(/[\s·….]+$/u, "");
  return (
    excerpt === title ||
    excerpt === stem ||
    title.startsWith(excerpt) ||
    (cut && stem.length >= 8 && excerpt.startsWith(stem))
  );
}

export function applyVcTopicCards(api, themeSettings) {
  if (themeSettings.topic_list_layout !== "cards") {
    return;
  }

  const excerptLines = parseInt(themeSettings.topic_card_excerpt_lines, 10) || 0;
  const contexts = cardContexts(themeSettings);

  api.registerValueTransformer("topic-list-class", ({ value, context }) =>
    isCardContext(context, contexts) ? [...value, "vc-topic-cards"] : value
  );

  api.registerValueTransformer("topic-list-item-class", ({ value, context }) => {
    if (!isCardContext(context, contexts)) {
      return value;
    }
    const classes = [...value, "vc-card"];
    if (!(context.topic?.replyCount > 0)) {
      classes.push("vc-card--no-replies");
    }
    return classes;
  });

  // Phones get the same cells as desktop, laid out by CSS.
  api.registerValueTransformer("topic-list-item-mobile-layout", ({ value, context }) =>
    isCardContext(context, contexts) ? false : value
  );

  // Show an excerpt on every card (core only does it for pinned topics),
  // unless it would just repeat the title. 0 lines keeps core's behaviour.
  api.registerValueTransformer("topic-list-item-expand-pinned", ({ value, context }) => {
    if (!isCardContext(context, contexts) || excerptLines < 1) {
      return value;
    }
    return !excerptRepeatsTitle(context.topic);
  });

  // The whole card opens the topic, as the title link would.
  api.registerBehaviorTransformer("topic-list-item-click", ({ context, next }) => {
    const { event, topic, listContext } = context;
    if (!isCardContext({ listContext, category: topic?.category }, contexts)) {
      return next();
    }

    const target = event.target;
    if (
      (target.closest("a, button, input, label, select, textarea") &&
        !target.closest(".topic-excerpt")) ||
      target.closest(".topic-excerpt-more")
    ) {
      return next();
    }

    const row = target.closest("tr");
    const link = row?.querySelector("a.raw-topic-link");
    if (!link) {
      return next();
    }

    // Selecting text in a card shouldn't open the topic.
    const selection = window.getSelection?.();
    if (selection && !selection.isCollapsed && row.contains(selection.anchorNode)) {
      return;
    }

    event.preventDefault();
    event.stopPropagation();

    if (event.button === 1) {
      window.open(link.href, "_blank", "noopener,noreferrer");
      return;
    }

    link.dispatchEvent(
      new MouseEvent("click", {
        ctrlKey: event.ctrlKey,
        metaKey: event.metaKey,
        shiftKey: event.shiftKey,
        button: event.button,
        bubbles: true,
        cancelable: true,
      })
    );
  });
}
