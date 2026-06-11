# frozen_string_literal: true

module SwalRails
  # A "don't show this again" preference recorded by an authenticated owner
  # (any model — User, Admin, Account…) for a given mute key.
  #
  # ActiveRecord is a soft dependency: this file is eager-loaded by the host
  # app (Zeitwerk expects the constant to exist), but a host generated with
  # `--skip-active-record` has no `ActiveRecord::Base` to inherit from. In that
  # case we still define the constant — as an inert stub — so eager loading /
  # `zeitwerk:check` don't blow up. `SwalRails::Preferences` guards every call
  # behind `defined?(ActiveRecord::Base)`, so the stub is never touched.
  if defined?(ActiveRecord::Base)
    class DismissedAlert < ActiveRecord::Base
      self.table_name = "swal_rails_dismissed_alerts"

      belongs_to :owner, polymorphic: true

      # length backstop matches SwalRails::Preferences::MAX_KEY_LENGTH; the
      # column is also limit:255 (see the generated migration). Preferences
      # filters oversized keys before this validation ever runs, but direct
      # model writes stay bounded too.
      validates :key, presence: true, length: { maximum: 255 },
                      uniqueness: { scope: %i[owner_type owner_id] }
    end
  else
    class DismissedAlert; end # rubocop:disable Lint/EmptyClass
  end
end
