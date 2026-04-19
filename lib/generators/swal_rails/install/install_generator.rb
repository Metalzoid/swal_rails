# frozen_string_literal: true

require "rails/generators"
require "rails/generators/base"

module SwalRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      ASSETS_MODES = %w[importmap jsbundling sprockets auto].freeze

      # `--mode` is used instead of `--assets` because Rails::Generators::Base
      # reserves `:assets` as a boolean option (legacy `rails new --skip-assets`).
      class_option :mode, type: :string, default: "auto", desc: "Asset mode: importmap, jsbundling, sprockets, auto"
      class_option :confirm_mode, type: :string, default: "data_attribute", desc: "Confirm mode: off, data_attribute, turbo_override, both"
      class_option :skip_layout, type: :boolean, default: false, desc: "Skip layout injection"

      def validate_options!
        mode = (options[:mode] || "auto").to_s
        return if ASSETS_MODES.include?(mode)

        raise Thor::Error, "--mode must be one of #{ASSETS_MODES.join(", ")}"
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
        return say_status(:skip, "#{layout} not found", :yellow) unless file_exists?(layout)

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
        mode = (options[:mode] || "auto").to_s
        return mode unless mode == "auto"
        return "importmap"  if file_exists?("config/importmap.rb")
        return "jsbundling" if file_exists?("package.json")

        "sprockets"
      end

      def install_importmap
        pin_line = 'pin "swal_rails", to: "swal_rails/index.js"'
        pin_sa2  = 'pin "sweetalert2", to: "sweetalert2.esm.all.js"'

        if file_exists?("config/importmap.rb")
          append_unique "config/importmap.rb", pin_sa2
          append_unique "config/importmap.rb", pin_line
        else
          say_status(:warn, "config/importmap.rb not found, skipping pins", :yellow)
        end

        app_js = "app/javascript/application.js"
        if file_exists?(app_js)
          append_unique app_js, 'import "swal_rails"'
        else
          say_status(:warn, "#{app_js} not found, add `import \"swal_rails\"` to your JS entrypoint", :yellow)
        end
      end

      def install_jsbundling
        if file_exists?("package.json")
          run "yarn add sweetalert2@#{SwalRails::SWEETALERT2_VERSION}" if file_exists?("yarn.lock")
          run "npm install sweetalert2@#{SwalRails::SWEETALERT2_VERSION}" if file_exists?("package-lock.json") && !file_exists?("yarn.lock")
        else
          say_status(:warn, "package.json not found", :yellow)
        end

        app_js = "app/javascript/application.js"
        if file_exists?(app_js)
          append_unique app_js, 'import "swal_rails"'
        else
          say_status(:warn, "#{app_js} not found", :yellow)
        end
      end

      def install_sprockets
        manifest = "app/assets/config/manifest.js"
        if file_exists?(manifest)
          append_unique manifest, "//= link sweetalert2.js"
          append_unique manifest, "//= link sweetalert2.css"
        else
          say_status(:warn, "#{manifest} not found; add `//= require sweetalert2` to your bundle", :yellow)
        end
      end

      def append_unique(path, line)
        content = File.read(File.join(destination_root, path))
        return if content.include?(line)

        append_to_file path, "\n#{line}\n"
      end

      def file_exists?(path)
        File.exist?(File.join(destination_root, path))
      end
    end
  end
end
