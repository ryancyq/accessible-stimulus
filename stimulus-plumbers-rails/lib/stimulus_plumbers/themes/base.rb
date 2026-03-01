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
          size:  { default: :md,  range: SIZE_RANGE },
          color: { default: nil,  range: :avatar_color_range }
        }.freeze,
        action_list_item: {
          active: { default: false, range: BOOL_RANGE }
        }.freeze,
        calendar_day:     {
          today:    { default: false, range: BOOL_RANGE },
          selected: { default: false, range: BOOL_RANGE },
          outside:  { default: false, range: BOOL_RANGE }
        }.freeze,
        card:             {}.freeze,
        card_section:     {}.freeze,
        action_list:      {}.freeze,
        divider:          {}.freeze,
        popover:          {}.freeze
      }.freeze

      def attribute_names(component)
        ARG_SCHEMA.fetch(component, {}).keys
      end

      # Resolves presentational classes for a component slot.
      # Returns a Hash with :classes (String) and optionally :style (String).
      # Returns {} when no mapping exists for the given component.
      def resolve(component, **args)
        method_name = :"#{component}_classes"
        unless respond_to?(method_name, true)
          StimulusPlumbers::Logger.warn("#{self.class} has no classes method for component #{component.inspect}")
          return {}
        end

        send(method_name, **validate_args(component.to_sym, args))
      end

      def avatar_colors
        {}
      end

      def avatar_color_range
        avatar_colors.values
      end

      private

      def validate_args(component, args)
        schema = ARG_SCHEMA.fetch(component, {})
        args.slice(*schema.keys).each_with_object({}) do |(key, value), result|
          result[key] = coerce_arg(component, key, value, schema[key])
        end
      end

      def coerce_arg(component, key, value, schema)
        return value unless schema

        range = schema[:range].is_a?(Symbol) ? send(schema[:range]) : schema[:range]
        return value if range.empty? || range.include?(value)

        StimulusPlumbers::Logger.warn(
          "#{component}##{key} received unknown value #{value.inspect}. " \
          "Range: #{schema[:range].inspect}. Falling back to: #{schema[:default].inspect}"
        )
        schema[:default]
      end

      ARG_SCHEMA.each_key do |component|
        method_name = :"#{component}_classes"
        define_method(method_name) do |**|
          raise NotImplementedError, "#{self.class}##{method_name} is not implemented"
        end
      end
    end
  end
end
