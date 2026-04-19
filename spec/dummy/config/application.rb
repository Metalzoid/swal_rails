# frozen_string_literal: true

require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_view/railtie"

# Whichever pipeline the gemfile selected — Propshaft (default) or Sprockets
# (the rails_8_1_sprockets appraisal variant).
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
    if config.respond_to?(:assets)
      config.assets.debug = false
      config.assets.quiet = true
    end
  end
end
