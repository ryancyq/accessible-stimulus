# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Components
    module Plumber
      module Attributes
        extend ActiveSupport::Concern

        def component_attrs(**kwargs)
          @component_attrs ||= {}

          if kwargs.key?(:class) || kwargs.key?(:classes)
            @component_attrs[:class] = merge_string_attribute(
              @component_attrs[:class],
              kwargs.delete(:class),
              kwargs.delete(:classes)
            )
          end

          yield kwargs, @component_attrs if block_given?

          @component_attrs.merge!(kwargs) if kwargs.present?
          @component_attrs
        end

        def merge_string_attribute(*args, delimiter: " ", **kwargs)
          merged = []
          args.each do |arg|
            case arg
            when String
              merged.push(*arg.split(delimiter)) if arg.present?
            when Hash
              arg.each do |key, val|
                merged << key if val
              end
            when Array
              merged << merge_string_attribute(*arg).presence
            end
          end
          kwargs.each do |key, val|
            merged << key if val
          end
          merged.compact.uniq.join(delimiter)
        end
      end
    end
  end
end
