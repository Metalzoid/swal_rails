# frozen_string_literal: true

module SwalRails
  # Compares the user's `config.initializer_version` against the gem's
  # `SwalRails::INITIALIZER_VERSION` and logs a one-line warning when the
  # initializer is missing the stamp or trails the gem's expected value.
  #
  # Wired into the engine after `:load_config_initializers` so it sees
  # whatever the user set. Silenced via
  # `config.silence_initializer_warning = true`.
  module InitializerVersionCheck
    module_function

    def run!(logger: default_logger, config: SwalRails.configuration)
      return if config.silence_initializer_warning

      message = stale_message(config)
      return unless message

      logger.warn(message)
    end

    def stale_message(config)
      user = config.initializer_version
      current = SwalRails::INITIALIZER_VERSION

      return nil if user == current

      regen = "Run `bin/rails g swal_rails:install --skip-layout --force` to regenerate, or set " \
              "`config.silence_initializer_warning = true` to silence."

      if user.nil?
        "[swal_rails] config/initializers/swal_rails.rb predates v#{current} " \
          "(no `config.initializer_version` set). New options may be missing. #{regen}"
      else
        "[swal_rails] initializer template advanced to v#{current} (yours: v#{user}). #{regen}"
      end
    end

    def default_logger
      defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger ? Rails.logger : Logger.new($stderr)
    end
  end
end
