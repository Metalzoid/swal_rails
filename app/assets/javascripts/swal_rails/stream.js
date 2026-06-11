import { store as defaultStore } from "swal_rails/preferences"

export function installStreamAction(Swal, store = defaultStore) {
  if (typeof Turbo === "undefined" || !Turbo.StreamActions) return
  Turbo.StreamActions.swal = function () {
    const json = this.templateContent.textContent.trim()
    if (!json) return
    try {
      const options = JSON.parse(json)
      const muteKey = options._muteKey

      // Strip every reserved meta-key before it reaches Swal.fire (SA2 warns
      // on unknown options). `_arrayMode` / `_stackDelay` are queue-only
      // concepts and meaningless for a single stream popup; `_persistent`
      // does apply — honor it the same way flash.js does.
      delete options._muteKey
      delete options._arrayMode
      delete options._stackDelay
      if (options._persistent) {
        delete options._persistent
        delete options.timer
        delete options.timerProgressBar
        options.showCloseButton = true
      }

      if (muteKey && store?.isSuppressed(muteKey)) return

      let fireOptions = options
      let getChecked = () => false
      if (muteKey && store) {
        ({ options: fireOptions, getChecked } = store.attachCheckbox(options, muteKey))
      }

      Swal.fire(fireOptions).then(() => {
        if (muteKey && store && getChecked()) store.suppress(muteKey)
      })
    } catch (e) { console.debug("swal_rails stream action: payload invalide", e) }
  }
}
