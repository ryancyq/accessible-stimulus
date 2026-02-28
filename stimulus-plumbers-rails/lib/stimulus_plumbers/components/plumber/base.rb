# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Plumber
      class Base < ViewComponent::Base
        include StimulusPlumbers::Components::Plumber::Attributes
        include StimulusPlumbers::Components::Plumber::Views

        class << self
          attr_writer :tag_prefix, :component_name

          def tag_prefix
            @tag_prefix ||= component_name.dasherize
          end

          def component_name
            @component_name ||= name
                                .sub(%r{\AStimulusPlumbers::Components::}, "") # strip component namespace
                                .sub(%r{Component\z}, "")                      # strip class suffix
                                .split("::")
                                .join("_")
                                .underscore
                                .to_sym
          end
        end

        def initialize(**kwargs)
          super()
          component_attrs(**theme.resolve(self.class.component_name, **kwargs), **kwargs) do |args, _attrs|
            process_theme_args(args)
            process_stimulus_args(args)
          end
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

        private

        def process_theme_args(args)
          theme.attribute_names(self.class.component_name).each { args.delete(_1) }
        end

        def process_stimulus_args(args)
          stimulus.extract(args[:data]) if args[:data].is_a?(Hash)
          stimulus.extract(args.delete(:stimulus)) if args[:stimulus].is_a?(Hash)
        end

        def before_render
          (component_attrs[:data] ||= {}).merge!(stimulus.data) if stimulus.data.present?
        end
      end
    end
  end
end
