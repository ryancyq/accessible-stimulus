# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Components
    module Plumber
      module StimulusRegistry
        extend ActiveSupport::Concern

        def extract(attrs)
          extract_stimulus_controllers!(attrs)
          extract_stimulus_actions!(attrs)
          extract_stimulus_attrs!(attrs)
        end

        def data
          {
            controller: controllers.compact.join(" ").presence,
            action:     actions.compact.join(" ").presence,
            **targets,
            **class_names,
            **values
          }.compact
        end

        def controller(name)
          raise ArgumentError if name.nil? || name.blank?

          registered_controllers[name] ||= {}
          registered_controllers[name][:controller] = true
        end

        def controllers
          @controllers ||= registered_controllers.filter_map { |controller, attrs| controller if attrs[:controller] }
        end

        def target(name, controller: nil)
          attrs = controller_registered_or_default(controller)
          raise ArgumentError, "controller name is required" if attrs.nil?

          attrs[:targets] ||= []
          attrs[:targets] << name unless attrs[:targets].include?(name)
        end

        def targets
          @targets ||= registered_controllers.each_with_object({}) do |(controller, attrs), result|
            attrs[:targets]&.each { result[:"#{controller}-target"] = _1 }
          end
        end

        def action(emitter, receiver = nil, controller: nil)
          event = if block_given?
                    attrs = controller_registered_or_default(controller)
                    raise ArgumentError, "controller name is required" if attrs.nil?

                    yield attrs
                  elsif !emitter.nil? && !receiver.nil?
                    "#{emitter}->#{receiver}"
                  else
                    emitter
                  end
          actions << event unless event.nil? || actions.include?(event)
        end

        def actions
          @actions ||= []
        end

        def class_name(name, css, controller: nil)
          attrs = controller_registered_or_default(controller)
          raise ArgumentError, "controller name is required" if attrs.nil?

          attrs[:class_names] ||= {}
          attrs[:class_names][name] ||= []
          attrs[:class_names][name] << css unless attrs[:class_names][name].include?(css)
        end

        def class_names
          @class_names ||= registered_controllers.each_with_object({}) do |(controller, attrs), result|
            attrs[:class_names]&.each do |name, css|
              class_identifier = [controller, name.underscore.dasherize, "class"].join("-")
              result[class_identifier.to_sym] = css.compact.map { _1.to_s.strip }.join(" ")
            end
          end
        end

        def value(name, value, controller: nil)
          attrs = controller_registered_or_default(controller)
          raise ArgumentError, "controller name is required" if attrs.nil?

          attrs[:values] ||= {}
          attrs[:values][name] = value.is_a?(Array) || value.is_a?(Hash) ? JSON.generate(value) : value.to_s
        end

        def values
          @values ||= registered_controllers.each_with_object({}) do |(controller, attrs), result|
            attrs[:values]&.each do |name, value|
              value_identifier = [controller, name.underscore.dasherize, "value"].join("-")
              result[value_identifier.to_sym] = value
            end
          end
        end

        STIMULUS_ATTR_REGEX = %r{.*-(?<suffix>\w+)$}.freeze
        STIMULUS_ATTR_SUFFIXES = %w[target class value].freeze

        private

        def extract_stimulus_controllers!(attrs)
          extract_attribute(:controller, attrs) do |controller|
            collection = controller.is_a?(Enumerable) ? controller : controller.to_s.split
            collection.each { controller(_1) }
          end
        end

        def extract_stimulus_actions!(attrs)
          extract_attribute(:action, attrs) do |action|
            collection = action.is_a?(Enumerable) ? action : action.to_s.split
            collection.each { action(_1) }
          end
        end

        def extract_stimulus_attrs!(attrs)
          attrs.each_pair do |key, value|
            matched = STIMULUS_ATTR_REGEX.match(key)
            next unless matched && STIMULUS_ATTR_SUFFIXES.include?(matched[:suffix])

            case matched[:suffix]
            when "target" then target(key, value)
            when "class" then class_name(key, value)
            when "value" then value(key, value)
            end
          end
        end

        def registered_controllers
          @registered_controllers ||= {}
        end

        def controller_registered_or_default(controller_name)
          if controller_name.present?
            registered_controllers[controller_name] ||= {}
          elsif registered_controllers.size == 1
            registered_controllers[registered_controllers.keys.first]
          end
        end

        def extract_attribute(attr_name, attrs)
          return unless attrs.key?(attr_name)

          yield attrs.delete(attr_name)
        end
      end
    end
  end
end
