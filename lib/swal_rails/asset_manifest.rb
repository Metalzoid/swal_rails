# frozen_string_literal: true

module SwalRails
  # Computes the list of vendored sweetalert2 assets the host should
  # precompile, based on `SwalRails.configuration.assets_mode` and
  # `precompile_strategy`. Kept side-effect-free so it's easy to test
  # without booting a full Rails app.
  module AssetManifest
    GEM_FILES = %w[
      swal_rails/index.js
      swal_rails/confirm.js
      swal_rails/flash.js
      swal_rails/chain.js
      swal_rails/controllers/swal_controller.js
      swal_rails/index.css
    ].freeze

    THEME_FILES = %w[
      themes/bootstrap-4.css
      themes/bootstrap-5.css
      themes/borderless.css
      themes/bulma.css
      themes/material-ui.css
      themes/minimal.css
    ].freeze

    ALL_VENDOR_FILES = %w[
      sweetalert2.js
      sweetalert2.min.js
      sweetalert2.all.js
      sweetalert2.all.min.js
      sweetalert2.esm.js
      sweetalert2.esm.min.js
      sweetalert2.esm.all.js
      sweetalert2.esm.all.min.js
      sweetalert2.css
      sweetalert2.min.css
    ].freeze

    # Returns the list of asset paths to add to `config.assets.precompile`.
    # Always includes the gem's own JS/CSS entrypoints (small, host-facing).
    # Vendored sweetalert2 variants depend on `precompile_strategy`:
    #   `:all`     → every JS + CSS variant + every theme (legacy)
    #   `:minimal` → only the variant matching the resolved assets_mode,
    #                plus the canonical CSS bundle
    def self.precompile_for(configuration, app_root: nil)
      strategy = configuration.precompile_strategy
      mode = resolve_assets_mode(configuration.assets_mode, app_root)

      base = GEM_FILES.dup
      base.concat(vendor_files_for(strategy, mode))
      base.concat(THEME_FILES) if strategy == :all
      base.uniq
    end

    # When `assets_mode` is `:auto`, sniff the host's filesystem to infer
    # which Rails asset pipeline is in use. Mirrors the heuristic in the
    # install generator (importmap.rb → :importmap, package.json → :jsbundling,
    # else :sprockets) so explicit and auto-detected behaviour match.
    def self.resolve_assets_mode(mode, app_root)
      return mode unless mode == :auto
      return :sprockets unless app_root

      return :importmap if app_root.join("config/importmap.rb").exist?
      return :jsbundling if app_root.join("package.json").exist?

      :sprockets
    end

    def self.vendor_files_for(strategy, mode)
      return ALL_VENDOR_FILES if strategy == :all

      case mode
      when :importmap
        # Importmap pins `sweetalert2` to the ESM bundle; CSS is sprocketed
        # separately so we ship `index.css` (which @imports the canonical CSS).
        %w[sweetalert2.esm.all.min.js sweetalert2.min.css]
      when :jsbundling
        # JS comes from `npm install sweetalert2`; we only ship the CSS.
        %w[sweetalert2.min.css]
      when :sprockets
        # Classic sprockets users `javascript_include_tag "sweetalert2.all.min"`.
        %w[sweetalert2.all.min.js sweetalert2.min.css]
      else
        ALL_VENDOR_FILES
      end
    end
  end
end
