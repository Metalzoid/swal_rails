# frozen_string_literal: true

module SwalRails
  # Holds runtime configuration for the gem.
  #
  # A default is created on first access; override via an initializer:
  #
  #   SwalRails.configure do |config|
  #     config.confirm_mode = :turbo_override
  #     config.flash_map[:notice] = { icon: "success", toast: true }
  #   end
  class Configuration
    CONFIRM_MODES = %i[off data_attribute turbo_override both].freeze
    FLASH_ARRAY_MODES = %i[sequential stacked].freeze

    attr_accessor :default_options,
                  :flash_keys_as_meta,
                  :respect_reduced_motion,
                  :expose_window_swal,
                  :flash_stack_delay,
                  :initializer_version,
                  :silence_initializer_warning
    attr_reader :confirm_mode, :flash_map, :i18n_scope, :flash_array_mode

    def initialize
      @confirm_mode = :data_attribute
      @flash_keys_as_meta = true
      @respect_reduced_motion = true
      @expose_window_swal = true
      @flash_array_mode = :sequential
      @flash_stack_delay = 500
      @i18n_scope = "swal_rails"
      # `initializer_version` left nil — apps that haven't regenerated
      # their initializer since `SwalRails::INITIALIZER_VERSION` was
      # introduced (0.3.3) get a one-line warning at boot. Setting it
      # explicitly in the initializer template silences it.
      @initializer_version = nil
      @silence_initializer_warning = false
      # `focusConfirm` / `returnFocus` are intentionally omitted: SA2 already
      # defaults both to `true` internally, and passing them explicitly makes
      # SA2 warn on every toast ("incompatible with toasts"). Listing them
      # here would be a no-op behaviorally and a noise generator.
      @default_options = {
        buttonsStyling: true,
        reverseButtons: false
      }
      @flash_map = default_flash_map
    end

    def confirm_mode=(value)
      value = value.to_sym
      raise ArgumentError, "confirm_mode must be one of #{CONFIRM_MODES.inspect}, got #{value.inspect}" unless CONFIRM_MODES.include?(value)

      @confirm_mode = value
    end

    def flash_array_mode=(value)
      value = value.to_sym
      unless FLASH_ARRAY_MODES.include?(value)
        raise ArgumentError, "flash_array_mode must be one of #{FLASH_ARRAY_MODES.inspect}, got #{value.inspect}"
      end

      @flash_array_mode = value
    end

    def i18n_scope=(value)
      @i18n_scope = value.to_s
    end

    # Replace the full flash map. Prefer editing individual keys via `flash_map[:key] = ...`.
    def flash_map=(value)
      raise ArgumentError, "flash_map must be a Hash" unless value.is_a?(Hash)

      @flash_map = value.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
    end

    # Snapshot safe for serialization into a meta tag / JSON.
    def to_client_payload
      {
        confirmMode: confirm_mode,
        respectReducedMotion: respect_reduced_motion,
        exposeWindowSwal: expose_window_swal,
        defaultOptions: default_options,
        flashMap: flash_map,
        flashArrayMode: flash_array_mode,
        flashStackDelay: flash_stack_delay,
        i18n: i18n_payload
      }
    end

    private

    def default_flash_map
      {
        notice: { icon: "success", toast: true, position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false },
        success: { icon: "success", toast: true, position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false },
        alert: { icon: "error",   toast: true, position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false },
        error: { icon: "error",   toast: true, position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false },
        warning: { icon: "warning", toast: true, position: "top-end", timer: 4000, timerProgressBar: true, showConfirmButton: false },
        info: { icon: "info", toast: true, position: "top-end", timer: 3000, timerProgressBar: true, showConfirmButton: false }
      }
    end

    def i18n_payload
      return {} unless defined?(I18n)

      %i[confirm_button_text cancel_button_text deny_button_text close_button_aria_label].each_with_object({}) do |key, h|
        translation = I18n.t("#{i18n_scope}.#{key}", default: nil)
        h[key] = translation if translation
      end
    end
  end
end
