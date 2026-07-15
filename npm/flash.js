import { injectMuteCheckbox, store as defaultStore } from "swal_rails/preferences";

// Read the meta tag exactly once per page load. Boot() fires on both
// DOMContentLoaded and turbo:load, so without this guard an array flash
// would have its fireNext chain launched twice, racing and cascading via
// Swal.fire's replace-current-popup behavior — only the last message wins.
const readFlash = () => {
  const el = document.querySelector('meta[name="swal-flash"]');
  if (!el || el.dataset.swalConsumed === "1") return [];
  el.dataset.swalConsumed = "1";
  try {
    return JSON.parse(el.getAttribute("content")) || [];
  } catch {
    return [];
  }
};

// Keys attached by `swal_flash` helper for per-request mode / delay override.
// Stripped from the options before being passed to Swal.fire so they never
// leak into SA2.
const META_KEYS = ["_arrayMode", "_stackDelay"];

const extractMeta = (queue) => {
  let mode = null;
  let delay = null;
  for (const item of queue) {
    if (mode === null && item._arrayMode) mode = item._arrayMode;
    if (delay === null && item._stackDelay != null) delay = item._stackDelay;
    for (const k of META_KEYS) delete item[k];
  }
  return { mode, delay };
};

// Per-item "don't show this again" key. Unlike _arrayMode/_stackDelay this
// isn't a shared meta — every entry carries its own (or none).
const extractMuteKey = (item) => {
  const key = item._muteKey;
  delete item._muteKey;
  return key || null;
};

// Per-item: _persistent removes the auto-close timer and ensures the user
// must dismiss manually via the close button.
const applyPersistent = (queue) => {
  for (const item of queue) {
    if (!item._persistent) continue;
    delete item._persistent;
    delete item.timer;
    delete item.timerProgressBar;
    item.showCloseButton = true;
  }
};

const STACK_ID = "swal-rails-stack";

const ensureStackContainer = () => {
  let el = document.getElementById(STACK_ID);
  if (!el) {
    el = document.createElement("div");
    el.id = STACK_ID;
    // 360px matches SA2's `body.swal2-toast-shown .swal2-container` width;
    // without it the cloned popups inherit `width: 100%` from SA2 and
    // visually span the whole screen.
    el.style.cssText = [
      "position:fixed",
      "top:1rem",
      "right:1rem",
      "width:360px",
      "max-width:calc(100vw - 2rem)",
      "display:flex",
      "flex-direction:column",
      "gap:.5rem",
      "z-index:10000",
      "pointer-events:none",
    ].join(";");
    document.body.appendChild(el);
  }
  return el;
};

const fireSequential = (Swal, queue, keys, store) => {
  const fireNext = () => {
    const opts = queue.shift();
    const key = keys.shift();
    if (!opts) return;

    let fireOptions = opts;
    let getChecked = () => false;
    if (key && store) {
      ({ options: fireOptions, getChecked } = store.attachCheckbox(opts, key));
    }

    Swal.fire(fireOptions).then(() => {
      if (key && store && getChecked()) store.suppress(key);
      fireNext();
    });
  };
  fireNext();
};

