# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Components
    module Plumber
      module Attributes
        extend ActiveSupport::Concern

        def component_attrs(**kwargs)
          @component_attrs ||= {}
          @component_attrs[:class] = merge_class_attr(@component_attrs[:class], kwargs)
          yield kwargs, @component_attrs if block_given?
          @component_attrs.merge!(kwargs) if kwargs.present?
          @component_attrs
        end

        private

        def merge_class_attr(current, kwargs)
          return current unless kwargs.key?(:class) || kwargs.key?(:classes)

          merge_string_attr(current, kwargs.delete(:class), kwargs.delete(:classes))
        end

        def merge_string_attr(*args, delimiter: " ", **kwargs)
          merged = args.flat_map { |arg| normalize_merge_arg(arg, delimiter) }
          merged.concat(kwargs.filter_map { |key, val| key if val })
          merged.compact.uniq.join(delimiter)
        end

        def normalize_merge_arg(arg, delimiter)
          case arg
          when String then arg.present? ? arg.split(delimiter) : []
          when Hash then arg.filter_map { |key, val| key if val }
          when Array then [merge_string_attr(*arg).presence]
          else []
          end
        end
      end
    end
  end
end
