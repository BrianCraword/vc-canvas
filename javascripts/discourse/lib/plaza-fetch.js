import { ajax } from "discourse/lib/ajax";

// Shared, rate-limit-friendly fetch layer for all Plaza blocks.
//
// Problems it solves (observed on the live site, 2026-07-02):
// 1. The homepage fired ~17 JSON requests simultaneously on load;
//    Discourse's per-user rate limiter answered with 429s and five
//    blocks rendered a literal "429 error" alert to the user.
// 2. Identical requests were duplicated across blocks in one load
//    (latest.json ×3, top.json ×3, about.json ×3, directory_items ×4,
//    steering/profile.json ×2).
// 3. Failed responses (429/403 HTML pages) surfaced as raw error text
//    in the UI and as JSON.parse exceptions in the console.
//
// Design:
// - In-flight dedupe + short TTL cache per request key. Two blocks that
//   want /about.json share one request and one response.
// - A small queue caps concurrency so a cold homepage load stays under
//   the rate limiter instead of bursting everything at once.
// - One automatic retry after a backoff when the server answers 429.
// - Never throws. Resolves `null` on failure; callers treat null as
//   "no data" and render their empty state. Errors never reach the UI.
//
// Successful responses are cached for TTL_MS (covers SPA back/forward
// to the homepage without refetch storms). Failures are NOT cached, so
// the next visit retries cleanly.

const TTL_MS = 60_000;
const MAX_CONCURRENT = 4;
const RETRY_DELAY_MS = 2_000;

const cache = new Map(); // key -> { at, promise }
let active = 0;
const waiting = [];

function pump() {
  while (active < MAX_CONCURRENT && waiting.length) {
    waiting.shift()();
  }
}

function schedule(task) {
  return new Promise((resolve) => {
    const run = () => {
      active++;
      task().then((result) => {
        active--;
        resolve(result);
        pump();
      });
    };
    if (active < MAX_CONCURRENT) {
      run();
    } else {
      waiting.push(run);
    }
  });
}

function is429(e) {
  return e?.jqXHR?.status === 429 || e?.status === 429;
}

async function attempt(fetcher) {
  try {
    return await fetcher();
  } catch (e) {
    if (is429(e)) {
      await new Promise((r) => setTimeout(r, RETRY_DELAY_MS));
      try {
        return await fetcher();
      } catch {
        return null;
      }
    }
    return null;
  }
}

function memoized(key, fetcher) {
  const hit = cache.get(key);
  if (hit && Date.now() - hit.at < TTL_MS) {
    return hit.promise;
  }
  const promise = schedule(() => attempt(fetcher)).then((value) => {
    if (value === null) {
      // Don't pin failures — allow the next visit to retry.
      cache.delete(key);
    }
    return value;
  });
  cache.set(key, { at: Date.now(), promise });
  return promise;
}

/**
 * GET a JSON endpoint through the shared queue/cache.
 * Resolves the parsed body, or `null` on any failure.
 */
export function plazaGet(url, data) {
  const key = data ? `${url}::${JSON.stringify(data)}` : url;
  // Discourse 2026.7's ajax() reads properties off the second argument
  // whenever one is passed — even an explicit `undefined` — so it must be
  // omitted entirely when there's no data. Passing `undefined` throws
  // synchronously ("reading 'ignoreUnsent'"), which attempt() swallowed,
  // silently nulling every data-less plazaGet call.
  return memoized(key, () => (data ? ajax(url, { data }) : ajax(url)));
}

/**
 * Fetch a topic list via the store with the same dedupe/queue/cache.
 * Resolves the topicList, or `null` on any failure.
 */
export function plazaTopicList(store, filter) {
  return memoized(`topicList:${filter}`, () =>
    store.findFiltered("topicList", { filter })
  );
}
