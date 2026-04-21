import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"
import { chainDialogs } from "swal_rails/chain"

// Fire a Swal modal/toast or a multi-step chain from markup.
//
// <button data-controller="swal"
//         data-action="click->swal#fire"
//         data-swal-options-value='{"title":"Hi","icon":"info"}'>
//   Ping
// </button>
//
// <button data-controller="swal"
//         data-action="click->swal#chain"
//         data-swal-steps-value='[{"title":"Sure?"},{"title":"Really?"}]'>
//   Ping
// </button>
export default class extends Controller {
  static values = {
    options: { type: Object, default: {} },
    steps: { type: Array, default: [] }
  }

  fire(event) {
    if (this.element.tagName === "A" || this.element.tagName === "BUTTON") {
      event?.preventDefault?.()
    }
    return Swal.fire(this.optionsValue)
  }

  confirm(event) {
    event?.preventDefault?.()
    const form = event?.target?.closest?.("form") || this.element
    Swal.fire({
      showCancelButton: true,
      focusCancel: true,
      ...this.optionsValue
    }).then((result) => {
      if (result.isConfirmed && form?.tagName === "FORM") {
        typeof form.requestSubmit === "function" ? form.requestSubmit() : form.submit()
      }
    })
  }

  async chain(event) {
    event?.preventDefault?.()
    const form = event?.target?.closest?.("form") || this.element
    const ok = await chainDialogs(window.Swal || Swal, this.stepsValue)
    if (ok && form?.tagName === "FORM") {
      typeof form.requestSubmit === "function" ? form.requestSubmit() : form.submit()
    }
    return ok
  }
}
