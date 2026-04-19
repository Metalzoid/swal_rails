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

      payload = flash.to_h.filter_map do |key, message|
        next if message.blank?

        { key: key.to_s, message: message.to_s }
      end
      return if payload.empty?

      tag.meta(name: "swal-flash", content: payload.to_json)
    end

    # Generates an inline `<script>` that fires a single Swal.
    # Usage: `<%= swal_tag(title: "Hi", icon: "info") %>`
    def swal_tag(options = {})
      javascript_tag(<<~JS.strip, type: "module")
        import Swal from "sweetalert2";
        Swal.fire(#{options.to_json});
      JS
    end
  end
end
