# frozen_string_literal: true

require "rails/engine"

module SwalRails
  class Engine < ::Rails::Engine
    isolate_namespace SwalRails

    config.swal_rails = SwalRails.configuration

    initializer "swal_rails.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("vendor/javascript/sweetalert2").to_s
        app.config.assets.paths << root.join("vendor/stylesheets/sweetalert2").to_s
        app.config.assets.paths << root.join("app/assets/javascripts").to_s
        app.config.assets.paths << root.join("app/assets/stylesheets").to_s
        app.config.assets.precompile += %w[
          sweetalert2.js sweetalert2.min.js
          sweetalert2.all.js sweetalert2.all.min.js
          sweetalert2.esm.js sweetalert2.esm.min.js
          sweetalert2.esm.all.js sweetalert2.esm.all.min.js
          sweetalert2.css sweetalert2.min.css
          swal_rails/index.js swal_rails/confirm.js swal_rails/flash.js
          swal_rails/controllers/swal_controller.js
        ]
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
      end
      ActiveSupport.on_load(:action_view) do
        include SwalRails::Helpers
      end
    end

    initializer "swal_rails.i18n" do
      config.i18n.load_path += Dir[root.join("config/locales/*.yml").to_s]
    end
  end
end

require "swal_rails/helpers"
