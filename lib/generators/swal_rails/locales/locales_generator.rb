# frozen_string_literal: true

require "rails/generators/base"

module SwalRails
  module Generators
    class LocalesGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../config/locales", __dir__)

      desc "Copies swal_rails locale files (en, fr) into config/locales/"

      def copy_locales
        Dir["#{self.class.source_root}/*.yml"].each do |file|
          copy_file file, "config/locales/#{File.basename(file)}"
        end
      end
    end
  end
end
