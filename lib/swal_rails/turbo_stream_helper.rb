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
    #
    # `mute_key:` adds a "don't show this again" checkbox; once
    # muted, the JS runtime skips this popup on future streams.
    #
    # Accepts both the positional-hash form (`swal({ icon: "info" })`) and the
    # bare-keyword form (`swal(icon: "info", title: "Hi")`) that worked in
    # 0.5.x. The `**opts` splat catches stray keywords and `mute_key:`, merged
    # back into a single SA2 options hash. `mute_key` is honored wherever it
    # lands (positional hash or keyword) so it never leaks into Swal.fire, and a
    # nil positional arg degrades to `{}` rather than raising.
    def swal(options = {}, **opts)
      merged = (options || {}).merge(opts)
      mute_key = merged.delete(:mute_key)
      merged = merged.merge(_muteKey: mute_key.to_s) if mute_key
      payload = ERB::Util.json_escape(merged.to_json)
      turbo_stream_action_tag(:swal, template: payload)
    end

    # Emit a <turbo-stream action="swal"> tag mapped from a flash key.
    # Merges flash_map defaults for the key, then applies text: and any overrides.
    #
    #   turbo_stream.swal_flash(:notice, "Élément créé avec succès")
    #   turbo_stream.swal_flash(:error, "Échec", timer: 0)
    #   turbo_stream.swal_flash(:notice, "Élément créé", mute_key: "items.created")
    def swal_flash(key, message = nil, mute_key: nil, **overrides)
      base = SwalRails.configuration.flash_map.fetch(key.to_sym, {}).dup
      base = base.merge(text: message) if message
      base = base.merge(overrides) unless overrides.empty?
      swal(base, mute_key: mute_key)
    end
  end
end
