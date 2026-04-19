# frozen_string_literal: true

require_relative "swal_rails/version"

module SwalRails
  class Error < StandardError; end

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
require_relative "swal_rails/helpers"
require_relative "swal_rails/engine" if defined?(Rails::Engine)
