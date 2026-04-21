# frozen_string_literal: true

require_relative "spec_helper"
require "rspec/rails"
require "capybara/rspec"
require "capybara/cuprite"

abort("Rails is running in production mode!") if Rails.env.production?

Capybara.register_driver(:cuprite) do |app|
  # CI runners boot Chromium cold on the first system spec — default 10s
  # is flaky, 60s gives headroom without masking real hangs.
  # `disable-dev-shm-usage` avoids /dev/shm exhaustion in containers.
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1280, 800],
    browser_options: {
      "no-sandbox" => nil,
      "disable-dev-shm-usage" => nil,
      "disable-gpu" => nil
    },
    headless: true,
    process_timeout: ENV["CI"] ? 60 : 20,
    timeout: 10
  )
end
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.use_transactional_fixtures = false

  config.before(:each, type: :system) { driven_by :cuprite }
end
