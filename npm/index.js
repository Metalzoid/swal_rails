import Swal from "sweetalert2"
import { installConfirm } from "swal_rails/confirm"
import { installFlash } from "swal_rails/flash"

const readMeta = (name) => {
  const el = document.querySelector(`meta[name="${name}"]`)
  if (!el) return null
  try { return JSON.parse(el.getAttribute("content")) } catch { return null }
}

const prefersReducedMotion = () =>
  window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches

const buildMixin = (config) => {
  const base = { ...(config.defaultOptions || {}) }
  if (config.respectReducedMotion && prefersReducedMotion()) {
    base.showClass = { popup: "" }
    base.hideClass = { popup: "" }
  }
  if (config.i18n?.confirm_button_text) base.confirmButtonText = config.i18n.confirm_button_text
  if (config.i18n?.cancel_button_text) base.cancelButtonText = config.i18n.cancel_button_text
  if (config.i18n?.deny_button_text) base.denyButtonText = config.i18n.deny_button_text
  if (config.i18n?.close_button_aria_label) base.closeButtonAriaLabel = config.i18n.close_button_aria_label
  return base
}

// Module-scoped so repeated calls to boot() (DOMContentLoaded + every
// turbo:load) don't stack a new click/submit listener per navigation.
let booted = null

const boot = () => {
  if (!booted) {
    const config = readMeta("swal-config") || {}
    const Mixin = Swal.mixin(buildMixin(config))

    if (config.exposeWindowSwal !== false) {
      window.Swal = Mixin
    }

    installConfirm(Mixin, config)
    booted = { Swal: Mixin, config }
    document.dispatchEvent(new CustomEvent("swal-rails:ready", { detail: booted }))
  }

  // Flash meta is re-rendered per request, so read and fire on every page.
  installFlash(booted.Swal, booted.config)
  return booted.Swal
}

const ready = (fn) => {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", fn, { once: true })
  } else {
    fn()
  }
}

ready(boot)
// `turbo:load` covers full Turbo Drive navigations + initial page loads.
// `turbo:render` additionally covers form submissions that render with
// a non-redirect status (e.g. 422 unprocessable_entity for `flash.now`)
// — Turbo replaces the body but does NOT fire turbo:load in that path.
// The `data-swal-consumed` guard on the meta tag dedupes the double-fire
// on full navigations where both events run.
document.addEventListener("turbo:load", boot)
document.addEventListener("turbo:render", boot)

export { Swal }
export default Swal
