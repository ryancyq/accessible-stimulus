# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Plumber
      class Base
        include Attributes

        attr_reader :template

        def initialize(template)
          @template = template
        end

        def theme
          StimulusPlumbers.config.theme
        end

        def self.method_added(method_name)
          super
          return if self == Base
          return unless public_method_defined?(method_name)
          return if instance_variable_get(:@_intercepting)

          instance_variable_set(:@_intercepting, true)
          original = instance_method(method_name)
          define_method(method_name) do |*args, **kwargs, &block|
            if renderer_klass.respond_to?(method_name)
              renderer_klass.public_send(method_name, *args, **kwargs, &block)
            else
              original.bind_call(self, *args, **kwargs, &block)
            end
          end
          instance_variable_set(:@_intercepting, false)
        end

        private

        def icon(name, **html_options)
          Icon::Renderer.new(template).icon(name, **html_options)
        end

        def renderer_klass
          return @renderer_klass if defined?(@renderer_klass)

          @renderer_klass = "#{self.class.module_parent.name}::#{theme.name}Renderer".safe_constantize
        end
      end
    end
  end
end
