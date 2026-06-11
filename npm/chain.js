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

// JSON-delivered steps cannot ship functions (e.g. inputValidator).
// `inputExpected` provides a declarative guard for typed confirmations.
const normalizeStep = (step) => {
  const {
    onConfirmed,
    onDenied,
    inputExpected,
    inputExpectedError,
    ...sa2Options
  } = step || {}

  if (typeof inputExpected === "string") {
    const expected = inputExpected
    const error = inputExpectedError || `Type "${expected}" to continue`
    sa2Options.inputValidator = (value) => (
      (value || "").trim() === expected ? undefined : error
    )
  }

  return { onConfirmed, onDenied, sa2Options }
}

const runChain = async (Swal, steps) => {
  if (!Array.isArray(steps) || steps.length === 0) return true

  for (const step of steps) {
    // Strip our own control keys — SA2 ignores unknown options, but leaking
    // `onConfirmed`/`onDenied` into the popup options keeps the serialized
    // payload noisy and invites confusion.
    const { onConfirmed, onDenied, sa2Options } = normalizeStep(step)
    const result = await Swal.fire({ ...CHAIN_DEFAULTS, ...sa2Options })

    if (result.isDismissed) return false
    if (result.isConfirmed) {
      if (Array.isArray(onConfirmed)) return runChain(Swal, onConfirmed)
      continue
    }
    if (result.isDenied) {
      if (Array.isArray(onDenied)) return runChain(Swal, onDenied)
      return false
    }
  }
  return true
}

// Runs `steps`. With `muteKey`/`store`, the first step gets a "don't show
// this again" checkbox; if the chain runs to completion (resolves `true`)
// and the checkbox was checked, the whole chain is suppressed for next time.
export const chainDialogs = async (Swal, steps, { muteKey, store } = {}) => {
  if (!Array.isArray(steps) || steps.length === 0) return true
  if (!muteKey || !store) return runChain(Swal, steps)

  const [first, ...rest] = steps
  const { onConfirmed, onDenied, ...sa2Options } = first || {}
  const { options, getChecked } = store.attachCheckbox(sa2Options, muteKey)

  const result = await runChain(Swal, [{ ...options, onConfirmed, onDenied }, ...rest])
  if (result && getChecked()) store.suppress(muteKey)
  return result
}
