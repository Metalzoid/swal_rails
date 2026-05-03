# frozen_string_literal: true

require "spec_helper"
require "swal_rails"
require "pathname"

RSpec.describe SwalRails::AssetManifest do
  let(:config) { SwalRails::Configuration.new }

  describe ".precompile_for with :all strategy (default)" do
    it "ships every vendored variant + every theme" do
      list = described_class.precompile_for(config)
      expect(list).to include(
        "sweetalert2.js",
        "sweetalert2.min.js",
        "sweetalert2.all.min.js",
        "sweetalert2.esm.all.min.js",
        "sweetalert2.css",
        "sweetalert2.min.css",
        "themes/bootstrap-5.css",
        "themes/material-ui.css"
      )
    end

    it "always includes the gem's own entry points" do
      list = described_class.precompile_for(config)
      expect(list).to include(
        "swal_rails/index.js",
        "swal_rails/confirm.js",
        "swal_rails/flash.js",
        "swal_rails/chain.js",
        "swal_rails/controllers/swal_controller.js",
        "swal_rails/index.css"
      )
    end
  end

  describe ".precompile_for with :minimal strategy" do
    before { config.precompile_strategy = :minimal }

    it "with assets_mode=:importmap, ships only the ESM bundle + canonical CSS" do
      config.assets_mode = :importmap
      list = described_class.precompile_for(config)

      expect(list).to include("sweetalert2.esm.all.min.js", "sweetalert2.min.css")
      expect(list).not_to include(
        "sweetalert2.all.min.js",
        "sweetalert2.js",
        "sweetalert2.esm.js"
      )
    end

    it "with assets_mode=:sprockets, ships the all.min.js bundle" do
      config.assets_mode = :sprockets
      list = described_class.precompile_for(config)

      expect(list).to include("sweetalert2.all.min.js", "sweetalert2.min.css")
      expect(list).not_to include("sweetalert2.esm.all.min.js")
    end

    it "with assets_mode=:jsbundling, ships only the CSS (JS comes from npm)" do
      config.assets_mode = :jsbundling
      list = described_class.precompile_for(config)

      expect(list).to include("sweetalert2.min.css")
      expect(list).not_to include(
        "sweetalert2.esm.all.min.js",
        "sweetalert2.all.min.js"
      )
    end

    it "drops the optional themes" do
      config.assets_mode = :importmap
      list = described_class.precompile_for(config)
      expect(list).not_to include("themes/bootstrap-5.css")
    end
  end

  describe ".resolve_assets_mode (auto-detection)" do
    it "returns the explicit mode when not :auto" do
      expect(described_class.resolve_assets_mode(:importmap, nil)).to eq(:importmap)
    end

    it "with :auto + importmap.rb present, resolves to :importmap" do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p("#{root}/config")
        File.write("#{root}/config/importmap.rb", "")
        expect(described_class.resolve_assets_mode(:auto, Pathname(root))).to eq(:importmap)
      end
    end

    it "with :auto + package.json present (no importmap), resolves to :jsbundling" do
      Dir.mktmpdir do |root|
        File.write("#{root}/package.json", "{}")
        expect(described_class.resolve_assets_mode(:auto, Pathname(root))).to eq(:jsbundling)
      end
    end

    it "with :auto + neither file, falls back to :sprockets" do
      Dir.mktmpdir do |root|
        expect(described_class.resolve_assets_mode(:auto, Pathname(root))).to eq(:sprockets)
      end
    end
  end
end
