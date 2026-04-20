# frozen_string_literal: true

RSpec.describe SwalRails::Configuration do
  subject(:config) { described_class.new }

  describe "defaults" do
    it "defaults confirm_mode to :data_attribute" do
      expect(config.confirm_mode).to eq(:data_attribute)
    end

    it "seeds a flash_map covering the usual Rails flash keys" do
      expect(config.flash_map.keys).to include(:notice, :alert, :success, :error, :warning, :info)
    end

    it "enables reduced-motion respect by default" do
      expect(config.respect_reduced_motion).to be(true)
    end
  end

  describe "#confirm_mode=" do
    it "accepts valid symbols" do
      %i[off data_attribute turbo_override both].each do |mode|
        expect { config.confirm_mode = mode }.not_to raise_error
      end
    end

    it "rejects unknown modes" do
      expect { config.confirm_mode = :bogus }.to raise_error(ArgumentError, /confirm_mode/)
    end

    it "coerces strings to symbols" do
      config.confirm_mode = "turbo_override"
      expect(config.confirm_mode).to eq(:turbo_override)
    end
  end

  describe "#flash_map=" do
    it "replaces the full map and normalizes keys to symbols" do
      config.flash_map = { "notice" => { icon: "success" } }
      expect(config.flash_map).to eq(notice: { icon: "success" })
    end

    it "rejects non-hash assignments" do
      expect { config.flash_map = [] }.to raise_error(ArgumentError)
    end
  end

  describe "#to_client_payload" do
    it "returns a serializable hash" do
      payload = config.to_client_payload
      expect(payload).to include(:confirmMode, :flashMap, :defaultOptions, :respectReducedMotion)
      expect { payload.to_json }.not_to raise_error
    end
  end
end
