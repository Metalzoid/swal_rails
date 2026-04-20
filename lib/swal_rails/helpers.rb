# frozen_string_literal: true

module SwalRails
  # View helpers exposed to ActionView and ActionController.
  #
  # Place `swal_rails_meta_tags` in your layout `<head>` to emit:
  #   - the global client config (once per request)
  #   - the per-request flash payload
  module Helpers
    # Emits the two meta tags the JS runtime reads on boot.
    def swal_rails_meta_tags
      safe_join([swal_config_meta_tag, swal_flash_meta_tag].compact, "\n")
    end

    def swal_config_meta_tag
      payload = SwalRails.configuration.to_client_payload
      tag.meta(name: "swal-config", content: payload.to_json)
    end

    def swal_flash_meta_tag
      return unless SwalRails.configuration.flash_keys_as_meta
      return if flash.blank?

      payload = build_flash_payload
      return if payload.empty?

      tag.meta(name: "swal-flash", content: payload.to_json)
    end

    # Rails idiom: `flash[:notice] = model.errors.full_messages` — expand arrays
    # into one entry per message so each fires its own Swal.
    #
    # Also accepts per-request option overrides:
    #   flash[:notice] = "Saved"                                       # string shortcut
    #   flash[:notice] = { text: "Saved", icon: "star", timer: 5000 }  # full SA2 options
    def build_flash_payload
      flash.to_h.flat_map do |key, message|
        flash_messages(message).filter_map do |m|
          next if m.blank?

          options = m.is_a?(Hash) ? m.symbolize_keys : { text: m.to_s }
          { key: key.to_s, options: options }
        end
      end
    end

    # Arrays expand into one entry per element. A Hash is a single entry —
    # don't let `Array(hash)` destructure it into key/value pairs.
    def flash_messages(message)
      message.is_a?(Array) ? message : [message]
    end

    # Generates an inline `<script>` that fires a single Swal.
    #
    # Usage: `<%= swal_tag(title: "Hi", icon: "info") %>`
    # Under a strict CSP: `<%= swal_tag({ title: "Hi" }, nonce: true) %>`
    #
    # When `nonce: true` is passed and ActionView's CSP helper is available,
    # Rails substitutes the per-request nonce so the tag survives a
    # `script-src 'self' 'nonce-…'` policy.
    def swal_tag(options = {}, html_options = {})
      # json_escape neutralizes `</script>`, `<!--`, U+2028 and U+2029 —
      # the four sequences that can break out of a <script> block.
      payload = ERB::Util.json_escape(options.to_json)
      tag_options = { type: "module" }.merge(html_options)
      tag_options.delete(:nonce) if tag_options[:nonce] == true && !respond_to?(:content_security_policy_nonce, true)
      javascript_tag(<<~JS.strip, **tag_options)
        import Swal from "sweetalert2";
        Swal.fire(#{payload});
      JS
    end
  end
end
