# frozen_string_literal: true

RSpec.describe SwalRails do
  it "has a version number" do
    expect(SwalRails::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it "pins a SweetAlert2 version" do
    expect(SwalRails::SWEETALERT2_VERSION).to match(/\A11\./)
  end

  describe ".configure" do
    it "yields the configuration" do
      original = described_class.configuration.confirm_mode
      described_class.configure do |config|
        config.confirm_mode = :turbo_override
      end
      expect(described_class.configuration.confirm_mode).to eq(:turbo_override)
    ensure
      described_class.configuration.confirm_mode = original
    end
  end
end
