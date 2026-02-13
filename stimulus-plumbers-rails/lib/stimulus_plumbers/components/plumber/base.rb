# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Plumber
      class Base < ViewComponent::Base
        include StimulusPlumbers::Components::Plumber::Attributes
        include StimulusPlumbers::Components::Plumber::Views

        class << self
          def dom_prefix(value = nil)
            @dom_prefix = value unless value.nil?
            @dom_prefix
          end
        end

        def initialize(**kwargs)
          super()
          component_attrs(**kwargs) do |args, _attrs|
            stimulus.extract(args[:data]) if args[:data].is_a?(Hash)
            stimulus.extract(args.delete(:stimulus)) if args[:stimulus].is_a?(Hash)
          end
        end

        def before_render
          return if stimulus.data.blank?

          component_attrs[:data] ||= {}
          component_attrs[:data].merge!(stimulus.data)
        end

        def stimulus
          @stimulus ||= Class.new.tap do |klazz|
            klazz.include StimulusPlumbers::Components::Plumber::StimulusRegistry
          end.new
        end

        def auth(name = nil)
          request.env.fetch ["rodauth", *name].join(".")
        end

        def dom_prefix
          @dom_prefix ||= self.class.dom_prefix || self.class.name.underscore.gsub("/", "-").chomp("_component")
        end

        def dom_id(*args)
          target = args.first
          if (target.is_a?(Class) && target < ActiveRecord::Base) || (target in ActiveRecord::Base)
            return helpers.dom_id(*args)
          end

          [dom_prefix, *args.map(&:to_s), SecureRandom.uuid].join("-")
        end
      end
    end
  end
end
