# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    class Base
      BOOL_RANGE    = [true, false].freeze
      SIZE_RANGE    = %i[sm md lg].freeze
      ALIGN_RANGE   = %i[left center right top bottom].freeze
      DIR_RANGE     = %i[row col].freeze

      ARG_SCHEMA = {
        button:           {
          variant: { default: :primary, range: %i[primary secondary outline destructive ghost link].freeze },
          size:    { default: :md,      range: SIZE_RANGE }
        }.freeze,
        button_group:     {
          alignment: { default: :left, range: ALIGN_RANGE },
          direction: { default: :row,  range: DIR_RANGE }
        }.freeze,
        avatar:           {
          size: { default: :md, range: SIZE_RANGE }
        }.freeze,
        action_list_item: {
          active: { default: false, range: BOOL_RANGE }
        }.freeze,
        calendar_day:     {
          today:    { default: false, range: BOOL_RANGE },
          selected: { default: false, range: BOOL_RANGE },
          outside:  { default: false, range: BOOL_RANGE }
        }.freeze
      }.freeze

      # Resolves presentational classes for a component slot.
      # Returns a Hash with :classes (String) and optionally :style (String).
      # Returns {} when no mapping exists for the given component.
      def resolve(component, **args)
        method_name = :"#{component}_classes"
        return {} unless respond_to?(method_name, true)

        send(method_name, **validate_args(component.to_sym, args))
      end

      private

      def validate_args(component, args)
        schema = ARG_SCHEMA[component]
        return args unless schema

        args.each_with_object({}) do |(key, value), result|
          result[key] = coerce_arg(component, key, value, schema[key])
        end
      end

      def coerce_arg(component, key, value, schema)
        return value unless schema
        return value if schema[:range].include?(value)

        log_invalid_arg(component, key, value, schema)
        schema[:default]
      end

      def log_invalid_arg(component, key, value, schema)
        message = "[StimulusPlumbers] #{component}##{key} received unknown value #{value.inspect}. " \
                  "Range: #{schema[:range].inspect}. Falling back to: #{schema[:default].inspect}"
        if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
          Rails.logger.warn(message)
        else
          warn(message)
        end
      end

      def button_classes(_variant: :primary, _size: :md)
        {}
      end

      def button_group_classes(_alignment: :left, _direction: :row)
        {}
      end

      def card_classes
        {}
      end

      def card_section_classes
        {}
      end

      def avatar_classes(_size: :md)
        {}
      end

      def action_list_classes
        {}
      end

      def action_list_item_classes(_active: false)
        {}
      end

      def divider_classes
        {}
      end

      def popover_classes
        {}
      end

      def calendar_day_classes(_today: false, _selected: false, _outside: false)
        {}
      end
    end
  end
end
