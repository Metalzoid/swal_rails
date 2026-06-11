# frozen_string_literal: true

require "rails_helper"
require "active_record"
require "rails/generators/test_case"
require "generators/swal_rails/preferences/preferences_generator"

RSpec.describe SwalRails::Generators::PreferencesGenerator, type: :generator do
  include Rails::Generators::Testing::Behavior
  include FileUtils

  tests described_class
  destination File.expand_path("../tmp/preferences_generator", __dir__)

  let(:initializer_with_placeholder) do
    <<~RUBY
      # frozen_string_literal: true

      SwalRails.configure do |config|
        config.confirm_mode = :data_attribute

        # "Don't show this again" preferences are off by default. Run
        # `rails g swal_rails:preferences` to add the migration, mount the
        # suppressions API, and uncomment config.preferences_enabled here.
        # config.preferences_enabled = false
        # config.current_user_method = :current_user
        # config.preferences_parent_controller = "ActionController::Base"
      end
    RUBY
  end

  let(:routes_rb) do
    <<~RUBY
      Rails.application.routes.draw do
      end
    RUBY
  end

  before do
    prepare_destination
  end

  def dest_read(relpath)
    File.read(File.join(destination_root, relpath))
  end

  def dest_write(relpath, content = "")
    full = File.join(destination_root, relpath)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
  end

  def migration_files
    Dir.glob(File.join(destination_root, "db/migrate/*_create_swal_rails_dismissed_alerts.rb"))
  end

  describe "copy_migration" do
    it "generates a migration creating swal_rails_dismissed_alerts with a bigint owner_id" do
      run_generator
      files = migration_files
      expect(files.size).to eq(1)

      contents = File.read(files.first)
      expect(contents).to include("class CreateSwalRailsDismissedAlerts < ActiveRecord::Migration")
      expect(contents).to include("create_table :swal_rails_dismissed_alerts")
      expect(contents).to include("t.bigint :owner_id, null: false")
      expect(contents).to include("t.string :key, null: false, limit: 255")
      expect(contents).to include("add_index :swal_rails_dismissed_alerts, %i[owner_type owner_id key],")
    end

    it "uses a uuid owner_id with --uuid" do
      run_generator(%w[--uuid])
      contents = File.read(migration_files.first)
      expect(contents).to include("t.uuid :owner_id, null: false")
    end
  end

  describe "mount_engine" do
    it "mounts SwalRails::Engine in config/routes.rb" do
      dest_write "config/routes.rb", routes_rb

      run_generator

      expect(dest_read("config/routes.rb")).to include('mount SwalRails::Engine => "/swal_rails"')
    end

    it "skips mounting when SwalRails::Engine is already mounted" do
      dest_write "config/routes.rb", <<~RUBY
        Rails.application.routes.draw do
          mount SwalRails::Engine => "/swal_rails"
        end
      RUBY

      run_generator

      expect(dest_read("config/routes.rb").scan("SwalRails::Engine").size).to eq(1)
    end

    it "does not touch config/routes.rb with --skip_route" do
      dest_write "config/routes.rb", routes_rb

      run_generator(%w[--skip_route])

      expect(dest_read("config/routes.rb")).not_to include("SwalRails::Engine")
    end

    it "warns and continues when config/routes.rb is missing" do
      run_generator

      expect(File).not_to exist(File.join(destination_root, "config/routes.rb"))
      expect(migration_files.size).to eq(1)
    end
  end

  describe "enable_preferences" do
    it "uncomments the preferences placeholder block in the initializer" do
      dest_write "config/initializers/swal_rails.rb", initializer_with_placeholder

      run_generator

      contents = dest_read("config/initializers/swal_rails.rb")
      expect(contents).to include("config.preferences_enabled = true")
      expect(contents).to include("config.current_user_method = :current_user")
      expect(contents).to include('config.preferences_parent_controller = "ActionController::Base"')
      expect(contents).not_to include("# config.preferences_enabled")
    end

    it "is idempotent across repeated runs" do
      dest_write "config/initializers/swal_rails.rb", initializer_with_placeholder
      dest_write "config/routes.rb", routes_rb

      run_generator
      run_generator

      contents = dest_read("config/initializers/swal_rails.rb")
      expect(contents.scan("config.preferences_enabled = true").size).to eq(1)
      expect(dest_read("config/routes.rb").scan("SwalRails::Engine").size).to eq(1)
      expect(migration_files.size).to eq(1)
    end

    it "skips when config.preferences_enabled = true is already present" do
      dest_write "config/initializers/swal_rails.rb", <<~RUBY
        SwalRails.configure do |config|
          config.preferences_enabled = true
        end
      RUBY

      run_generator

      contents = dest_read("config/initializers/swal_rails.rb")
      expect(contents.scan("config.preferences_enabled = true").size).to eq(1)
    end

    it "warns and continues when the initializer is missing" do
      run_generator

      expect(File).not_to exist(File.join(destination_root, "config/initializers/swal_rails.rb"))
      expect(migration_files.size).to eq(1)
    end
  end
end
