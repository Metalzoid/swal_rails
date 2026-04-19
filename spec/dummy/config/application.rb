# frozen_string_literal: true

require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "propshaft"
require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"

require "swal_rails"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.root = File.expand_path("..", __dir__)
    config.secret_key_base = "dummy-key-for-tests"
    config.logger = Logger.new($stdout)
    config.log_level = :warn
    config.hosts.clear
    config.active_support.deprecation = :silence
    config.autoload_paths << config.root.join("app/controllers").to_s
    config.assets.debug = false
    config.assets.quiet = true
  end
end
