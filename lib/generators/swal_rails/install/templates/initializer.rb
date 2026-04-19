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
  config.default_options = {
    buttonsStyling: true,
    reverseButtons: false,
    focusConfirm: true,
    returnFocus: true
  }

  # Map Rails flash keys to SweetAlert2 options.
  # Set a key to nil to silence it. Customize icon/toast/position/timer per key.
  config.flash_map[:notice]  = { icon: "success", toast: true,  position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false }
  config.flash_map[:success] = { icon: "success", toast: true,  position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false }
  config.flash_map[:alert]   = { icon: "error",   toast: false }
  config.flash_map[:error]   = { icon: "error",   toast: false }
  config.flash_map[:warning] = { icon: "warning", toast: true,  position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false }
  config.flash_map[:info]    = { icon: "info",    toast: true,  position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false }
end
