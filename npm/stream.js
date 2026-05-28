export function installStreamAction(Swal) {
  if (typeof Turbo === "undefined" || !Turbo.StreamActions) return
  Turbo.StreamActions.swal = function () {
    const json = this.templateContent.textContent.trim()
    if (!json) return
    try { Swal.fire(JSON.parse(json)) }
    catch (e) { console.debug("swal_rails stream action: payload invalide", e) }
  }
}
