# frozen_string_literal: true

module SwalRails
  # View helpers exposed to ActionView and ActionController.
  #
  # Place `swal_rails_meta_tags` in your layout `<head>` to emit:
  #   - the global client config (once per request)
  #   - the per-request flash payload
  module Helpers
    # Emits the meta tags the JS runtime reads on boot.
    def swal_rails_meta_tags
      safe_join([swal_config_meta_tag, swal_flash_meta_tag, swal_preferences_meta_tag].compact, "\n")
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

    # Emits `<meta name="swal-preferences">` with the "don't show this
    # again" state for the current request: whether preferences are
    # enabled, whether the visitor is a known owner (vs. guest/localStorage),
    # the suppressions API path (omitted if the engine isn't mounted), and
    # the keys this owner has already muted.
    def swal_preferences_meta_tag
      # Gate on Preferences.enabled? (config flag AND the table actually
      # existing), not just the config flag. In a half-installed state
      # (generator run, migration pending) we emit no tag, so the JS store
      # treats everyone as a guest and falls back to localStorage instead of
      # POSTing to an API that would silently no-op.
      return unless SwalRails::Preferences.enabled?

      owner = swal_rails_current_owner
      payload = {
        enabled: true,
        owner: owner.present?,
        path: swal_rails_suppressions_path,
        keys: swal_rails_suppressed_keys
      }.compact
      tag.meta(name: "swal-preferences", content: payload.to_json)
    end

    # Rails idiom: `flash[:notice] = model.errors.full_messages` — expand arrays
    # into one entry per message so each fires its own Swal.
    #
    # Also accepts per-request option overrides:
    #   flash[:notice] = "Saved"                                       # string shortcut
    #   flash[:notice] = { text: "Saved", icon: "star", timer: 5000 }  # full SA2 options
    def build_flash_payload
      suppressed = swal_rails_suppressed_keys
      flash.to_h.flat_map do |key, message|
        flash_messages(message).filter_map do |m|
          next if m.blank?

          options = m.is_a?(Hash) ? m.symbolize_keys : { text: m.to_s }
          next if options[:_muteKey] && suppressed.include?(options[:_muteKey])

          { key: key.to_s, options: options }
        end
      end
    end

    # Arrays expand into one entry per element. A Hash is a single entry —
    # don't let `Array(hash)` destructure it into key/value pairs.
    def flash_messages(message)
      message.is_a?(Array) ? message : [message]
    end

    # Controller/view sugar for setting a flash entry with per-request
    # overrides of the global flash_array_mode / flash_stack_delay config.
    #
    #   swal_flash :alert, @post.errors.full_messages, mode: :stacked, delay: 300
    #   swal_flash :notice, "Deployed!", icon: "rocket", timer: 5000
    #   swal_flash :alert, "Oops", now: true            # uses flash.now
    #
    # `mode:` — :sequential | :stacked (overrides config.flash_array_mode for this payload)
    # `delay:` — ms between stacked toasts (overrides config.flash_stack_delay)
    # `now:`   — write to flash.now (for rendered responses, no redirect)
    # `mute_key:` — unique key enabling a "don't show this again" checkbox;
    #               once muted, this entry is filtered server-side (owners)
    #               or by the JS runtime (guests, via localStorage)
    # `**options` — any extra SA2 options merged into each entry
    #
    # Meta-keys `_arrayMode` / `_stackDelay` / `_muteKey` are reserved —
    # the JS runtime strips them before passing options to Swal.fire.
    def swal_flash(key, messages, mode: nil, delay: nil, now: false, mute_key: nil, **options) # rubocop:disable Metrics/ParameterLists
      entries = build_swal_flash_entries(messages, swal_flash_meta(mode, delay, mute_key), options)
      return if entries.empty?

      (now ? flash.now : flash)[key] = entries.size == 1 ? entries.first : entries
    end

    private

    def swal_flash_meta(mode, delay, mute_key = nil)
      meta = {}
      meta[:_arrayMode] = mode.to_s if mode
      meta[:_stackDelay] = Integer(delay) if delay
      meta[:_muteKey] = mute_key.to_s if mute_key
      meta
    end

    # Resolves the current owner via `config.current_user_method`, if the
    # controller/view responds to it. Returns nil for guests or when
    # preferences aren't enabled.
    def swal_rails_current_owner
      method_name = SwalRails.configuration.current_user_method
      return nil unless method_name && respond_to?(method_name, true)

      send(method_name)
    end

    # Memoized per-request: keys the current owner has muted for good.
    #
    # Short-circuits before resolving the owner when preferences are off (the
    # default), so `build_flash_payload` never invokes the host's
    # `current_user` — with its potential DB hits or exceptions — on the flash
    # path of an app that doesn't use this feature.
    def swal_rails_suppressed_keys
      return @swal_rails_suppressed_keys if defined?(@swal_rails_suppressed_keys)

      @swal_rails_suppressed_keys =
        if SwalRails::Preferences.enabled?
          SwalRails::Preferences.suppressed_keys(swal_rails_current_owner)
        else
          []
        end
    end

    # The mounted suppressions API path, or nil if the engine isn't mounted
    # (the JS runtime then falls back to localStorage-only for guests).
    def swal_rails_suppressions_path
      return nil unless respond_to?(:swal_rails)

      swal_rails.suppressions_path
    rescue NoMethodError
      nil
    end

    def build_swal_flash_entries(messages, meta, options)
      list = messages.is_a?(Array) ? messages : [messages]
      list.filter_map do |m|
        next if m.blank?

        base = m.is_a?(Hash) ? m.symbolize_keys : { text: m.to_s }
        base.merge(options).merge(meta)
      end
    end

    public

    # Generates an inline `<script>` that fires a single Swal.
    #
    # Usage: `<%= swal_tag(title: "Hi", icon: "info") %>`
    # Under a strict CSP: `<%= swal_tag({ title: "Hi" }, nonce: true) %>`
    #
    # When `nonce: true` is passed and ActionView's CSP helper is available,
    # Rails substitutes the per-request nonce so the tag survives a
    # `script-src 'self' 'nonce-…'` policy.
    #
    # @deprecated Inline `<script>` tags add per-request CSP nonce overhead
    #   and are not cacheable. Prefer the `data-swal-confirm` attribute or
    #   the bundled Stimulus controller (`data-controller="swal"
    #   data-action="click->swal#fire"`). Slated for removal in v1.0.
    def swal_tag(options = {}, html_options = {})
      ActiveSupport::Deprecation.new("1.0", "swal_rails").warn(
        "swal_tag is deprecated. Use the bundled Stimulus controller " \
        "(data-controller=\"swal\" data-action=\"click->swal#fire\" " \
        "data-swal-options-value=\"…\") or a data-swal-confirm attribute. " \
        "swal_tag will be removed in swal_rails 1.0."
      )
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

    # Fires a multi-step confirm chain inline on page load.
    #
    # Usage: `<%= swal_chain_tag([{ title: "Sure?" }, { title: "Really?" }]) %>`
    # Under a strict CSP: `<%= swal_chain_tag(steps, nonce: true) %>`
    #
    # Same XSS hardening and CSP nonce handling as `swal_tag`. Each step is
    # a full SweetAlert2 options Hash; `onConfirmed:` / `onDenied:` keys
    # declare nested sub-chains for conditional branching.
    #
    # @deprecated Same trade-offs as `swal_tag`. Prefer `data-swal-steps`
    #   on a button/form. Slated for removal in v1.0.
    def swal_chain_tag(steps, html_options = {})
      ActiveSupport::Deprecation.new("1.0", "swal_rails").warn(
        "swal_chain_tag is deprecated. Use a data-swal-steps attribute on " \
        "the triggering element. swal_chain_tag will be removed in swal_rails 1.0."
      )
      # Array(hash) destructures a Hash into [[k, v], ...] pairs — wrap
      # single Hash steps manually so shorthand `swal_chain_tag(title: "Hi")`
      # produces `[{"title":"Hi"}]`, not `[["title","Hi"]]`.
      steps = [steps] unless steps.is_a?(Array)
      payload = ERB::Util.json_escape(steps.to_json)
      tag_options = { type: "module" }.merge(html_options)
      tag_options.delete(:nonce) if tag_options[:nonce] == true && !respond_to?(:content_security_policy_nonce, true)
      javascript_tag(<<~JS.strip, **tag_options)
        import Swal from "sweetalert2";
        import { chainDialogs } from "swal_rails/chain";
        chainDialogs(Swal, #{payload});
      JS
    end
  end
end
