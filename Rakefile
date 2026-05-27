# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

# ---------------------------------------------------------------------------
# npm companion package tasks
# ---------------------------------------------------------------------------
namespace :npm do
  require "fileutils"
  require "json"

  JS_SRC  = "app/assets/javascripts/swal_rails"
  JS_DEST = "npm"

  desc "Sync JS files from #{JS_SRC}/ → #{JS_DEST}/ and bump version in package.json"
  task :sync do
    require_relative "lib/swal_rails/version"

    Dir.glob("#{JS_SRC}/**/*.js").each do |src|
      rel  = src.sub("#{JS_SRC}/", "")
      dest = "#{JS_DEST}/#{rel}"
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
      puts "  synced #{rel}"
    end

    pkg_path = "#{JS_DEST}/package.json"
    pkg = JSON.parse(File.read(pkg_path))
    pkg["version"] = SwalRails::VERSION
    File.write(pkg_path, JSON.pretty_generate(pkg) + "\n")
    puts "  version → #{SwalRails::VERSION}"
  end

  desc "Publish npm package to registry (runs npm:sync first)"
  task publish: :sync do
    Dir.chdir(JS_DEST) do
      system("npm publish --access public") || abort("npm publish failed")
    end
  end
end
