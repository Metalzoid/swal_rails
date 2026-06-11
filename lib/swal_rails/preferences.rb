# frozen_string_literal: true

module SwalRails
  # "Don't show this again" preferences for logged-in owners.
  #
  # No-ops (returns blank/false, never raises) unless
  # `config.preferences_enabled` is true, ActiveRecord is loaded, and the
  # `swal_rails_dismissed_alerts` table exists — so a half-installed gem
  # never breaks a request. Run `rails g swal_rails:preferences` to enable.
  module Preferences
    # Caps to keep the suppressions table (and the per-request meta tag that
    # serializes every key) from being flooded by an authenticated client.
    # Mute keys are short app-defined identifiers ("posts.destroy"), so 255
    # chars and 1000 keys per owner are generous in practice while bounding
    # storage and response size.
    MAX_KEY_LENGTH = 255
    MAX_KEYS_PER_OWNER = 1_000

    module_function

    def enabled?
      return false unless SwalRails.configuration.preferences_enabled
      return false unless defined?(ActiveRecord::Base)

      DismissedAlert.table_exists?
    rescue StandardError
      false
    end

    # Keys the given owner has muted for good.
    def suppressed_keys(owner)
      return [] unless enabled? && owner

      DismissedAlert.where(owner: owner).pluck(:key)
    end

    def suppressed?(owner, key)
      return false unless enabled? && owner

      DismissedAlert.exists?(owner: owner, key: key.to_s)
    end

    # Records that `owner` no longer wants to see `key`. Silently ignores
    # blank/oversized keys and writes beyond the per-owner cap — an
    # authenticated client can't flood the table or inflate the meta tag.
    def suppress(owner, key)
      return unless enabled? && owner

      key = key.to_s
      return if key.empty? || key.length > MAX_KEY_LENGTH
      # Re-suppressing an existing key is a no-op (idempotent) and never
      # counts against the cap; only genuinely new keys are bounded.
      return if DismissedAlert.exists?(owner: owner, key: key)
      return if DismissedAlert.where(owner: owner).count >= MAX_KEYS_PER_OWNER

      DismissedAlert.create_or_find_by!(owner: owner, key: key)
    end

    def unsuppress(owner, key)
      return unless enabled? && owner

      DismissedAlert.where(owner: owner, key: key.to_s).delete_all
    end

    # Clears every stored preference, for every owner and key.
    def reset_all
      return unless enabled?

      DismissedAlert.delete_all
    end

    # Clears stored preferences scoped by `owner` and/or `key`.
    # With neither argument, behaves like `reset_all`.
    def reset(owner: nil, key: nil)
      return reset_all if owner.nil? && key.nil?
      return unless enabled?

      scope = DismissedAlert.all
      scope = scope.where(owner: owner) if owner
      scope = scope.where(key: key.to_s) if key
      scope.delete_all
    end
  end
end
