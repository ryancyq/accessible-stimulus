# frozen_string_literal: true

require "active_support/concern"

module StimulusPlumbers
  module Components
    module Plumber
      module Views
        extend ActiveSupport::Concern

        COMPONENTS = Dir.glob(File.join("*_component.rb"), base: __dir__).each_with_object({}) do |path, result|
          component_path = path.chomp("_component.rb")
          component_name = component_path.gsub(File::Separator, "_")
          component_klazz = component_path.classify
          result.tap { result[component_name.to_sym] = component_klazz }
        end

        included do
          # def component_name_tag(*args, **kwargs, &block)
          #   render ComponentNameComponent.new(*args, **kwargs), &block
          # end
          generated_component_helpers.module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
            #{COMPONENTS.map { |name, klazz| component_helper_template(name, klazz) }.join(";")}
          RUBY
        end

        module ClassMethods
          def generated_component_helpers
            @generated_component_helpers ||= Module.new.tap { |mod| include mod }
          end

          def component_helper_template(name, klazz)
            <<-RUBY
              def #{name}_tag(*args, **kwargs, &block)
                render #{klazz}Component.new(*args, **kwargs), &block
              end
            RUBY
          end
        end
      end
    end
  end
end
