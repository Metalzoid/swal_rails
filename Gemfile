# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "irb"
gem "rake", "~> 13.0"

# Rails stack — pinned to the latest stable for local dev.
# Declared at top level (not in a group) so Appraisal's `remove_gem`
# can override them per-version in gemfiles/.
gem "importmap-rails", "~> 2.0"
gem "propshaft", "~> 1.0"
gem "rails", "~> 8.1.3"
gem "stimulus-rails", "~> 1.3"
gem "turbo-rails", "~> 2.0"

group :development, :test do
  gem "appraisal", "~> 2.5"
  gem "capybara", "~> 3.40"
  gem "cuprite", "~> 0.15"
  gem "puma", "~> 8.0"
  gem "rspec", "~> 3.12"
  gem "rspec-rails", "~> 8.0"
  gem "rubocop", "~> 1.60", require: false
  gem "rubocop-rspec", require: false
  gem "sqlite3", "~> 1.7"
end
