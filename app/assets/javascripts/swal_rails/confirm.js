const parseJSON = (value) => {
  if (!value) return {}
  try { return JSON.parse(value) || {} } catch { return {} }
}

// When Rails serializes `data: { turbo_confirm: { icon: "error" } }`, the
// attribute value is a JSON string. Detect that and treat the parsed object
// as SA2 options rather than as a raw message.
const messageOptions = (message) => {
  if (typeof message !== "string" || message[0] !== "{") return null
  try {
    const parsed = JSON.parse(message)
    return parsed && typeof parsed === "object" ? parsed : null
  } catch { return null }
}

const confirmDialog = (Swal, message, element) => {
  const dataset = element?.dataset || {}
  const fromMessage = messageOptions(message)
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
  const extras = parseJSON(dataset.swalOptions)
  return Swal.fire({ ...options, ...(fromMessage || {}), ...extras }).then((result) => result.isConfirmed)
}

const installTurboOverride = (Swal) => {
  if (typeof window.Turbo === "undefined" || !window.Turbo.setConfirmMethod) return false

  window.Turbo.setConfirmMethod((message, element) => confirmDialog(Swal, message, element))
  return true
}

const installDataAttribute = (Swal) => {
  const handler = (event) => {
    const el = event.target.closest("[data-swal-confirm]")
    if (!el) return
    const message = el.getAttribute("data-swal-confirm")
    event.preventDefault()
    event.stopPropagation()
    confirmDialog(Swal, message, el).then((confirmed) => {
      if (!confirmed) return
      el.removeAttribute("data-swal-confirm")
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
