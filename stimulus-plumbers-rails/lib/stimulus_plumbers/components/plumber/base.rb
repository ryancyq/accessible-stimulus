# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Plumber
      class Base < ViewComponent::Base
        include StimulusPlumbers::Components::Plumber::Attributes
        include StimulusPlumbers::Components::Plumber::Views

        class << self
          def tag_prefix
            @tag_prefix ||= component_name.dasherize
          end

          def tag_prefix=(value)
            @tag_prefix = value
          end

          def component_name
            @component_name ||= name
              .sub(/\AStimulusPlumbers::Components::/, "") # strip component namespace
              .sub(/Component\z/, "")                      # strip class suffix
              .split("::")
              .join("_")
              .underscore
              .to_sym
          end

          def component_name=(value)
            @component_name = value
          end
        end

        def initialize(**kwargs)
          super()
          component_attrs(**theme.resolve(self.class.component_name, **kwargs), **kwargs) do |args, _attrs|
            stimulus.extract(args[:data]) if args[:data].is_a?(Hash)
            stimulus.extract(args.delete(:stimulus)) if args[:stimulus].is_a?(Hash)
          end
        end

        def before_render
          (component_attrs[:data] ||= {}).merge!(stimulus.data) if stimulus.data.present?
        end

        def theme
          StimulusPlumbers.config.theme
        end

        def stimulus
          @stimulus ||= Class.new { include StimulusPlumbers::Components::Plumber::StimulusRegistry }.new
        end

        def dom_id(*args)
          target = args.first
          if (target.is_a?(Class) && target < ActiveRecord::Base) || (target in ActiveRecord::Base)
            return helpers.dom_id(*args) # rails helper
          end

          [self.class.tag_prefix, *args.map(&:to_s), SecureRandom.uuid].join("-")
        end
      end
    end
  end
end
