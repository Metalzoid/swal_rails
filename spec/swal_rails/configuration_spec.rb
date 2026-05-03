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

    it "defaults flash_array_mode to :sequential" do
      expect(config.flash_array_mode).to eq(:sequential)
    end

    it "defaults flash_stack_delay to 500" do
      expect(config.flash_stack_delay).to eq(500)
    end

    it "defaults initializer_version to nil (drives the boot-time stale-stamp warning)" do
      expect(config.initializer_version).to be_nil
    end

    it "defaults silence_initializer_warning to false" do
      expect(config.silence_initializer_warning).to be(false)
    end

    it "defaults every flash_map key to toast: true" do
      expect(config.flash_map.values.map { |v| v[:toast] }).to all(be(true))
    end
  end

  describe "#flash_array_mode=" do
    it "accepts :sequential and :stacked" do
      %i[sequential stacked].each do |mode|
        expect { config.flash_array_mode = mode }.not_to raise_error
      end
    end

    it "coerces strings to symbols" do
      config.flash_array_mode = "stacked"
      expect(config.flash_array_mode).to eq(:stacked)
    end

    it "rejects unknown modes" do
      expect { config.flash_array_mode = :bogus }.to raise_error(ArgumentError, /flash_array_mode/)
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

    it "carries the exposeWindowSwal flag" do
      config.expose_window_swal = false
      expect(config.to_client_payload[:exposeWindowSwal]).to be(false)
    end

    it "carries flashArrayMode and flashStackDelay" do
      config.flash_array_mode = :stacked
      config.flash_stack_delay = 250
      payload = config.to_client_payload
      expect(payload[:flashArrayMode]).to eq(:stacked)
      expect(payload[:flashStackDelay]).to eq(250)
    end

    it "surfaces I18n-backed button text into the payload" do
      # Use an isolated scope so we don't leak translations into the live
      # swal_rails scope used by the system suite's SweetAlert UI.
      config.i18n_scope = "swal_rails_cfg_spec"
      I18n.backend.store_translations(
        :en,
        swal_rails_cfg_spec: { confirm_button_text: "OK mate", cancel_button_text: "Nope" }
      )

      I18n.with_locale(:en) do
        i18n = config.to_client_payload[:i18n]
        expect(i18n[:confirm_button_text]).to eq("OK mate")
        expect(i18n[:cancel_button_text]).to eq("Nope")
      end
    end
  end

  describe "#i18n_scope=" do
    it "coerces non-string values to strings" do
      config.i18n_scope = :my_scope
      expect(config.i18n_scope).to eq("my_scope")
    end
  end

  describe "#assets_mode=" do
    it "defaults to :auto" do
      expect(config.assets_mode).to eq(:auto)
    end

    it "accepts the documented modes" do
      %i[auto importmap jsbundling sprockets].each do |mode|
        config.assets_mode = mode
        expect(config.assets_mode).to eq(mode)
      end
    end

    it "rejects unknown modes" do
      expect { config.assets_mode = :webpack }.to raise_error(ArgumentError, /assets_mode/)
    end

    it "coerces strings to symbols" do
      config.assets_mode = "importmap"
      expect(config.assets_mode).to eq(:importmap)
    end
  end

  describe "#precompile_strategy=" do
    it "defaults to :all (legacy behaviour, all variants shipped)" do
      expect(config.precompile_strategy).to eq(:all)
    end

    it "accepts :all and :minimal" do
      config.precompile_strategy = :minimal
      expect(config.precompile_strategy).to eq(:minimal)
    end

    it "rejects unknown strategies" do
      expect { config.precompile_strategy = :smart }.to raise_error(ArgumentError, /precompile_strategy/)
    end
  end
end
