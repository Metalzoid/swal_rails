# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "action_view/railtie"

ENV["RAILS_ENV"] ||= "test"

require "swal_rails"

class TestApp < Rails::Application
  config.eager_load = false
  config.logger = Logger.new(IO::NULL)
  config.secret_key_base = "test"
  config.active_support.deprecation = :silence
  config.hosts.clear
end
TestApp.initialize!

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) { SwalRails.reset_configuration! }
end
