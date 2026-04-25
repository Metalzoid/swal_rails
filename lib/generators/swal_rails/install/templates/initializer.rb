# frozen_string_literal: true

SwalRails.configure do |config|
  # How confirmation modals are wired.
  #   :off             — do nothing, use Swal manually
  #   :data_attribute  — intercept clicks/submits on [data-swal-confirm] (default, non-intrusive)
  #   :turbo_override  — replace Turbo.setConfirmMethod globally
  #   :both            — both mechanisms at once
  config.confirm_mode = :<%= options[:confirm_mode] %>

  # Whether to expose `window.Swal` globally (useful for console / inline scripts).
  config.expose_window_swal = true

  # Whether to honor the user's OS prefers-reduced-motion setting.
  config.respect_reduced_motion = true

  # Default options merged into every Swal.fire call.
  # Note: `focusConfirm` / `returnFocus` are intentionally omitted — SA2
  # already defaults both to `true`, and listing them explicitly makes SA2
  # warn on every toast ("incompatible with toasts").
  config.default_options = {
    buttonsStyling: true,
    reverseButtons: false
  }

  # Map Rails flash keys to SweetAlert2 options.
  # Set a key to nil to silence it. Customize icon/toast/position/timer per key.
  config.flash_map[:notice]  = { icon: "success", toast: true, position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false }
  config.flash_map[:success] = { icon: "success", toast: true, position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false }
  config.flash_map[:alert]   = { icon: "error",   toast: true, position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false }
  config.flash_map[:error]   = { icon: "error",   toast: true, position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false }
  config.flash_map[:warning] = { icon: "warning", toast: true, position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false }
  config.flash_map[:info]    = { icon: "info",    toast: true, position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false }

  # How multiple flash entries are played when more than one is set in a
  # single request (or a flash key carries an array of messages).
  #   :sequential — one after the other, each waits for the previous to close (default)
  #   :stacked    — fire all in parallel, stacked vertically in a top-right container,
  #                 with `flash_stack_delay` ms between each appearance
  # Override per-request with `swal_flash :alert, msgs, mode: :stacked, delay: 300`.
  config.flash_array_mode  = :sequential
  config.flash_stack_delay = 500
end
