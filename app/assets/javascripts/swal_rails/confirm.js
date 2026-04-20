const confirmDialog = (Swal, message, element) => {
  const dataset = element?.dataset || {}
  const options = {
    title: dataset.swalTitle || message || "Are you sure?",
    text: dataset.swalText || (dataset.swalTitle ? message : undefined),
    icon: dataset.swalIcon || "warning",
    showCancelButton: true,
    focusCancel: true
  }
  if (dataset.swalConfirmText) options.confirmButtonText = dataset.swalConfirmText
  if (dataset.swalCancelText) options.cancelButtonText = dataset.swalCancelText
  return Swal.fire(options).then((result) => result.isConfirmed)
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
        el.submit()
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
