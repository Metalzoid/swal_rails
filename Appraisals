# frozen_string_literal: true

# Regenerate per-version Gemfiles with: bundle exec appraisal install
#
# The base Gemfile pins Rails 8.1.3 + Propshaft for local dev. Each appraise
# block redeclares the Rails stack — Appraisal uses the last `gem` declaration
# when the same gem is named twice. `remove_gem "propshaft"` is needed for the
# sprockets variant to avoid shipping both pipelines.

appraise "rails-7-2" do
  gem "rails", "~> 7.2.2"
  gem "propshaft", "~> 0.9"
  gem "importmap-rails", "~> 2.0"
  gem "turbo-rails", "~> 2.0"
  gem "stimulus-rails", "~> 1.3"
end

appraise "rails-8-0" do
  gem "rails", "~> 8.0.0"
  gem "propshaft", "~> 1.0"
  gem "importmap-rails", "~> 2.0"
  gem "turbo-rails", "~> 2.0"
  gem "stimulus-rails", "~> 1.3"
end

appraise "rails-8-1" do
  gem "rails", "~> 8.1.3"
  gem "propshaft", "~> 1.0"
  gem "importmap-rails", "~> 2.0"
  gem "turbo-rails", "~> 2.0"
  gem "stimulus-rails", "~> 1.3"
end

# Rails LTS (8.1) with Sprockets instead of Propshaft — validates the
# alternative asset pipeline on the version most people will run in prod.
appraise "rails-8-1-sprockets" do
  remove_gem "propshaft"
  gem "rails", "~> 8.1.3"
  gem "importmap-rails", "~> 2.0"
  gem "turbo-rails", "~> 2.0"
  gem "stimulus-rails", "~> 1.3"
  gem "sprockets-rails", "~> 3.5"
end
