# frozen_string_literal: true

require_relative "themes/base"
require_relative "themes/tailwind"

module StimulusPlumbers
  class Configuration
    DEFAULT_LOG_FORMATTER = ->(message) { "[StimulusPlumbers] #{message}" }

    def theme
      @theme ||= build_theme(:tailwind)
    end

    def theme=(value)
      @theme = build_theme(value)
    end

    def log_formatter
      @log_formatter ||= DEFAULT_LOG_FORMATTER
    end

    def log_formatter=(callable)
      raise ArgumentError, "log_formatter must respond to #call" unless callable.respond_to?(:call)

      @log_formatter = callable
    end

    private

    def build_theme(type)
      return type if type.is_a?(Themes::Base)

      case type
      when :tailwind then Themes::Tailwind.new
      else raise ArgumentError, "Unknown theme: #{type.inspect}. Pass :tailwind or a Themes::Base instance."
      end
    end
  end
end
