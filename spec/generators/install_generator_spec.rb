# frozen_string_literal: true

require "rails_helper"
require "rails/generators/test_case"
require "generators/swal_rails/install/install_generator"

RSpec.describe SwalRails::Generators::InstallGenerator, type: :generator do
  include Rails::Generators::Testing::Behavior
  include FileUtils

  tests described_class
  destination File.expand_path("../tmp/generator", __dir__)

  before do
    prepare_destination
  end

  def run_install(args = [])
    run_generator(args + ["--skip-layout"])
  end

  def dest_read(relpath)
    File.read(File.join(destination_root, relpath))
  end

  def dest_write(relpath, content = "")
    full = File.join(destination_root, relpath)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
  end

  def quietly
    orig = $stdout
    $stdout = File.open(File::NULL, "w")
    yield
  ensure
    $stdout.close
    $stdout = orig
  end

  it "copies the initializer" do
    run_install
    expect(File).to exist(File.join(destination_root, "config/initializers/swal_rails.rb"))
    expect(dest_read("config/initializers/swal_rails.rb")).to include("SwalRails.configure")
  end

  it "honors --confirm_mode" do
    run_install(%w[--confirm_mode=turbo_override])
    expect(dest_read("config/initializers/swal_rails.rb")).to include(":turbo_override")
  end

  context "importmap mode" do
    it "pins sweetalert2 and swal_rails in importmap.rb" do
      dest_write "config/importmap.rb", "pin \"application\"\n"
      dest_write "app/javascript/application.js", "// entrypoint\n"

      run_install(%w[--mode=importmap])

      expect(dest_read("config/importmap.rb")).to include('pin "sweetalert2"')
      expect(dest_read("config/importmap.rb")).to include('pin "swal_rails"')
      expect(dest_read("app/javascript/application.js")).to include('import "swal_rails"')
    end
  end

  context "sprockets mode" do
    it "appends link directives to manifest.js" do
      dest_write "app/assets/config/manifest.js", "//= link_tree ../images\n"

      run_install(%w[--mode=sprockets])

      manifest = dest_read("app/assets/config/manifest.js")
      expect(manifest).to include("//= link sweetalert2.js")
      expect(manifest).to include("//= link sweetalert2.css")
    end
  end

  context "auto detection" do
    it "picks importmap when config/importmap.rb exists" do
      dest_write "config/importmap.rb", "\n"
      dest_write "app/javascript/application.js", "\n"

      run_install(%w[--mode=auto])

      expect(dest_read("config/importmap.rb")).to include('pin "sweetalert2"')
    end

    it "falls back to sprockets when neither importmap nor package.json exist" do
      dest_write "app/assets/config/manifest.js", ""

      run_install(%w[--mode=auto])

      expect(dest_read("app/assets/config/manifest.js")).to include("sweetalert2")
    end
  end
end
