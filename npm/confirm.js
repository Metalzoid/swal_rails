import { chainDialogs } from "swal_rails/chain"

const parseJSON = (value) => {
  if (!value) return null
  try { return JSON.parse(value) } catch { return null }
}

// When Rails serializes `data: { turbo_confirm: { icon: "error" } }`, the
// attribute value is a JSON string. Detect that, and accept both Object
// (single-step options) and Array (multi-step chain) shapes.
const messagePayload = (message) => {
  if (typeof message !== "string") return null
  const trimmed = message.trim()
  if (trimmed[0] !== "{" && trimmed[0] !== "[") return null
  const parsed = parseJSON(trimmed)
  if (Array.isArray(parsed)) return parsed
  if (parsed && typeof parsed === "object") return parsed
  return null
}

const confirmDialog = (Swal, message, element) => {
  const dataset = element?.dataset || {}
  const payload = messagePayload(message)
  const fromMessage = payload && !Array.isArray(payload) ? payload : null
  const text = fromMessage ? undefined : message

  const options = {
    title: dataset.swalTitle || text || "Are you sure?",
    text: dataset.swalText || (dataset.swalTitle ? text : undefined),
    icon: dataset.swalIcon || "warning",
    showCancelButton: true,
    focusCancel: true
  }
  if (dataset.swalConfirmText) options.confirmButtonText = dataset.swalConfirmText
  if (dataset.swalCancelText) options.cancelButtonText = dataset.swalCancelText

  // Merge order (later wins): defaults → data-swal-* shortcuts → JSON message
  // (turbo_confirm: {}) → data-swal-options (most specific).
  const extras = parseJSON(dataset.swalOptions) || {}
  return Swal.fire({ ...options, ...(fromMessage || {}), ...extras }).then((result) => result.isConfirmed)
}

// Dispatches to either a multi-step chain or a single-step confirm. Called
// from both the Turbo override and the data-attribute listener so both
// paths behave identically.
const confirmFlow = (Swal, message, element) => {
  const fromDataset = parseJSON(element?.dataset?.swalSteps)
  if (Array.isArray(fromDataset) && fromDataset.length) return chainDialogs(Swal, fromDataset)

  const payload = messagePayload(message)
  if (Array.isArray(payload) && payload.length) return chainDialogs(Swal, payload)

  return confirmDialog(Swal, message, element)
}

const installTurboOverride = (Swal) => {
  if (typeof window.Turbo === "undefined") return false
  const handler = (message, element) => confirmFlow(Swal, message, element)
  // Turbo 8.1+ renamed the API to `Turbo.config.forms.confirm`. The legacy
  // `setConfirmMethod` still works but emits a deprecation warning. Prefer
  // the new path, fall back to the old one for older Turbo versions.
  if (window.Turbo.config?.forms) {
    window.Turbo.config.forms.confirm = handler
    return true
  }
  if (typeof window.Turbo.setConfirmMethod === "function") {
    window.Turbo.setConfirmMethod(handler)
    return true
  }
  return false
}

const installDataAttribute = (Swal) => {
  const handler = (event) => {
    const el = event.target.closest("[data-swal-confirm], [data-swal-steps]")
    if (!el) return
    const message = el.getAttribute("data-swal-confirm")
    event.preventDefault()
    event.stopPropagation()
    confirmFlow(Swal, message, el).then((confirmed) => {
      if (!confirmed) return
      el.removeAttribute("data-swal-confirm")
      el.removeAttribute("data-swal-steps")
      if (typeof el.click === "function" && event.type === "click") {
        el.click()
      } else if (el.tagName === "FORM") {
        // requestSubmit() fires the 'submit' event, so Turbo and any UJS
        // handlers stay in the loop — unlike the raw .submit() which skips them.
        if (typeof el.requestSubmit === "function") el.requestSubmit()
        else el.submit()
      }
    })
  }
  document.addEventListener("click", handler, true)
  document.addEventListener("submit", handler, true)
}

export const installConfirm = (Swal, config) => {
  const mode = config.confirmMode || "data_attribute"
  if (mode === "off") return
  if (mode === "turbo_override" || mode === "both") installTurboOverride(Swal)
  if (mode === "data_attribute" || mode === "both") installDataAttribute(Swal)
}
