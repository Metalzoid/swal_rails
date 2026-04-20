# frozen_string_literal: true

require "rails_helper"

RSpec.describe SwalRails::Engine do
  describe "asset precompile list" do
    let(:precompile) { Rails.application.config.assets.precompile }

    it "includes the ESM builds pinned by importmap" do
      # Regression lock: the engine used to ship only the non-ESM builds,
      # which broke Sprockets host apps the moment javascript_importmap_tags
      # hit `sweetalert2.esm.all.js`.
      expect(precompile).to include("sweetalert2.esm.all.js")
      expect(precompile).to include("sweetalert2.esm.js")
    end

    it "includes the gem's own entry points" do
      expect(precompile).to include("swal_rails/index.js")
      expect(precompile).to include("swal_rails/confirm.js")
      expect(precompile).to include("swal_rails/flash.js")
      expect(precompile).to include("swal_rails/controllers/swal_controller.js")
    end
  end

  describe "I18n load path" do
    it "contributes the gem's locale files" do
      loaded = I18n.load_path.map(&:to_s)
      expect(loaded.any? { |p| p.include?("swal_rails") && p.end_with?(".yml") }).to be(true)
    end
  end
end
