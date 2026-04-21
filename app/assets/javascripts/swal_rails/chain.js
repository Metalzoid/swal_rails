// Runs a sequence of SweetAlert2 modals, advancing only on confirm.
//
// Semantics (per step):
//   - isDismissed → abort the chain, return false
//   - isConfirmed → run onConfirmed sub-chain if present, else continue
//   - isDenied    → run onDenied sub-chain if present, else abort
//
// A chain resolves to `true` iff it ran to completion along a path without
// abort. That boolean is the contract expected by Turbo.setConfirmMethod
// and by the data-attribute re-dispatch logic in confirm.js.
export const CHAIN_DEFAULTS = {
  showCancelButton: true,
  focusCancel: true,
  icon: "warning"
}

export const chainDialogs = async (Swal, steps) => {
  if (!Array.isArray(steps) || steps.length === 0) return true

  for (const step of steps) {
    // Strip our own control keys — SA2 ignores unknown options, but leaking
    // `onConfirmed`/`onDenied` into the popup options keeps the serialized
    // payload noisy and invites confusion.
    const { onConfirmed, onDenied, ...sa2Options } = step || {}
    const result = await Swal.fire({ ...CHAIN_DEFAULTS, ...sa2Options })

    if (result.isDismissed) return false
    if (result.isConfirmed) {
      if (Array.isArray(onConfirmed)) return chainDialogs(Swal, onConfirmed)
      continue
    }
    if (result.isDenied) {
      if (Array.isArray(onDenied)) return chainDialogs(Swal, onDenied)
      return false
    }
  }
  return true
}
