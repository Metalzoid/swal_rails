import { Controller } from "@hotwired/stimulus"
import Swal from "sweetalert2"

// Fire a Swal modal/toast from markup.
//
// <button data-controller="swal"
//         data-action="click->swal#fire"
//         data-swal-options-value='{"title":"Hi","icon":"info"}'>
//   Ping
// </button>
export default class extends Controller {
  static values = { options: { type: Object, default: {} } }

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
      if (result.isConfirmed && form?.tagName === "FORM") form.submit()
    })
  }
}
