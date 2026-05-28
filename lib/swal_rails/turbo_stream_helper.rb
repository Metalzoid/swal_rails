# frozen_string_literal: true

module SwalRails
  # Extends Turbo::Streams::TagBuilder with swal-specific stream actions.
  # Prepended at boot (engine initializer) only when turbo-rails is loaded.
  #
  # Usage in a controller:
  #   render turbo_stream: [
  #     turbo_stream.update("modal-container", ""),
  #     turbo_stream.swal_flash(:notice, "Élément créé avec succès"),
  #     # or freeform SA2 options:
  #     # turbo_stream.swal(icon: "error", title: "Oops", text: "Something went wrong")
  #   ]
  module TurboStreamHelper
    # Emit a <turbo-stream action="swal"> tag with raw SA2 options.
    #
    #   turbo_stream.swal(icon: "success", title: "OK", toast: true, timer: 3000)
    def swal(options = {})
      payload = ERB::Util.json_escape(options.to_json)
      turbo_stream_action_tag(:swal, template: payload)
    end

    # Emit a <turbo-stream action="swal"> tag mapped from a flash key.
    # Merges flash_map defaults for the key, then applies text: and any overrides.
    #
    #   turbo_stream.swal_flash(:notice, "Élément créé avec succès")
    #   turbo_stream.swal_flash(:error, "Échec", timer: 0)
    def swal_flash(key, message = nil, **overrides)
      base = SwalRails.configuration.flash_map.fetch(key.to_s, {}).dup
      base = base.merge(text: message) if message
      base = base.merge(overrides) unless overrides.empty?
      swal(base)
    end
  end
end
