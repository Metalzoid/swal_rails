# frozen_string_literal: true

require "action_view"
require "action_view/helpers"

RSpec.describe SwalRails::Helpers do
  let(:klass) do
    Class.new do
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::OutputSafetyHelper
      include SwalRails::Helpers

      attr_accessor :output_buffer, :flash

      def initialize = @flash = {}
    end
  end

  subject(:view) { klass.new }

  describe "#swal_config_meta_tag" do
    it "emits a meta tag with JSON payload" do
      tag = view.swal_config_meta_tag
      expect(tag).to include('name="swal-config"')
      expect(tag).to include("confirmMode")
    end
  end

  describe "#swal_flash_meta_tag" do
    it "returns nil when flash is empty" do
      expect(view.swal_flash_meta_tag).to be_nil
    end

    it "emits a JSON payload for non-empty flash" do
      view.flash = { "notice" => "Saved" }
      tag = view.swal_flash_meta_tag
      expect(tag).to include('name="swal-flash"')
      expect(tag).to include("Saved")
    end

    it "skips blank messages" do
      view.flash = { "notice" => "", "alert" => "Bad" }
      tag = view.swal_flash_meta_tag
      expect(tag).to include("Bad")
      expect(tag).not_to match(/"message":"(,|"")/)
    end

    it "returns nil when disabled by config" do
      SwalRails.configuration.flash_keys_as_meta = false
      view.flash = { "notice" => "Saved" }
      expect(view.swal_flash_meta_tag).to be_nil
    end
  end

  describe "#swal_tag" do
    it "renders an ES module script" do
      out = view.swal_tag(title: "Hi", icon: "info")
      expect(out).to include('type="module"')
      expect(out).to include("Swal.fire")
      expect(out).to include('"title":"Hi"')
    end
  end
end
