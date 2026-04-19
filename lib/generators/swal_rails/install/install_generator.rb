# frozen_string_literal: true

require "rails/generators"
require "rails/generators/base"

module SwalRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      ASSETS_MODES = %w[importmap jsbundling sprockets auto].freeze

      class_option :assets, type: :string, default: "auto",
                            desc: "Asset delivery mode: #{ASSETS_MODES.join(", ")}"
      class_option :confirm_mode, type: :string, default: "data_attribute",
                                  desc: "Default confirm mode: off | data_attribute | turbo_override | both"
      class_option :skip_layout, type: :boolean, default: false,
                                 desc: "Skip injecting meta tags into application.html.erb"

      def validate_options!
        return if ASSETS_MODES.include?(options[:assets])

        raise Thor::Error, "--assets must be one of #{ASSETS_MODES.join(", ")}"
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/swal_rails.rb"
      end

      def configure_assets
        case resolved_assets_mode
        when "importmap"  then install_importmap
        when "jsbundling" then install_jsbundling
        when "sprockets"  then install_sprockets
        end
      end

      def inject_meta_tags
        return if options[:skip_layout]

        layout = "app/views/layouts/application.html.erb"
        return say_status(:skip, "#{layout} not found", :yellow) unless File.exist?(layout)

        inject_into_file layout, before: %r{</head>} do
          "    <%= swal_rails_meta_tags %>\n  "
        end
      end

      def show_readme
        readme_text = <<~TXT

          swal_rails installed.

          Next steps:
            1. Edit config/initializers/swal_rails.rb to customize flash_map / confirm_mode.
            2. Ensure <%= swal_rails_meta_tags %> is rendered in your <head>.
            3. Import the runtime in your JS entrypoint:
                 import "swal_rails"

          Confirm mode: #{options[:confirm_mode]}
          Assets mode:  #{resolved_assets_mode}
        TXT
        say readme_text, :green
      end

      private

      def resolved_assets_mode
        @resolved_assets_mode ||= detect_assets_mode
      end

      def detect_assets_mode
        return options[:assets] unless options[:assets] == "auto"
        return "importmap"  if File.exist?("config/importmap.rb")
        return "jsbundling" if File.exist?("package.json")

        "sprockets"
      end

      def install_importmap
        pin_line = 'pin "swal_rails", to: "swal_rails/index.js"'
        pin_sa2  = 'pin "sweetalert2", to: "sweetalert2.esm.all.js"'

        if File.exist?("config/importmap.rb")
          append_unique "config/importmap.rb", pin_sa2
          append_unique "config/importmap.rb", pin_line
        else
          say_status(:warn, "config/importmap.rb not found, skipping pins", :yellow)
        end

        app_js = "app/javascript/application.js"
        if File.exist?(app_js)
          append_unique app_js, 'import "swal_rails"'
        else
          say_status(:warn, "#{app_js} not found, add `import \"swal_rails\"` to your JS entrypoint", :yellow)
        end
      end

      def install_jsbundling
        if File.exist?("package.json")
          run "yarn add sweetalert2@#{SwalRails::SWEETALERT2_VERSION}" if File.exist?("yarn.lock")
          run "npm install sweetalert2@#{SwalRails::SWEETALERT2_VERSION}" if File.exist?("package-lock.json") && !File.exist?("yarn.lock")
        else
          say_status(:warn, "package.json not found", :yellow)
        end

        app_js = "app/javascript/application.js"
        if File.exist?(app_js)
          append_unique app_js, 'import "swal_rails"'
        else
          say_status(:warn, "#{app_js} not found", :yellow)
        end
      end

      def install_sprockets
        manifest = "app/assets/config/manifest.js"
        if File.exist?(manifest)
          append_unique manifest, "//= link sweetalert2.js"
          append_unique manifest, "//= link sweetalert2.css"
        else
          say_status(:warn, "#{manifest} not found; add `//= require sweetalert2` to your bundle", :yellow)
        end
      end

      def append_unique(path, line)
        content = File.read(path)
        return if content.include?(line)

        append_to_file path, "\n#{line}\n"
      end
    end
  end
end
