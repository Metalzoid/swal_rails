# frozen_string_literal: true

require_relative "lib/swal_rails/version"

Gem::Specification.new do |spec|
  spec.name = "swal_rails"
  spec.version = SwalRails::VERSION
  spec.authors = ["Florian Gagnaire"]
  spec.email = ["gagnaire.flo@gmail.com"]

  spec.summary = "SweetAlert2 for Rails 7+ — batteries included (importmap, jsbundling, sprockets)."
  spec.description = <<~DESC
    swal_rails integrates SweetAlert2 v11 into Rails 7+ applications with first-class
    support for importmap, jsbundling, and sprockets. Includes auto-wired flash messages,
    Turbo confirm replacement, a Stimulus controller, Ruby view helpers, and full I18n.
  DESC
  spec.homepage = "https://github.com/Metalzoid/swal_rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml sig/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 7.0"
  spec.add_dependency "zeitwerk", ">= 2.6"
end
