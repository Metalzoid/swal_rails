# frozen_string_literal: true

require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_view/railtie"

# Use whichever asset pipeline is available in the current gemset:
# Propshaft (Rails 7.2+ default) or Sprockets (Rails 7.0/7.1).
begin
  require "propshaft"
rescue LoadError
  require "sprockets/railtie"
end

require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"

require "swal_rails"

module Dummy
  class Application < Rails::Application
    rails_version = Rails::VERSION::STRING.to_f
    config.load_defaults rails_version
    config.eager_load = false
    config.root = File.expand_path("..", __dir__)
    config.secret_key_base = "dummy-key-for-tests"
    config.logger = Logger.new($stdout)
    config.log_level = :warn
    config.hosts.clear
    config.active_support.deprecation = :silence
    config.autoload_paths << config.root.join("app/controllers").to_s

    if config.respond_to?(:assets)
      config.assets.debug = false
      config.assets.quiet = true
    end
  end
end
