# frozen_string_literal: true

require_relative "swal_rails/version"

module SwalRails
  class Error < StandardError; end

  # The initializer template version this release of the gem ships.
  # Bump only when the template content changes in a way users should
  # know about (new option, removed option, default flip). Compared at
  # boot against `config.initializer_version` to warn about stale
  # config/initializers/swal_rails.rb files. Independent from gem VERSION
  # so non-template-touching releases don't trigger spurious warnings.
  INITIALIZER_VERSION = "0.3.3"

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end

require_relative "swal_rails/configuration"
require_relative "swal_rails/initializer_version_check"
require_relative "swal_rails/helpers"
require_relative "swal_rails/engine" if defined?(Rails::Engine)