// SA2 is singleton — two concurrent Swal.fire calls collapse into one
// popup (the second replaces the first). To stack multiple toasts we let
// SA2 render each popup, clone it into its own slot, then close the
// original fast so the next fire is unblocked. The clones live on in our
// stack with their own timer and click-to-dismiss handlers. Empiler des
// modales bloquantes n'a pas de sens — on force toast: true.
const fireStacked = async (Swal, queue, keys, delay, store) => {
  const stack = ensureStackContainer();
  for (let i = 0; i < queue.length; i++) {
    const opts = queue[i];
    const key = keys[i];
    const slot = document.createElement("div");
    slot.className = "swal-rails-stack-slot";
    slot.style.cssText = "width:100%;pointer-events:auto;";
    stack.appendChild(slot);

    const timerMs = opts.timer;
    await new Promise((resolve) => {
      Swal.fire({
        ...opts,
        toast: true,
        timerProgressBar: false,
        showClass: { popup: "", backdrop: "", icon: "" },
        hideClass: { popup: "", backdrop: "", icon: "" },
        // timer:1 races with the setTimeout(0) SA2 uses to schedule didOpen
        // when animations are disabled — didOpen can lose that race and never
        // fire, leaving the slot empty. 50 ms gives the event loop a safe
        // margin while remaining imperceptible to the user.
        timer: 50,
        // Suppress the SA2 original so only our clone in the stack is visible.
        willOpen: (popup) => {
          popup.style.opacity = "0";
          popup.style.pointerEvents = "none";
        },
        // Clone at didOpen: SA2 has applied all inline styles at this point
        // (display:grid, icon classes, close-button grid placement, etc.),
        // so the clone requires no manual fixups.
        didOpen: (popup) => {
          if (key && store) injectMuteCheckbox(popup, store.label);

          const clone = popup.cloneNode(true);
          // willOpen set opacity:0 on the original; clear it on the clone.
          clone.style.opacity = "";
          clone
            .querySelectorAll(".swal2-timer-progress-bar-container")
            .forEach((e) => e.remove());
          slot.appendChild(clone);

          // cloneNode(true) copies DOM but not listeners. Grab the clone's
          // checkbox (the one the user sees/clicks) and read its FINAL state
          // at dismiss time — matching the getChecked()-after-resolve
          // semantics of every other path, so a check-then-uncheck before the
          // toast closes does NOT permanently mute.
          const muteCheckbox =
            key && store
              ? clone.querySelector(".swal-rails-mute input[type=checkbox]")
              : null;

          const dismiss = () => {
            if (muteCheckbox?.checked) store.suppress(key);
            if (slot.isConnected) slot.remove();
            if (stack.isConnected && stack.children.length === 0)
              stack.remove();
          };
          clone.querySelector(".swal2-close")?.addEventListener("click", dismiss);
          if (timerMs) setTimeout(dismiss, timerMs);
        },
        didClose: () => resolve(),
      });
    });

    if (i < queue.length - 1 && delay > 0) {
      await new Promise((r) => setTimeout(r, delay));
    }
  }
};

export const installFlash = (Swal, config, store = defaultStore) => {
  // Refresh the suppression store on every boot (each turbo:load/render),
  // BEFORE the early-return below — a page with no flash can still hold
  // confirm buttons whose mute state must be current. Defaulting `store` to
  // the singleton means custom boot sequences calling installFlash(Swal,
  // config) still get fully-wired suppression without threading the store.
  store.refresh(config);

  const flashes = readFlash();
  if (!flashes.length) return;

  const map = config.flashMap || {};
  let queue = flashes.map((flash) => {
    const spec = map[flash.key] ||
      map[flash.key.toLowerCase()] || {
        icon: "info",
        toast: true,
        position: "top-end",
        timer: 3000,
      };
    // Per-request options win over the per-key defaults from flash_map.
    return { ...spec, ...(flash.options || {}) };
  });

  let keys = queue.map(extractMuteKey);

  // Owners are already filtered server-side (build_flash_payload); for
  // guests, drop entries suppressed via localStorage here.
  const kept = queue
    .map((opts, i) => ({ opts, key: keys[i] }))
    .filter(({ key }) => !(key && store?.isSuppressed(key)));
  if (!kept.length) return;
  queue = kept.map((entry) => entry.opts);
  keys = kept.map((entry) => entry.key);

  const meta = extractMeta(queue);
  applyPersistent(queue);
  const mode = meta.mode || config.flashArrayMode || "sequential";
  const delay =
    meta.delay != null
      ? meta.delay
      : config.flashStackDelay != null
        ? config.flashStackDelay
        : 500;

  if (mode === "stacked" && queue.length > 1) {
    fireStacked(Swal, queue, keys, delay, store);
  } else {
    fireSequential(Swal, queue, keys, store);
  }
};
