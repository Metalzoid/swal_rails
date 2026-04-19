# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

# spec_helper boots a Rails application from spec/dummy.
# To keep unit-test load times low, we only initialize once.
require_relative "dummy/config/environment" unless defined?(Rails) && Rails.application&.initialized?

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) { SwalRails.reset_configuration! }
end
