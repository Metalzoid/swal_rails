# frozen_string_literal: true

require "rails/engine"

module SwalRails
  class Engine < ::Rails::Engine
    isolate_namespace SwalRails

    config.swal_rails = SwalRails.configuration

    initializer "swal_rails.assets", after: :load_config_initializers do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("vendor/javascript/sweetalert2").to_s
        app.config.assets.paths << root.join("vendor/stylesheets/sweetalert2").to_s
        app.config.assets.paths << root.join("app/assets/javascripts").to_s
        app.config.assets.paths << root.join("app/assets/stylesheets").to_s
        app.config.assets.precompile += SwalRails::AssetManifest.precompile_for(
          SwalRails.configuration,
          app_root: app.root
        )
      end
    end

    initializer "swal_rails.importmap", before: "importmap" do |app|
      next unless app.config.respond_to?(:importmap)

      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
      app.config.importmap.cache_sweepers << root.join("vendor/javascript")
    end

    initializer "swal_rails.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper SwalRails::Helpers
        # Expose `swal_flash` as a controller method so controllers can
        # set flash entries with per-request mode/delay overrides.
        include SwalRails::Helpers
      end
      ActiveSupport.on_load(:action_view) do
        include SwalRails::Helpers
      end
    end

    initializer "swal_rails.i18n" do
      config.i18n.load_path += Dir[root.join("config/locales/*.yml").to_s]
    end

    # Run AFTER user initializers so we can read whatever value they set
    # (or didn't set) for `config.initializer_version`. One-shot, idempotent,
    # opt-out via `config.silence_initializer_warning = true`.
    initializer "swal_rails.check_initializer_version", after: :load_config_initializers do
      SwalRails::InitializerVersionCheck.run!
    end
  end
end

require "swal_rails/helpers"
