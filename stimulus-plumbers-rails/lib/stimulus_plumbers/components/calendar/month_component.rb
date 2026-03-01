# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      class MonthComponent < StimulusPlumbers::Components::Plumber::Base
        include ViewComponent::SlotableDefault

        renders_one :navigator_previous,
                    lambda { |tag: :button, **kwargs|
                      StimulusPlumbers::Components::Calendar::NavigatorComponent.new(
                        direction: :left,
                        tag:       tag,
                        **kwargs
                      )
                    }
        renders_one :navigator_next,
                    lambda { |tag: :button, **kwargs|
                      StimulusPlumbers::Components::Calendar::NavigatorComponent.new(
                        direction: :right,
                        tag:       tag,
                        **kwargs
                      )
                    }

        renders_one :current_day, ContainerComponent
        renders_one :current_month, ContainerComponent
        renders_one :current_year, ContainerComponent

        def initialize(**kwargs)
          stimulus.controller(stimulus_controller)
          super
        end

        def stimulus_controller
          "calendar-month"
        end
      end
    end
  end
end
