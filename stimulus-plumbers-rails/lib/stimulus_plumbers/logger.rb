# frozen_string_literal: true

module StimulusPlumbers
  module Logger
    LEVELS = %i[debug info warn error].freeze

    module_function

    LEVELS.each do |level|
      define_method(level) do |message|
        tagged = StimulusPlumbers.config.log_formatter.call(message)
        if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
          Rails.logger.public_send(level, tagged)
        else
          warn(tagged)
        end
      end
    end
  end
end
