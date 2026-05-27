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
require "fileutils"
require "json"

NPM_JS_SRC  = "app/assets/javascripts/swal_rails"
NPM_JS_DEST = "npm"

def npm_sync_files
  require_relative "lib/swal_rails/version"

  Dir.glob("#{NPM_JS_SRC}/**/*.js").each do |src|
    rel  = src.sub("#{NPM_JS_SRC}/", "")
    dest = "#{NPM_JS_DEST}/#{rel}"
    FileUtils.mkdir_p(File.dirname(dest))
    FileUtils.cp(src, dest)
    puts "  synced #{rel}"
  end

  pkg_path = "#{NPM_JS_DEST}/package.json"
  pkg = JSON.parse(File.read(pkg_path))
  pkg["version"] = SwalRails::VERSION
  File.write(pkg_path, "#{JSON.pretty_generate(pkg)}\n")
  puts "  version → #{SwalRails::VERSION}"
end

namespace :npm do
  desc "Sync JS files from #{NPM_JS_SRC}/ → #{NPM_JS_DEST}/ and bump version in package.json"
  task(:sync) { npm_sync_files }

  desc "Publish npm package to registry (runs npm:sync first)"
  task publish: :sync do
    Dir.chdir(NPM_JS_DEST) do
      system("npm publish --access public") || abort("npm publish failed")
    end
  end
end
