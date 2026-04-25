# frozen_string_literal: true

# Stamp the dummy initializer against the gem's current template version
# so the boot-time check stays silent during the test suite. Specs that
# exercise the warning paths invoke `InitializerVersionCheck.run!` directly
# with overridden values.
SwalRails.configure do |config|
  config.initializer_version = SwalRails::INITIALIZER_VERSION
end
