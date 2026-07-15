# frozen_string_literal: true

module SwalRails
  # JSON API for "don't show this again" preferences, mounted by the host
  # app via `mount SwalRails::Engine => "/swal_rails"`.
  #
  # Inherits from `config.preferences_parent_controller` (default
  # ActionController::Base) so it picks up the host's session/auth setup.
  class SuppressionsController < SwalRails.configuration.preferences_parent_controller.constantize
    protect_from_forgery with: :exception if respond_to?(:protect_from_forgery)

    before_action :require_owner!

    def index
      render json: { keys: SwalRails::Preferences.suppressed_keys(current_owner) }
    end

    def create
      SwalRails::Preferences.suppress(current_owner, params.require(:key))
      head :created
    end

    def destroy
      SwalRails::Preferences.unsuppress(current_owner, params.require(:key))
      head :no_content
    end

    private

    # Mirrors Helpers#swal_rails_current_owner: a missing/unconfigured
    # current-user method means "guest" (→ 401), never a 500.
    def current_owner
      method_name = SwalRails.configuration.current_user_method
      return nil unless method_name && respond_to?(method_name, true)

      send(method_name)
    end

    def require_owner!
      head :unauthorized unless current_owner
    end
  end
end
