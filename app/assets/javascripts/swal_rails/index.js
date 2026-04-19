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

const boot = () => {
  const config = readMeta("swal-config") || {}
  const Mixin = Swal.mixin(buildMixin(config))

  if (config.exposeWindowSwal !== false) {
    window.Swal = Mixin
  }

  installConfirm(Mixin, config)
  installFlash(Mixin, config)

  document.dispatchEvent(new CustomEvent("swal-rails:ready", { detail: { Swal: Mixin, config } }))
  return Mixin
}

const ready = (fn) => {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", fn, { once: true })
  } else {
    fn()
  }
}

ready(boot)
document.addEventListener("turbo:load", boot)

export { Swal }
export default Swal
