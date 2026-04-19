# frozen_string_literal: true

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false
  config.public_file_server.enabled = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  # Rails 7.1+ accepts :rescuable (symbol); Rails 7.0 expects a boolean.
  config.action_dispatch.show_exceptions = Rails::VERSION::MAJOR >= 7 && Rails::VERSION::MINOR >= 1 ? :rescuable : true
  config.action_controller.allow_forgery_protection = false
  config.active_support.deprecation = :stderr
  config.hosts.clear

  if config.respond_to?(:assets)
    config.assets.compile = true
    config.assets.digest = false
  end
end
