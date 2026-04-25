# frozen_string_literal: true

RSpec.describe SwalRails::InitializerVersionCheck do
  let(:logger) { instance_double(Logger, warn: nil) }
  let(:config) { SwalRails::Configuration.new }

  describe ".run!" do
    it "is silent when initializer_version matches the gem constant" do
      config.initializer_version = SwalRails::INITIALIZER_VERSION
      described_class.run!(logger: logger, config: config)
      expect(logger).not_to have_received(:warn)
    end

    it "warns when initializer_version is nil" do
      config.initializer_version = nil
      described_class.run!(logger: logger, config: config)
      expect(logger).to have_received(:warn).with(/predates v#{Regexp.escape(SwalRails::INITIALIZER_VERSION)}/)
    end

    it "warns when initializer_version trails the gem constant" do
      config.initializer_version = "0.3.2"
      described_class.run!(logger: logger, config: config)
      expect(logger).to have_received(:warn).with(/yours: v0\.3\.2/)
    end

    it "stays silent when silence_initializer_warning is true, even if stale" do
      config.initializer_version = nil
      config.silence_initializer_warning = true
      described_class.run!(logger: logger, config: config)
      expect(logger).not_to have_received(:warn)
    end

    it "embeds the regenerate hint in the warning" do
      config.initializer_version = "0.0.0"
      described_class.run!(logger: logger, config: config)
      expect(logger).to have_received(:warn).with(%r{bin/rails g swal_rails:install --skip-layout --force})
    end
  end

  describe ".stale_message" do
    it "returns nil when versions match" do
      config.initializer_version = SwalRails::INITIALIZER_VERSION
      expect(described_class.stale_message(config)).to be_nil
    end

    it "returns the missing-stamp message when initializer_version is nil" do
      config.initializer_version = nil
      expect(described_class.stale_message(config)).to include("predates")
    end

    it "returns the version-trail message when initializer_version differs" do
      config.initializer_version = "0.3.0"
      expect(described_class.stale_message(config)).to include("yours: v0.3.0")
    end
  end
end
