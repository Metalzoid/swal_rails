# frozen_string_literal: true

# Regenerate per-version Gemfiles with: bundle exec appraisal install
#
# The base Gemfile pins Rails 8.1 + Propshaft for local dev. Each appraise
# block overrides those pins — hence the `remove_gem` calls before
# redeclaring versions.

appraise "rails-7-0" do
  remove_gem "rails"
  remove_gem "propshaft"
  remove_gem "importmap-rails"
  remove_gem "turbo-rails"
  remove_gem "stimulus-rails"
  gem "rails", "~> 7.0.8"
  gem "importmap-rails", "~> 1.2"
  gem "turbo-rails", "~> 1.5"
  gem "stimulus-rails", "~> 1.3"
  gem "sprockets-rails", "~> 3.4"
  gem "concurrent-ruby", "1.3.4"
end

appraise "rails-7-1" do
  remove_gem "rails"
  remove_gem "propshaft"
  remove_gem "importmap-rails"
  remove_gem "turbo-rails"
  remove_gem "stimulus-rails"
  gem "rails", "~> 7.1.5"
  gem "importmap-rails", "~> 2.0"
  gem "turbo-rails", "~> 2.0"
  gem "stimulus-rails", "~> 1.3"
  gem "sprockets-rails", "~> 3.5"
end

appraise "rails-7-2" do
  remove_gem "rails"
  remove_gem "propshaft"
  remove_gem "importmap-rails"
  remove_gem "turbo-rails"
  remove_gem "stimulus-rails"
  gem "rails", "~> 7.2.2"
  gem "propshaft", "~> 0.9"
  gem "importmap-rails", "~> 2.0"
  gem "turbo-rails", "~> 2.0"
  gem "stimulus-rails", "~> 1.3"
end

appraise "rails-8-0" do
  remove_gem "rails"
  remove_gem "propshaft"
  remove_gem "importmap-rails"
  remove_gem "turbo-rails"
  remove_gem "stimulus-rails"
  gem "rails", "~> 8.0.0"
  gem "propshaft", "~> 1.0"
  gem "importmap-rails", "~> 2.0"
  gem "turbo-rails", "~> 2.0"
  gem "stimulus-rails", "~> 1.3"
end

appraise "rails-8-1" do
  remove_gem "rails"
  remove_gem "propshaft"
  remove_gem "importmap-rails"
  remove_gem "turbo-rails"
  remove_gem "stimulus-rails"
  gem "rails", "~> 8.1.0"
  gem "propshaft", "~> 1.0"
  gem "importmap-rails", "~> 2.0"
  gem "turbo-rails", "~> 2.0"
  gem "stimulus-rails", "~> 1.3"
end

# Rails LTS (8.1) with Sprockets instead of Propshaft — validates the
# alternative asset pipeline on the version most people will run in prod.
appraise "rails-8-1-sprockets" do
  remove_gem "rails"
  remove_gem "propshaft"
  remove_gem "importmap-rails"
  remove_gem "turbo-rails"
  remove_gem "stimulus-rails"
  gem "rails", "~> 8.1.0"
  gem "importmap-rails", "~> 2.0"
  gem "turbo-rails", "~> 2.0"
  gem "stimulus-rails", "~> 1.3"
  gem "sprockets-rails", "~> 3.5"
end
