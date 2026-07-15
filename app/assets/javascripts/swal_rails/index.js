import Swal from "sweetalert2"
import { installConfirm } from "swal_rails/confirm"
import { installFlash } from "swal_rails/flash"
import { installStreamAction } from "swal_rails/stream"

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
    installStreamAction(Mixin)
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

// Pendant du boot côté « sortie » de page. Turbo met la page en cache au
// moment de la navigation : une popup encore dans le DOM à cet instant —
// typiquement une popup dont l'animation de fermeture a été coupée par un
// Turbo.visit lancé depuis son propre .then() — est capturée dans le
// snapshot et rejoue son animation au retour arrière.
const cleanupBeforeCache = () => {
  // Capturés avant la fermeture : sur Safari/iOS, SA2 vide le conteneur et
  // lui retire sa classe au lieu de le supprimer, le sélecteur ne le
  // retrouverait plus après coup.
  const containers = [...document.querySelectorAll(".swal2-container")]

  // Une popup encore ouverte : on demande sa fermeture, puis on force la fin
  // de l'animation que SA2 attend — l'animationend n'arrivera jamais sur une
  // page que Turbo s'apprête à jeter. SA2 exécute alors lui-même son
  // teardown : classes, padding du scrollbar et keydown handler sont
  // restaurés proprement.
  Swal.close()
  document.querySelectorAll(".swal2-popup").forEach((popup) => {
    popup.dispatchEvent(new AnimationEvent("animationend"))
  })

  // Ce qui reste debout part sans cérémonie : la page est démontée de toute
  // façon. Les toasts flash sont éphémères par page (réémis via installFlash
  // sur turbo:load), on ne fait que les retirer du snapshot.
  containers.forEach((el) => el.remove())
  document.getElementById("swal-rails-stack")?.remove()
  ;[document.documentElement, document.body].forEach((el) =>
    el.classList.remove(
      "swal2-shown",
      "swal2-height-auto",
      "swal2-toast-shown",
      "swal2-no-backdrop",
      "swal2-iosfix"
    )
  )
}

document.addEventListener("turbo:before-cache", cleanupBeforeCache)

export { Swal }
export default Swal
