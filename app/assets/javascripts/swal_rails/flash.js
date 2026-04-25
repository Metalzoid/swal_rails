// Read the meta tag exactly once per page load. Boot() fires on both
// DOMContentLoaded and turbo:load, so without this guard an array flash
// would have its fireNext chain launched twice, racing and cascading via
// Swal.fire's replace-current-popup behavior — only the last message wins.
const readFlash = () => {
  const el = document.querySelector('meta[name="swal-flash"]')
  if (!el || el.dataset.swalConsumed === "1") return []
  el.dataset.swalConsumed = "1"
  try { return JSON.parse(el.getAttribute("content")) || [] } catch { return [] }
}

// Keys attached by `swal_flash` helper for per-request mode / delay override.
// Stripped from the options before being passed to Swal.fire so they never
// leak into SA2.
const META_KEYS = ["_arrayMode", "_stackDelay"]

const extractMeta = (queue) => {
  let mode = null
  let delay = null
  for (const item of queue) {
    if (mode === null && item._arrayMode) mode = item._arrayMode
    if (delay === null && item._stackDelay != null) delay = item._stackDelay
    for (const k of META_KEYS) delete item[k]
  }
  return { mode, delay }
}

const STACK_ID = "swal-rails-stack"

const ensureStackContainer = () => {
  let el = document.getElementById(STACK_ID)
  if (!el) {
    el = document.createElement("div")
    el.id = STACK_ID
    el.style.cssText = [
      "position:fixed",
      "top:1rem",
      "right:1rem",
      "display:flex",
      "flex-direction:column",
      "gap:.5rem",
      "z-index:10000",
      "pointer-events:none"
    ].join(";")
    document.body.appendChild(el)
  }
  return el
}

const fireSequential = (Swal, queue) => {
  const fireNext = () => {
    const opts = queue.shift()
    if (!opts) return
    Swal.fire(opts).then(fireNext)
  }
  fireNext()
}

// SA2 is singleton — two concurrent Swal.fire calls collapse into one
// popup (the second replaces the first). To stack multiple toasts we let
// SA2 render each popup, clone it into its own slot, then close the
// original fast so the next fire is unblocked. The clones live on in our
// stack with their own timer and click-to-dismiss handlers. Empiler des
// modales bloquantes n'a pas de sens — on force toast: true.
const fireStacked = async (Swal, queue, delay) => {
  const stack = ensureStackContainer()
  for (let i = 0; i < queue.length; i++) {
    const opts = queue[i]
    const slot = document.createElement("div")
    slot.className = "swal-rails-stack-slot"
    slot.style.cssText = "pointer-events:auto;"
    stack.appendChild(slot)

    const timerMs = opts.timer
    await new Promise((resolve) => {
      Swal.fire({
        ...opts,
        toast: true,
        // Close the SA2 original immediately; the clone in `slot` persists.
        // Animations disabled on the decoy so the clone captures the popup
        // in its normal "shown" state (no opacity-0 from close transition).
        timer: 1,
        timerProgressBar: false,
        showClass: { popup: "", backdrop: "", icon: "" },
        hideClass: { popup: "", backdrop: "", icon: "" },
        didRender: (popup) => {
          const clone = popup.cloneNode(true)
          clone.style.opacity = ""
          clone.querySelectorAll(".swal2-timer-progress-bar-container").forEach((e) => e.remove())
          // SA2 adds `.swal2-icon-show` only after didOpen, but we clone
          // earlier (in didRender) to beat the close animation. Apply it
          // manually so the icon's SVG is visibly drawn in the clone.
          clone.querySelectorAll(".swal2-icon").forEach((icon) => icon.classList.add("swal2-icon-show"))
          slot.appendChild(clone)
          const dismiss = () => {
            if (slot.isConnected) slot.remove()
            if (stack.isConnected && stack.children.length === 0) stack.remove()
          }
          clone.querySelector(".swal2-close")?.addEventListener("click", dismiss)
          if (timerMs) setTimeout(dismiss, timerMs)
        },
        didClose: () => resolve()
      })
    })

    if (i < queue.length - 1 && delay > 0) {
      await new Promise((r) => setTimeout(r, delay))
    }
  }
}

export const installFlash = (Swal, config) => {
  const flashes = readFlash()
  if (!flashes.length) return

  const map = config.flashMap || {}
  const queue = flashes.map((flash) => {
    const spec = map[flash.key] || map[flash.key.toLowerCase()] || { icon: "info", toast: true, position: "top-end", timer: 3000 }
    // Per-request options win over the per-key defaults from flash_map.
    return { ...spec, ...(flash.options || {}) }
  })

  const meta = extractMeta(queue)
  const mode = meta.mode || config.flashArrayMode || "sequential"
  const delay = meta.delay != null ? meta.delay
    : (config.flashStackDelay != null ? config.flashStackDelay : 500)

  if (mode === "stacked" && queue.length > 1) {
    fireStacked(Swal, queue, delay)
  } else {
    fireSequential(Swal, queue)
  }
}
