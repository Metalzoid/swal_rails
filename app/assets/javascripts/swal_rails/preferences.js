// "Don't show this again" preference store.
//
// Reads `<meta name="swal-preferences">` (emitted per-request by
// `swal_rails_meta_tags` when `config.preferences_enabled`) on every boot —
// available before the first flash fires, so there's no async race. Owners
// (logged-in users) sync suppressions to the DB via the mounted engine API;
// guests fall back to localStorage. The checkbox itself is opt-in: it's only
// rendered for popups that carry a `muteKey`, regardless of whether
// preferences are enabled server-side (localStorage always works).
const STORAGE_KEY = "swal_rails:muted"

const readMeta = (name) => {
  const el = document.querySelector(`meta[name="${name}"]`)
  if (!el) return null
  try { return JSON.parse(el.getAttribute("content")) } catch { return null }
}

const readLocalKeys = () => {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY)
    const parsed = raw ? JSON.parse(raw) : []
    return Array.isArray(parsed) ? parsed : []
  } catch {
    return []
  }
}

const writeLocalKeys = (keys) => {
  try { window.localStorage.setItem(STORAGE_KEY, JSON.stringify(keys)) } catch { /* storage unavailable */ }
}

const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") || ""

// Inserts a "don't show this again" checkbox after the popup's actions row
// (or at the end of the popup if there are none) and returns the <input>.
export const injectMuteCheckbox = (popup, label) => {
  const wrapper = document.createElement("label")
  wrapper.className = "swal-rails-mute"
  wrapper.style.cssText = "display:flex;align-items:center;justify-content:center;gap:.5rem;margin-top:.75rem;font-size:.875rem;cursor:pointer;"

  const input = document.createElement("input")
  input.type = "checkbox"

  const span = document.createElement("span")
  span.textContent = label

  wrapper.append(input, span)

  const anchor = popup.querySelector(".swal2-actions") || popup.querySelector(".swal2-html-container")
  if (anchor) anchor.insertAdjacentElement("afterend", wrapper)
  else popup.appendChild(wrapper)

  return input
}

class PreferencesStore {
  constructor() {
    this.enabled = false
    this.owner = false
    this.path = null
    this.label = "Don't show this again"
    this.muted = new Set()
  }

  // Re-reads the per-request meta tag and merges localStorage. Called on
  // every boot() (DOMContentLoaded + each turbo:load) so the suppression
  // list is current before flashes/confirms fire.
  refresh(config) {
    this.label = config?.i18n?.mute_label || this.label

    const meta = readMeta("swal-preferences")
    this.enabled = !!meta?.enabled
    this.owner = !!meta?.owner
    this.path = meta?.path || null

    // A suppression is DB-backed only when we have BOTH a known owner and an
    // API path. Without the engine mounted (`path` absent), even a logged-in
    // owner's writes go to localStorage — so they must be read back from there
    // too, otherwise the mute is written somewhere reads never look.
    const keys = new Set(Array.isArray(meta?.keys) ? meta.keys : [])
    if (!this.owner || !this.path) {
      for (const key of readLocalKeys()) keys.add(key)
    }
    this.muted = keys
  }

  isSuppressed(key) {
    return !!key && this.muted.has(key)
  }

  // Marks `key` as muted for good: synced to the DB for known owners,
  // written to localStorage for guests. Idempotent.
  suppress(key) {
    if (!key || this.muted.has(key)) return
    this.muted.add(key)

    if (this.owner && this.path) {
      fetch(this.path, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken() },
        body: JSON.stringify({ key })
      }).catch(() => { /* best-effort; key stays suppressed for this session */ })
      return
    }

    const keys = readLocalKeys()
    if (!keys.includes(key)) {
      keys.push(key)
      writeLocalKeys(keys)
    }
  }

  // Wraps `options.didOpen` to inject the checkbox. Returns the (possibly)
  // new options plus a `getChecked()` closure to read after `Swal.fire`
  // resolves — for popups that stay open until the user acts (confirms,
  // sequential flash, chains).
  attachCheckbox(options, key) {
    if (!key) return { options, getChecked: () => false }

    const userDidOpen = options.didOpen
    let checked = false

    return {
      options: {
        ...options,
        didOpen: (popup) => {
          if (typeof userDidOpen === "function") userDidOpen(popup)
          const input = injectMuteCheckbox(popup, this.label)
          input.addEventListener("change", () => { checked = input.checked })
        }
      },
      getChecked: () => checked
    }
  }
}

export const store = new PreferencesStore()
